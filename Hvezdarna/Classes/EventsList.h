//
//  EventsList.h
//  Hvezdarna
//
//  Created by Michal Zelinka in 2013
//  Copyright (c) 2013- Michal Zelinka. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Event.h"

typedef NS_ENUM(NSUInteger, EventsListUpdateResult) {
	EventsListUpdateResultNoChange = 0,
	EventsListUpdateResultNewData,
	EventsListUpdateResultFailure,
};

NS_ASSUME_NONNULL_BEGIN

@interface EventsList : NSObject

+ (EventsList *)sharedList;
+ (instancetype)new  UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;

- (NSArray<CalendarDay *> *)calendarForSearchTerm:(nullable NSString *)term;

- (void)checkForUpdates;
- (void)checkForUpdatesForce:(BOOL)force
                  completion:(nullable void (^)(EventsListUpdateResult result))completion;

@end

NS_ASSUME_NONNULL_END
