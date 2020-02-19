//
//  AppDelegate.m
//  Hvezdarna
//
//  Created by Michal Zelinka in 2013
//  Copyright (c) 2013- Michal Zelinka. All rights reserved.
//

#import "AppDelegate.h"

#import "WeatherViewController.h"
#import "EventsListViewController.h"
#import "ProgramSplitViewController.h"
#import "AboutObservatoryViewController.h"

#import "ProgramList.h"


@interface AppDelegate () <UIApplicationDelegate, UITabBarControllerDelegate>

@property (nonatomic, strong) UITabBarController *tabBarController;

@end


#pragma mark - Implementation


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// Set Background Fetch interval
	[application setMinimumBackgroundFetchInterval:MAX(UIApplicationBackgroundFetchIntervalMinimum, 60*60*24)];

	self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];

	// Declare tabbed view controllers
	UIViewController *weather, *eventsList, *observatory;

	weather = [[WeatherViewController alloc] initWithNibName:@"WeatherViewController" bundle:nil];
	observatory = [[AboutObservatoryViewController alloc] initWithNibName:@"AboutObservatoryViewController" bundle:nil];
	eventsList = [[ProgramSplitViewController alloc] initWithNibName:@"ProgramSplitViewController" bundle:nil];

	_tabBarController = [[UITabBarController alloc] init];
	_tabBarController.delegate = self;
	_tabBarController.viewControllers = @[ weather, eventsList, observatory ];

	[[UITabBarItem appearance] setTitlePositionAdjustment:UIOffsetMake(0, -2)];

//	UIView *mask = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
//	mask.backgroundColor = [UIColor whiteColor];
//	mask.layer.cornerRadius = 4.0;
//	_tabBarController.view.layer.mask = mask.layer;

	[self refreshTabBarAppearance];

	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];

	self.window.rootViewController = _tabBarController;
	[self.window makeKeyAndVisible];

	return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application
	performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
	// Called irregularly to allow the application to fetch some update data in the background.

	ProgramList *list = [ProgramList sharedList];

	[list checkForUpdatesForce:YES completion:^(ProgramListUpdateResult result) {

		UIBackgroundFetchResult fetchResult = UIBackgroundFetchResultNoData;
		if (result == ProgramListUpdateResultNewData)
			fetchResult = UIBackgroundFetchResultNewData;
		if (result == ProgramListUpdateResultFailure)
			fetchResult = UIBackgroundFetchResultFailed;

		if (completionHandler)
			completionHandler(fetchResult);
	}];
}


#pragma mark - Tab bar actions

static UIViewAnimationOptions quickAnimation = UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState;

- (void)refreshTabBarAppearance
{
	static BOOL isInitialDraw = YES;

	CGFloat firstDelay = (isInitialDraw) ? .05:.12;

	BOOL isClear = [_tabBarController.selectedViewController isKindOfClass:[WeatherViewController class]];
	UITabBar *tabBar = _tabBarController.tabBar;

	[[UIApplication sharedApplication] setStatusBarStyle:(isClear) ? UIStatusBarStyleLightContent : UIStatusBarStyleDefault animated:YES];

	[UIView animateWithDuration:firstDelay delay:0 options:quickAnimation animations:^{

		tabBar.alpha = 0;

	} completion:^(BOOL f){

		[tabBar setBackgroundColor:(isClear) ? [UIColor clearColor] : [UIColor clearColor]];
		[tabBar setBackgroundImage:(isClear) ?  [UIImage new] : nil];
		tabBar.translucent = YES;
		[tabBar setShadowImage:(isClear) ? [UIImage new] : nil];
		[tabBar setTintColor:(isClear) ? [UIColor whiteColor] : [UIColor colorWithRed:53.0/255.0 green:165.0/255.0 blue:215.0/255.0 alpha:1.0]];
		[tabBar setBarTintColor:(isClear) ? [UIColor lightGrayColor] : [UIColor whiteColor]];

		[UIView animateWithDuration:firstDelay delay:0 options:quickAnimation animations:^{

			tabBar.alpha = 1;

		} completion:nil];
	}];

	isInitialDraw = NO;
}


#pragma mark - Tab bar delegate


- (void)tabBarController:(UITabBarController *)tabBarController
 didSelectViewController:(UIViewController *)viewController
{
	static UIViewController *lastViewController;

	if (!lastViewController ||
		[viewController isKindOfClass:[WeatherViewController class]] ||
		[lastViewController isKindOfClass:[WeatherViewController class]])
		[self refreshTabBarAppearance];

	lastViewController = viewController;
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController
shouldSelectViewController:(UIViewController *)viewController
{
	NSArray *tabViewControllers = tabBarController.viewControllers;
	UIView *fromView = tabBarController.selectedViewController.view;
	UIView *toView = viewController.view;

	if (fromView == toView) {
		id fromController = tabBarController.selectedViewController;
		UINavigationController *nc = ([fromController isKindOfClass:[UINavigationController class]]) ?
			fromController : nil;
		if (nc.viewControllers.count > 1)
			[nc popToRootViewControllerAnimated:YES];
		return NO;
	}

	NSUInteger toIndex = [tabViewControllers indexOfObject:viewController];

	[UIView transitionFromView:fromView toView:toView duration:0.3
		options:UIViewAnimationOptionTransitionCrossDissolve completion:^(BOOL finished) {
			if (finished)
				tabBarController.selectedIndex = toIndex;
	}];

	[UIView animateWithDuration:.12 delay:0 options:quickAnimation animations:^{
		self.window.transform = CGAffineTransformMakeScale(1.02, 1.02);
	} completion:^(BOOL finished) {
		[UIView animateWithDuration:.12 delay:0 options:quickAnimation animations:^{
			self.window.transform = CGAffineTransformIdentity;
		} completion:nil];
	}];

	return YES;
}


@end
