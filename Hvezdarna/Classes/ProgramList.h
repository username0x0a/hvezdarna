//
//  ProgramList.h
//  Hvezdarna
//
//  Created by Michal Zelinka in 2013
//  Copyright (c) 2013- Michal Zelinka. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Program.h"

@interface ProgramList : NSObject

- (int) numberOfDays;
- (int) numberOfEventsOnDayIndex:(NSInteger)idx;
- (NSInteger) dayAtIndex:(NSInteger)idx;
- (Program*) programOnDayIdx:(NSInteger)day atIdx:(NSInteger)idx;
- (void) processSearchWord:(NSString*)word;

@end
