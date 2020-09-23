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


@interface EventsList ()

@property (nonatomic, strong) FMDatabase *db;

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

#if TARGET_OS_TV == 1
	NSString *path = NSCachesPath();
#else
	NSString *path = NSLibraryPath();
#endif

	path = [path stringByAppendingPathComponent:@"Database.sqlite"];

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

	return self;
}

- (void)clearEventsData {
	[_db executeUpdate:@"DELETE FROM events;"];
}

- (void)dailyCleanup {
	[_db executeUpdate:@"DELETE FROM events WHERE time < ?;", @([Utils unixTimestamp])];
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

		NSTimeInterval currentUnixTS = [Utils unixTimestamp];

		NSArray *events = [response[@"events"] parsedArray];
		NSTimeInterval latestUnixTS = [events.lastObject[@"time"] parsedNumber].doubleValue;
		
		if (events.count == 0 || latestUnixTS < currentUnixTS) {
			if (completion) completion(EventsListUpdateResultNoChange);
			return;
		}
		
		[_db beginTransaction];
		[self clearEventsData];

		for (NSDictionary *event in events)
		{
			NSTimeInterval time = [event[@"time"] parsedNumber].doubleValue;
			if (time < currentUnixTS) continue;

			NSInteger dayID = [Utils getLocalDayTimestampFromTimestamp:time];
			NSString *name = [event[@"name"] parsedString];

			if (!dayID || !name) continue;

			NSString *price = objectOrNull([event[@"price"] parsedString]);
			NSString *desc = objectOrNull([event[@"desc"] parsedString]);
			NSString *shortDesc = objectOrNull([event[@"short_desc"] parsedString]);
			NSString *link = objectOrNull([event[@"link"] parsedString]);
			NSArray<NSString *> *opts = objectOrNull([[[event[@"options"] parsedArray]
			  filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:
			  ^BOOL(id evaluatedObject, NSDictionary<NSString *,id> *bindings) {
				return [evaluatedObject parsedString] != nil;
			}]] componentsJoinedByString:@"|"]);

			[_db executeUpdate:@"INSERT INTO events VALUES(NULL, ?, ?, ?, ?, ?, ?, ?, ?);"
				values:@[ name, @(dayID), @(time), desc, shortDesc, opts, price, link ] error:nil];
		}
		
		[_db executeUpdate:@"UPDATE options SET last_update = ?;", @([Utils unixTimestamp])];
		[_db commit];

		DebugLog(@"Calendar data updated.");

		if (completion) completion(EventsListUpdateResultNewData);
					
	}] resume];
}

- (NSArray<CalendarDay *> *)calendarForSearchTerm:(NSString *)term
{
	term = [term parsedString];
	NSString *condition = (term) ? [NSString stringWithFormat:@"%%%@%%", term] : @"%";

	NSNumber *now = @([Utils unixTimestamp]);
	NSMutableArray<CalendarDay *> *calendar = [NSMutableArray arrayWithCapacity:32];
	
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

		[calendar addObject:day];
	}

	return [calendar copy];
}

- (void)dealloc
{
	[_db close];
}

@end
