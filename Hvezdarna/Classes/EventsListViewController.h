//
//  EventsListViewController.h
//  Hvezdarna
//
//  Created by Michal Zelinka in 2013
//  Copyright (c) 2013- Michal Zelinka. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"

@protocol EventsListDelegate <NSObject>

- (void)eventsListDidSelectEventToDisplay:(Event *)event;

@end

@interface EventsListViewController : UIViewController
{
	UINib *nibForCells;
}

@property (nonatomic, weak) id<EventsListDelegate> delegate;

@property (nonatomic, strong) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UILabel *infoMessage;

@end
