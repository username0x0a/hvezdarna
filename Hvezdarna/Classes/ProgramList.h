//
//  ProgramList.h
//  Hvezdarna
//
//  Created by Michal Zelinka in 2013
//  Copyright (c) 2013- Michal Zelinka. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Program.h"

typedef NS_ENUM(NSUInteger, ProgramListUpdateResult) {
	ProgramListUpdateResultNoChange = 0,
	ProgramListUpdateResultNewData,
	ProgramListUpdateResultFailure,
};


@interface ProgramList : NSObject

+ (ProgramList *)sharedList;
- (instancetype)init __attribute__((unavailable("Use -sharedList instead.")));

- (NSUInteger)numberOfDays;
- (NSUInteger)numberOfEventsOnDayIndex:(NSInteger)idx;
- (NSInteger)dayAtIndex:(NSInteger)idx;
- (Program *)programOnDayIdx:(NSInteger)day atIdx:(NSInteger)idx;
- (void)processSearchWord:(NSString *)word;

- (void)checkForUpdates;
- (void)checkForUpdatesForce:(BOOL)force completion:(void (^)(ProgramListUpdateResult result))completion;

@end
