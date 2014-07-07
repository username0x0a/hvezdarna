//
//  ProgramList.m
//  Hvezdarna
//
//  Created by Michal Zelinka in 2013
//  Copyright (c) 2013- Michal Zelinka. All rights reserved.
//

#define DB_VERSION 10 // DB scheme version
#define DISPLAYED_DAYS 7 // Number of days to be taken from the DB

#import "ProgramList.h"
#import "Utils.h"
//#import "AFNetworking/AFJSONRequestOperation.h"
#import "AFJSONRequestOperation.h"
//#import "FMDatabase/FMDatabase.h"
#import "FMDatabase.h"

@interface ProgramList ()
{
	FMDatabase *db;
	NSMutableArray *working_data;
	NSLock *working_data_lock;
	NSString *search_condition;
}
@property(nonatomic,retain) FMDatabase *db;
@property(nonatomic,retain) NSMutableArray *working_data;
@property(nonatomic,retain) NSLock *working_data_lock;
@property(nonatomic,retain) NSString *search_condition;

- (id) init;

@end

@implementation ProgramList

- (id) init {
	
	self = [super init];
	if (!self) return nil;
	
	NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *path = [NSString stringWithFormat:@"%@%@", [dirPaths objectAtIndex:0], @"/program.db"];
	
	db = [FMDatabase databaseWithPath:path];
	[db setLogsErrors:YES];
	[db open];
	FMResultSet *s = [db executeQuery:@"SELECT * FROM options;"];
	if (!s || ![s next] || [s intForColumnIndex:1] < DB_VERSION) {
		NSLog(@"DB is not up-to-date, updating…");
		/// ---- Clear old DB structure ----
		[db executeUpdate:@"DROP TABLE IF EXISTS options;"];
		[db executeUpdate:@"DROP TABLE IF EXISTS events;"];
		/// ---- Create DB structure ----
		[db executeUpdate:@"CREATE TABLE options (initialized int, db_version int, last_update int);"];
		[db executeUpdate:@"INSERT INTO options VALUES(1, ?, 0);", [NSNumber numberWithInt:DB_VERSION]];
		[db executeUpdate:@"CREATE TABLE events (id integer NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE, name text, day int, \"time\" int, \"desc\" text, opts text, price text, link text);"];
	}
	search_condition = @"%";
	working_data = [NSMutableArray array];
	[self dailyCleanup];
	[self updateWorkingCopy];
	working_data_lock = [NSLock new];
	[self checkForUpdates];

	return self;
}

- (void) clearCalendarData {
	[working_data_lock lock];
	[db executeUpdate:@"DELETE FROM events;"];
	[working_data_lock unlock];
}

- (void) clearCalendarDataForDay:(NSInteger)day {
	[working_data_lock lock];
	[db executeUpdate:@"DELETE FROM events WHERE day = ?;", day];
	[working_data_lock unlock];
}

- (void) dailyCleanup {
	[working_data_lock lock];
	[db executeUpdate:@"DELETE FROM events WHERE time < ?;", [NSNumber numberWithInt:[Utils unixTimestamp]]];
	[working_data_lock unlock];
}

- (void) insertEventWithName:(NSString*)name desc:(NSString*)desc day:(NSInteger)day timestamp:(NSInteger)timestamp price:(NSString*)price link:(NSString*)link opts:(NSString*)opts {
	[working_data_lock lock];
	[db executeUpdate:@"INSERT INTO events VALUES(NULL, ?, ?, ?, ?, ?, ?, ?);",
	 name, [NSNumber numberWithInt:day], [NSNumber numberWithInt:timestamp], desc, opts, price, link];
	[working_data_lock unlock];
}

- (int) numberOfDays {
	return [working_data count];
}

- (int) numberOfEventsOnDayIndex:(NSInteger)idx {
	NSDictionary *day = [working_data objectAtIndex:idx];
	NSArray *events = [day objectForKey:@"Events"];
	return [events count];
}

- (NSInteger) dayAtIndex:(NSInteger)idx {
	NSDictionary *day = [working_data objectAtIndex:idx];
	NSString *day_id = [day objectForKey:@"Day ID"];
	return [day_id intValue];
}

- (Program*) programOnDayIdx:(NSInteger)day_idx atIdx:(NSInteger)idx
{
	NSDictionary *day = [working_data objectAtIndex:day_idx];
	NSArray *events = [day objectForKey:@"Events"];
	return [events objectAtIndex:idx];
}


- (void) checkForUpdates {
	[self checkForUpdatesForce:FALSE];
}

- (void) checkForUpdatesForce:(BOOL)force {
	FMResultSet* r = [db executeQuery:@"SELECT last_update FROM options;"];
	[r next];
	int last_update = [r intForColumnIndex:0];
	
	// Stop if not forced or updated in last 5 days
	if (!force && [Utils unixTimestamp] - last_update < 86400 * 5)
		return;
	
	NSLog(@"Trying to update calendar data…");
	
	NSURL *url = [NSURL URLWithString:@"http://hvezdarna.misacek.net/program.json"];
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	AFJSONRequestOperation *operation = [[AFJSONRequestOperation alloc] initWithRequest:request];
	
	[operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id response) {
		
		if (!response) return;
		
		NSArray *events = [response objectForKey:@"events"];
		
		if ([events count] == 0) return;
		
		[db beginTransaction];
		[self clearCalendarData];

		for (NSDictionary *event in events) {
		
			int time = [[event objectForKey:@"time"] integerValue];
			if (time < [Utils unixTimestamp]) continue;

			int day_id = [Utils getLocalDayTimestampFromTimestamp:time];
			NSString *name = [event objectForKey:@"name"];
			NSString *price = [event objectForKey:@"price"];
			NSString *desc = [event objectForKey:@"desc"];
			NSString *link = [event objectForKey:@"link"];
			NSString *opts = [event objectForKey:@"options"];
		
			[self insertEventWithName:name desc:desc day:day_id timestamp:time price:price link:link opts:opts];
		}
		
		[db executeUpdate:@"UPDATE options SET last_update = ?;", [NSNumber numberWithInt:[Utils unixTimestamp]]];
		[db commit];
		[self updateWorkingCopy];

		NSLog(@"Calendar data updated.");
					
	} failure:nil];
	[operation start];
	
}

- (void) updateWorkingCopy {
	
	[working_data_lock lock];
	// #-----
	[working_data removeAllObjects];
	
	NSNumber *now = [NSNumber numberWithInt:[Utils unixTimestamp]];
	
	FMResultSet *days_data = [db executeQuery:@"SELECT DISTINCT day FROM events WHERE name LIKE ? AND time >= ? LIMIT ?;", search_condition, now, [NSNumber numberWithInt:DISPLAYED_DAYS]];
	while ([days_data next]) {

		NSString* day_id = [days_data stringForColumnIndex:0];
		NSMutableDictionary *day = [NSMutableDictionary dictionary];
		[day setValue:day_id forKey:@"Day ID"];
		NSMutableArray *events = [NSMutableArray array];

		FMResultSet *events_data = [db executeQuery:@"SELECT * FROM events WHERE day = ? AND name LIKE ? AND time >= ?;", day_id, search_condition, now];
		while ([events_data next]) {

			Program* program = [Program programWithTitle:[events_data stringForColumnIndex:1] description:[events_data stringForColumnIndex:4] day:[day_id intValue] timestamp:[events_data intForColumnIndex:3] price:[events_data stringForColumnIndex:6] link:[events_data stringForColumnIndex:7] opts:[events_data stringForColumnIndex:5]];
			
			[events addObject:program];
		
		}
		[day setValue:events forKey:@"Events"];
		[working_data addObject:day];
	}
	
	// -----#
	[working_data_lock unlock];
}

- (void) processSearchWord:(NSString*)word
{
	word = [word stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

	if ([word length])
		search_condition = [NSString stringWithFormat:@"%%%@%%", word];
	else
		search_condition = @"%";

	[self updateWorkingCopy];
}

- (void) dealloc
{
	[working_data_lock lock];
	[db close];
	[working_data_lock unlock];
}

@end
