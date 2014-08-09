//
//  EventsListViewController.h
//  Hvezdarna
//
//  Created by Michal Zelinka in 2013
//  Copyright (c) 2013- Michal Zelinka. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventsListViewController : UIViewController
{
	UINib *nibForCells;
}

@property (nonatomic, strong) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UILabel *infoMessage;

@property (nonatomic, weak) UISplitViewController *splitViewController;

@end
