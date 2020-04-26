//
//  EventsListCellView.h
//  Hvezdarna
//
//  Created by Michal Zelinka in 2013
//  Copyright (c) 2013- Michal Zelinka. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"


@interface EventsListCellView : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *timeLabel;

@property (nonatomic, strong) Event *event;

@end
