//
//  EventsListViewModel.h
//  Hvezdarna
//
//  Created by Michi on 28/02/2020.
//  Copyright © 2020 Heartpix. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Event.h"

NS_ASSUME_NONNULL_BEGIN

@interface EventsListViewModel : NSObject

@property (nonatomic, copy) void (^updateHandler)(void);

- (NSArray<CalendarDay *> *)calendarForSearchTerm:(nullable NSString *)term;

@end

NS_ASSUME_NONNULL_END
