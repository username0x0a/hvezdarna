//
//  EventsListViewModel.m
//  Hvezdarna
//
//  Created by Michi on 28/02/2020.
//  Copyright © 2020 Heartpix. All rights reserved.
//

#import "EventsListViewModel.h"
#import "EventsList.h"

@implementation EventsListViewModel

- (instancetype)init
{
	if (self = [super init])
	{
		[[EventsList sharedList] checkForUpdatesForce:NO
		  completion:^(EventsListUpdateResult result) {
			if (result != EventsListUpdateResultNewData) return;
			if (_updateHandler) _updateHandler();
		}];
	}

	return self;
}

- (NSArray<CalendarDay *> *)calendarForSearchTerm:(NSString *)term
{
	return [[EventsList sharedList] calendarForSearchTerm:term];
}

@end
