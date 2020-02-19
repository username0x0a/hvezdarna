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


@interface ProgramSplitViewController () <UISplitViewControllerDelegate>

@end

@interface NoProgramSelectedViewController : UIViewController @end

@implementation NoProgramSelectedViewController

- (void)viewDidLoad
{
	[super viewDidLoad];

	self.view.backgroundColor = [UIColor whiteColor];

	UILabel *labe = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 280, 100)];
	labe.autoresizingMask =
		UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin |
		UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
	labe.font = [UIFont systemFontOfSize:18];
	labe.textColor = [UIColor lightGrayColor];
	labe.textAlignment = NSTextAlignmentCenter;
	labe.text = @"Vyberte pořad ze seznamu";
	[self.view addCenteredSubview:labe];
}

@end


@implementation ProgramSplitViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
	{
		self.title = @"Program";
		self.tabBarItem.image = [UIImage imageNamed:@"programme"];

		EventsListViewController *root = [[EventsListViewController alloc] initWithNibName:@"EventsListViewController" bundle:nil];
		NoProgramSelectedViewController *blank = [NoProgramSelectedViewController new];
		
		UINavigationController *rootNav = [[UINavigationController alloc] initWithRootViewController:root];
		UINavigationController *detailNav = [[UINavigationController alloc] initWithRootViewController:blank];
		
		self.viewControllers = @[ rootNav, detailNav ];
		root.splitViewController = self;

		self.delegate = self;
		self.preferredDisplayMode = UISplitViewControllerDisplayModeAllVisible;
	}

	return self;
}

- (BOOL)splitViewController:(UISplitViewController *)splitViewController
         showViewController:(UIViewController *)vc sender:(id)sender
{
	return NO;
}

- (BOOL)splitViewController:(UISplitViewController *)splitViewController
   showDetailViewController:(UIViewController *)vc sender:(id)sender
{
	if (splitViewController.collapsed == NO)
	{
		// The navigation controller we'll be adding the view controller vc to.
		UINavigationController *navController = splitViewController.viewControllers[1];

		UIViewController *topDetailViewController = [navController.viewControllers lastObject];
		if ([topDetailViewController isKindOfClass:[NoProgramSelectedViewController class]] ||
			[topDetailViewController isKindOfClass:[EventDetailViewController class]])
		{
			// Replace the (expanded) detail view with this new view controller.
			[navController setViewControllers:@[ vc ] animated:NO];
		}
		else
		{
			// Otherwise, just push.
			[navController pushViewController:vc animated:YES];
		}
	}
	else
	{
		// Collapsed.  Just push onto the conbined primary and detailed navigation controller.
		UINavigationController *navController = splitViewController.viewControllers[0];
		[navController pushViewController:vc animated:YES];
	}

	// We've handled this ourselves.
	return YES;
}

- (BOOL)splitViewController:(UISplitViewController *)splitViewController
collapseSecondaryViewController:(UIViewController *)secondaryViewController
  ontoPrimaryViewController:(UIViewController *)primaryViewController
{
	UINavigationController *primaryNavController = (UINavigationController *)primaryViewController;
	UINavigationController *secondaryNavController = (UINavigationController *)secondaryViewController;
	UIViewController *bottomSecondaryView = [secondaryNavController.viewControllers firstObject];
	if ([bottomSecondaryView isKindOfClass:[NoProgramSelectedViewController class]])
	{
		NSAssert([secondaryNavController.viewControllers count] == 1, @"BlankViewController is not only detail view controller");
		// If our secondary controller is blank, do the collapse ourself by doing nothing.
		return YES;
	}

	// We need to shift these view controllers ourselves.
	// This should be the primary views and then the detailed views on top.
	// Otherwise the UISplitViewController does wacky things like embedding a UINavigationController inside another UINavigation Controller, which causes problems for us later.
	NSMutableArray *newPrimaryViewControllers = [NSMutableArray arrayWithArray:primaryNavController.viewControllers];
	[newPrimaryViewControllers addObjectsFromArray:secondaryNavController.viewControllers];
	primaryNavController.viewControllers = newPrimaryViewControllers;

	return YES;
}

- (UIViewController *)splitViewController:(UISplitViewController *)splitViewController
separateSecondaryViewControllerFromPrimaryViewController:(UIViewController *)primaryViewController
{
	UINavigationController *primaryNavController = (UINavigationController *)primaryViewController;

	// Split up the combined primary and detail navigation controller in their component primary and detail view controller lists, but with same ordering.
	NSMutableArray *newPrimaryViewControllers = [NSMutableArray array];
	NSMutableArray *newDetailViewControllers = [NSMutableArray array];
	for (UIViewController *controller in primaryNavController.viewControllers)
	{
		if ([controller isKindOfClass:[EventDetailViewController class]])
		{
			[newDetailViewControllers addObject:controller];
		}
		else
		{
			[newPrimaryViewControllers addObject:controller];
		}
	}

	if (newDetailViewControllers.count == 0)
	{
		// If there's no detailed views on the top of the navigation stack, return a blank view  (in navigation controller) for detailed side.
		UINavigationController *blankDetailNavController = [[UINavigationController alloc] initWithRootViewController:[[NoProgramSelectedViewController alloc] init]];
		return blankDetailNavController;
	}

	// Set the new primary views.
	primaryNavController.viewControllers = newPrimaryViewControllers;

	// Return the new detail navigation controller and views.
	UINavigationController *detailNavController = [[UINavigationController alloc] init];
	detailNavController.viewControllers = newDetailViewControllers;
	return detailNavController;
}

@end
