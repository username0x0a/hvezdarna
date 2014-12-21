//
//  ProgramList.m
//  Hvezdarna
//
//  Created by Michal Zelinka in 2013
//  Copyright (c) 2013- Michal Zelinka. All rights reserved.
//

#define DB_VERSION 11 // DB scheme version
#define DISPLAYED_DAYS 7 // Number of days to be taken from the DB

#import "ProgramList.h"
#import "Utils.h"
#import "FMDatabase.h"
#import "AFNetworking.h"


@interface ProgramList ()

@property (nonatomic, strong) FMDatabase *db;
@property (nonatomic, strong) NSMutableArray *workingData;
@property (nonatomic, strong) NSLock *workingDataLock;
@property (nonatomic, strong) NSString *searchCondition;

@end


@implementation ProgramList

- (id) init {

	self = [super init];
	if (!self) return nil;
	
	NSString *path = [NSLibraryPath() stringByAppendingPathComponent:@"Database.sqlite"];
	
	_db = [FMDatabase databaseWithPath:path];
#ifndef DEBUG
	_db.logsErrors = NO;
#endif
	[_db open];

	FMResultSet *s = [_db executeQuery:@"SELECT * FROM options;"];
	if (!s || ![s next] || [s intForColumn:@"db_version"] < DB_VERSION) {
		NSLog(@"DB is not up-to-date, updating…");
		/// ---- Clear old DB structure ----
		[_db executeUpdate:@"DROP TABLE IF EXISTS options;"];
		[_db executeUpdate:@"DROP TABLE IF EXISTS events;"];
		/// ---- Create DB structure ----
		[_db executeUpdate:@"CREATE TABLE options (initialized INTEGER NOT NULL, db_version INTEGER NOT NULL, last_update INTEGER NOT NULL);"];
		[_db executeUpdate:@"INSERT INTO options VALUES(1, ?, 0);", @(DB_VERSION)];
		[_db executeUpdate:@"CREATE TABLE events (id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE, name TEXT NOT NULL, day INTEGER NOT NULL, 'time' INTEGER NOT NULL, 'desc' TEXT, 'short_desc' TEXT, opts TEXT, price TEXT, link TEXT);"];
	}

	_searchCondition = @"%";
	_workingData = [NSMutableArray array];
	[self dailyCleanup];
	[self updateWorkingCopy];
	_workingDataLock = [NSLock new];
	[self checkForUpdates];

	return self;
}

- (void) clearCalendarData {
	[_workingDataLock lock];
	[_db executeUpdate:@"DELETE FROM events;"];
	[_workingDataLock unlock];
}

- (void) clearCalendarDataForDay:(NSInteger)day {
	[_workingDataLock lock];
	[_db executeUpdate:@"DELETE FROM events WHERE day = ?;", day];
	[_workingDataLock unlock];
}

- (void) dailyCleanup {
	[_workingDataLock lock];
	[_db executeUpdate:@"DELETE FROM events WHERE time < ?;", [NSNumber numberWithInt:[Utils unixTimestamp]]];
	[_workingDataLock unlock];
}

- (void) insertEventWithName:(NSString *)name desc:(NSString *)desc shortDesc:(NSString *)shortDesc day:(NSInteger)day timestamp:(NSInteger)timestamp price:(NSString *)price link:(NSString *)link opts:(NSArray *)opts {
	[_workingDataLock lock];
    id optsObject = ([opts isKindOfClass:[NSArray class]]) ? [opts componentsJoinedByString:@"|"] : opts;
	[_db executeUpdate:@"INSERT INTO events VALUES(NULL, ?, ?, ?, ?, ?, ?, ?, ?);",
	 name, [NSNumber numberWithInt:day], [NSNumber numberWithInt:timestamp], desc, shortDesc, optsObject, price, link];
	[_workingDataLock unlock];
}

- (NSUInteger) numberOfDays {
	return _workingData.count;
}

- (NSUInteger) numberOfEventsOnDayIndex:(NSInteger)idx {
	NSDictionary *day = [_workingData objectAtIndex:idx];
	NSArray *events = [day objectForKey:@"Events"];
	return events.count;
}

- (NSInteger) dayAtIndex:(NSInteger)idx {
	NSDictionary *day = [_workingData objectAtIndex:idx];
	NSString *day_id = [day objectForKey:@"Day ID"];
	return [day_id intValue];
}

- (Program*) programOnDayIdx:(NSInteger)day_idx atIdx:(NSInteger)idx
{
	NSDictionary *day = [_workingData objectAtIndex:day_idx];
	NSArray *events = [day objectForKey:@"Events"];
	return [events objectAtIndex:idx];
}


- (void) checkForUpdates {
	[self checkForUpdatesForce:NO];
}

- (void) checkForUpdatesForce:(BOOL)force {
	FMResultSet* r = [_db executeQuery:@"SELECT last_update FROM options;"];
	[r next];
	int last_update = [r intForColumnIndex:0];
	
	// Stop if not forced or updated in last 5 days
	if (!force && [Utils unixTimestamp] - last_update < 5 * kTimeDayInSeconds)
		return;
	
	NSLog(@"Trying to update calendar data…");
	
	NSURL *url = [NSURL URLWithString:@"http://hvezdarna.tk/program.json"];
	NSURLRequest *request = [NSURLRequest requestWithURL:url];

	AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
	operation.responseSerializer = [AFJSONResponseSerializer serializer];

	[operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id response) {
		
		if (!response) return;
		
		NSArray *events = [response objectForKey:@"events"];
		
		if ([events count] == 0) return;
		
		[_db beginTransaction];
		[self clearCalendarData];

		for (NSDictionary *event in events) {
		
			int time = [[event objectForKey:@"time"] integerValue];
			if (time < [Utils unixTimestamp]) continue;

			int day_id = [Utils getLocalDayTimestampFromTimestamp:time];
			NSString *name = event[@"name"];
			NSString *price = event[@"price"];
			NSString *desc = event[@"desc"];
			NSString *shortDesc = event[@"short_desc"];
			NSString *link = event[@"link"];
			NSArray *opts = event[@"options"];
		
			[self insertEventWithName:name desc:desc shortDesc:shortDesc day:day_id timestamp:time price:price link:link opts:opts];
		}
		
		[_db executeUpdate:@"UPDATE options SET last_update = ?;", [NSNumber numberWithInt:[Utils unixTimestamp]]];
		[_db commit];
		[self updateWorkingCopy];

		NSLog(@"Calendar data updated.");
					
	} failure:nil];
	[operation start];
	
}

- (void) updateWorkingCopy {
	
	[_workingDataLock lock];
	// #-----
	[_workingData removeAllObjects];
	
	NSNumber *now = [NSNumber numberWithInt:[Utils unixTimestamp]];
	
	FMResultSet *daysData = [_db executeQuery:@"SELECT DISTINCT day FROM events WHERE name LIKE ? AND time >= ? LIMIT ?;", _searchCondition, now, [NSNumber numberWithInt:DISPLAYED_DAYS]];
	while ([daysData next]) {

		NSString * dayID = [daysData stringForColumnIndex:0];
		NSMutableDictionary *day = [NSMutableDictionary dictionary];
		[day setValue:dayID forKey:@"Day ID"];
		NSMutableArray *events = [NSMutableArray array];

		FMResultSet *eventsData = [_db executeQuery:@"SELECT * FROM events WHERE day = ? AND name LIKE ? AND time >= ?;", dayID, _searchCondition, now];

		while ([eventsData next]) {

			NSDictionary *dict = [eventsData resultDictionary];
			if (!dict) continue;

			Program* program = [Program programFromDictionary:dict];
			if (!program) continue;
			
			[events addObject:program];

		}

		[day setValue:events forKey:@"Events"];
		[_workingData addObject:day];
	}

	// -----#
	[_workingDataLock unlock];
}

- (void) processSearchWord:(NSString *)word
{
	word = [word stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

	if ([word length])
		_searchCondition = [NSString stringWithFormat:@"%%%@%%", word];
	else
		_searchCondition = @"%";

	[self updateWorkingCopy];
}

- (void) dealloc
{
	[_workingDataLock lock];
	[_db close];
	[_workingDataLock unlock];
}

@end
