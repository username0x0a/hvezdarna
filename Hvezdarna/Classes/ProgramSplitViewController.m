//
//  ProgramSplitViewController.m
//  Hvezdarna
//
//  Created by Michal Zelinka in 2013
//  Copyright (c) 2013- Michal Zelinka. All rights reserved.
//

#import "ProgramSplitViewController.h"
#import "EventsListViewController.h"
#import "EventDetailViewController.h"

@implementation ProgramSplitViewController

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
	{
        self.title = @"Program";
		self.tabBarItem.image = [UIImage imageNamed:@"programme"];

		EventsListViewController *root = [[EventsListViewController alloc] initWithNibName:@"EventsListViewController" bundle:nil];
		EventDetailViewController *detail = [[EventDetailViewController alloc] initWithNibName:@"EventDetailViewController" bundle:nil];
		
		UINavigationController *rootNav = [[UINavigationController alloc] initWithRootViewController:root];
		UINavigationController *detailNav = [[UINavigationController alloc] initWithRootViewController:detail];
		
		self.viewControllers = [NSArray arrayWithObjects:rootNav, detailNav, nil];
		self.delegate = detail;
		root.splitViewController = self;
	}
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

@end
