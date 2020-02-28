//
//  EventsList.m
//  Hvezdarna
//
//  Created by Michal Zelinka in 2013
//  Copyright (c) 2013- Michal Zelinka. All rights reserved.
//

#define DB_VERSION 11 // DB scheme version
#define DISPLAYED_DAYS 7 // Number of days to be taken from the DB

#import "EventsList.h"
#import "Utils.h"
#import "NSObject+Parsing.h"

#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"


@interface CalendarDay: NSObject

@property (atomic) NSInteger ID;
@property (nonatomic, copy) NSArray<Event *> *events;

@end


@implementation CalendarDay @end


@interface EventsList ()

@property (nonatomic, strong) FMDatabase *db;

@property (nonatomic, strong) NSArray<CalendarDay *> *workingData;
@property (nonatomic, strong) NSLock *workingDataLock;

@end


@implementation EventsList

+ (EventsList *)sharedList
{
	static EventsList *shared = nil;

	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		shared = [[self alloc] init];
	});

	return shared;
}

- (instancetype)init
{
	if (!(self = [super init])) return nil;

	_workingData = @[ ];
	_workingDataLock = [NSLock new];

	NSString *path = [NSLibraryPath() stringByAppendingPathComponent:@"Database.sqlite"];
	
	_db = [FMDatabase databaseWithPath:path];
#ifndef DEBUG
	_db.logsErrors = NO;
#endif
	[_db open];

	BOOL isOK = [_db tableExists:@"options"];
	if (isOK) isOK = [_db columnExists:@"initialized" inTableWithName:@"options"];
	if (isOK) isOK = [_db columnExists:@"db_version" inTableWithName:@"options"];
	if (isOK) isOK = [_db columnExists:@"last_update" inTableWithName:@"options"];

	FMResultSet *s = nil;

	if (isOK) s = [_db executeQuery:@"SELECT * FROM options;"];

	if (!isOK || !s || ![s next] || [s intForColumn:@"db_version"] < DB_VERSION) {
		DebugLog(@"DB is not up-to-date, updating…");
		/// ---- Clear old DB structure ----
		[_db executeUpdate:@"DROP TABLE IF EXISTS options;"];
		[_db executeUpdate:@"DROP TABLE IF EXISTS events;"];
		/// ---- Create DB structure ----
		[_db executeUpdate:@"CREATE TABLE options (initialized INTEGER NOT NULL, "
		 "db_version INTEGER NOT NULL, last_update INTEGER NOT NULL);"];
		[_db executeUpdate:@"INSERT INTO options VALUES(1, ?, 0);", @(DB_VERSION)];
		[_db executeUpdate:@"CREATE TABLE events (id INTEGER NOT NULL PRIMARY KEY "
		 "AUTOINCREMENT UNIQUE, name TEXT NOT NULL, day INTEGER NOT NULL, 'time' "
		 "INTEGER NOT NULL, 'desc' TEXT, 'short_desc' TEXT, opts TEXT, price TEXT, "
		 "link TEXT);"];
	}

	[self dailyCleanup];
	[self updateWorkingCopyWithTerm:nil];
	[self checkForUpdates];

	return self;
}

- (void)clearEventsData {
	[_workingDataLock lock];
	[_db executeUpdate:@"DELETE FROM events;"];
	[_workingDataLock unlock];
}

- (void)clearCalendarDataForDay:(NSInteger)day {
	[_workingDataLock lock];
	[_db executeUpdate:@"DELETE FROM events WHERE day = ?;", day];
	[_workingDataLock unlock];
}

- (void)dailyCleanup {
	[_workingDataLock lock];
	[_db executeUpdate:@"DELETE FROM events WHERE time < ?;", @([Utils unixTimestamp])];
	[_workingDataLock unlock];
}

- (void)insertEventWithName:(NSString *)name desc:(NSString *)desc shortDesc:(NSString *)shortDesc
	day:(NSInteger)day timestamp:(NSInteger)timestamp price:(NSString *)price link:(NSString *)link
	opts:(NSArray *)opts
{
	[_workingDataLock lock];
	id optsObject = ([opts isKindOfClass:[NSArray class]]) ? [opts componentsJoinedByString:@"|"] : opts;
	[_db executeUpdate:@"INSERT INTO events VALUES(NULL, ?, ?, ?, ?, ?, ?, ?, ?);",
	 name, @(day), @(timestamp), desc, shortDesc, optsObject, price, link];
	[_workingDataLock unlock];
}

- (NSUInteger)numberOfDays {
	return _workingData.count;
}

- (NSUInteger)numberOfEventsOnDayIndex:(NSInteger)idx {
	CalendarDay *day = [_workingData objectAtIndex:idx];
	return day.events.count;
}

- (NSInteger)dayAtIndex:(NSInteger)idx {
	CalendarDay *day = [_workingData objectAtIndex:idx];
	return day.ID;
}

- (Event *)eventOnDayIdx:(NSInteger)day_idx atIdx:(NSInteger)idx
{
	CalendarDay *day = [_workingData objectAtIndex:day_idx];
	return [day.events objectAtIndex:idx];
}


- (void)checkForUpdates {
	[self checkForUpdatesForce:NO completion:nil];
}

- (void)checkForUpdatesForce:(BOOL)force completion:(void (^)(EventsListUpdateResult))completion
{
	FMResultSet* r = [_db executeQuery:@"SELECT last_update FROM options;"];
	[r next];
	NSTimeInterval last_update = [r doubleForColumn:@"last_update"];
	
	// Stop if not forced or updated in last 5 days
	if (!force && [Utils unixTimestamp] - last_update < 5 * kTimeDayInSeconds) {
		if (completion) completion(EventsListUpdateResultNoChange);
		return;
	}
	
	DebugLog(@"Trying to update calendar data…");
	
	NSURL *url = [NSURL URLWithString:@"http://hvezdarna.misacek.net/program.json"];

	[[[NSURLSession sharedSession] dataTaskWithURL:url
		completionHandler:^(NSData *data, NSURLResponse *resp, NSError *error) {

		if (!data.length) {
			if (completion) completion(EventsListUpdateResultFailure);
			return;
		}

		NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
		
		NSArray *events = [response[@"events"] parsedArray];
		
		if (events.count == 0) {
			if (completion) completion(EventsListUpdateResultNoChange);
			return;
		}
		
		[_db beginTransaction];
		[self clearEventsData];

		NSTimeInterval currentUnixTS = [Utils unixTimestamp];

		for (NSDictionary *event in events)
		{
			NSTimeInterval time = [event[@"time"] parsedNumber].doubleValue;
			if (time < currentUnixTS) continue;

			NSInteger dayID = [Utils getLocalDayTimestampFromTimestamp:time];
			NSString *name = [event[@"name"] parsedString];
			NSString *price = [event[@"price"] parsedString];
			NSString *desc = [event[@"desc"] parsedString];
			NSString *shortDesc = [event[@"short_desc"] parsedString];
			NSString *link = [event[@"link"] parsedString];
			NSArray<NSString *> *opts = [[event[@"options"] parsedArray]
			  filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:
			  ^BOOL(id evaluatedObject, NSDictionary<NSString *,id> *bindings) {
				return [evaluatedObject parsedString];
			}]];
		
			[self insertEventWithName:name desc:desc shortDesc:shortDesc
				day:dayID timestamp:time price:price link:link opts:opts];
		}
		
		[_db executeUpdate:@"UPDATE options SET last_update = ?;", @([Utils unixTimestamp])];
		[_db commit];
		[self updateWorkingCopyWithTerm:nil]; // TODO

		DebugLog(@"Calendar data updated.");

		if (completion) completion(EventsListUpdateResultNewData);
					
	}] resume];
}

- (void)updateWorkingCopyWithTerm:(NSString *)term
{
	term = [term parsedString];
	NSString *condition = (term) ? [NSString stringWithFormat:@"%%%@%%", term] : @"%";

	[_workingDataLock lock];
	// #-----

	NSNumber *now = @([Utils unixTimestamp]);
	NSMutableArray<CalendarDay *> *workingData = [NSMutableArray arrayWithCapacity:32];
	
	FMResultSet *daysData = [_db executeQuery:@"SELECT DISTINCT day FROM events "
		"WHERE name LIKE ? AND time >= ? LIMIT ?;", condition, now, @(DISPLAYED_DAYS)];

	while ([daysData next])
	{
		NSDictionary *dayDict = [[daysData resultDictionary] parsedDictionary];
		if (!dayDict) continue;

		NSInteger dayID = [dayDict[@"day"] parsedNumber].integerValue;

		CalendarDay *day = [CalendarDay new];
		day.ID = dayID;

		NSMutableArray<Event *> *events = [NSMutableArray array];

		FMResultSet *eventsData = [_db executeQuery:@"SELECT * FROM events "
			"WHERE day = ? AND name LIKE ? AND time >= ?;", @(dayID), condition, now];

		while ([eventsData next])
		{
			NSDictionary *dict = [[eventsData resultDictionary] parsedDictionary];
			if (!dict) continue;

			Event *evt = [Event eventFromDictionary:dict];
			if (evt) [events addObject:evt];
		}

		day.events = events;

		[workingData addObject:day];
	}

	_workingData = workingData;

	// -----#
	[_workingDataLock unlock];
}

- (void)processSearchWord:(NSString *)word
{
	word = [word stringByTrimmingCharactersInSet:
		[NSCharacterSet whitespaceAndNewlineCharacterSet]];

	[self updateWorkingCopyWithTerm:word];
}

- (void) dealloc
{
	[_workingDataLock lock];
	[_db close];
	[_workingDataLock unlock];
}

@end
