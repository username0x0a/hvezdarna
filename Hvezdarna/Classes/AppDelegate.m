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
#import "EventsSplitViewController.h"
#import "AboutObservatoryViewController.h"

#import "EventsList.h"


@interface MSTabBarController: UITabBarController

@property (nonatomic, copy) void (^appearanceUpdateHandler)(void);

@end

@implementation MSTabBarController

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection
{
	[super traitCollectionDidChange:previousTraitCollection];
#if TARGET_OS_TV == 1
	__auto_type block = _appearanceUpdateHandler;
	if (block) block();
#endif
}

@end

@interface AppDelegate () <UIApplicationDelegate, UITabBarControllerDelegate>

@property (nonatomic, strong) MSTabBarController *tabBarController;

@end


#pragma mark - Implementation


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
	didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// Set Background Fetch interval
	[application setMinimumBackgroundFetchInterval:
		MAX(UIApplicationBackgroundFetchIntervalMinimum, 60*60*24)];

	self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];

	// Declare tabbed view controllers
	UIViewController *weather, *eventsList, *about;

	weather = [[WeatherViewController alloc] initWithNibName:
	           @"WeatherViewController" bundle:nil];
	eventsList = [[EventsSplitViewController alloc] initWithNibName:
	           @"EventsSplitViewController" bundle:nil];
	about = [[AboutObservatoryViewController alloc] initWithNibName:
	           @"AboutObservatoryViewController" bundle:nil];

	__weak typeof(self) wself = self;

	_tabBarController = [MSTabBarController new];
	_tabBarController.delegate = self;
	_tabBarController.viewControllers = @[ weather, eventsList, about ];
	_tabBarController.appearanceUpdateHandler = ^{
		[wself refreshTabBarAppearance];
	};

#if !TARGET_OS_TV
	[[UITabBarItem appearance] setTitlePositionAdjustment:UIOffsetMake(0, -2)];
#endif

	[self refreshTabBarAppearance];

#if !TARGET_OS_TV
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
#endif

#if TARGET_OS_TV == 1
	self.window.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Default-bg"]];
#endif
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

	[[EventsList sharedList] checkForUpdates];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application
	performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
	// Called irregularly to allow the application to fetch some update data in the background.

	EventsList *list = [EventsList sharedList];

	[list checkForUpdatesForce:YES completion:^(EventsListUpdateResult result) {

		UIBackgroundFetchResult fetchResult = UIBackgroundFetchResultNoData;
		if (result == EventsListUpdateResultNewData)
			fetchResult = UIBackgroundFetchResultNewData;
		if (result == EventsListUpdateResultFailure)
			fetchResult = UIBackgroundFetchResultFailed;

		if (completionHandler)
			completionHandler(fetchResult);
	}];
}


#pragma mark - Tab bar actions


static UIViewAnimationOptions quickAnimation =
	UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState;

- (void)refreshTabBarAppearance
{
	static BOOL isInitialDraw = YES;

	UIViewController *controller = _tabBarController.selectedViewController;
	BOOL isWeatherScreen = [controller isKindOfClass:[WeatherViewController class]];
	BOOL darkScreen = isWeatherScreen;

	if (@available(iOS 13.0, tvOS 13.0, *)) {
		darkScreen = darkScreen || controller.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark;
	}

	UITabBar *tabBar = _tabBarController.tabBar;

#if !TARGET_OS_TV

	BOOL transparentTabBar = isWeatherScreen;
	CGFloat firstDelay = (isInitialDraw) ? .05:.12;

	[UIView animateWithDuration:firstDelay delay:0 options:quickAnimation animations:^{

		tabBar.alpha = 0;

	} completion:^(BOOL f) {

		static UIColor *st_backColor = nil;
		static UIColor *st_btntColor = nil;
		static UIImage *st_backImage = nil;
		static UIImage *st_shadImage = nil;

		if (isInitialDraw) {
			st_backColor = tabBar.backgroundColor;
			st_btntColor = tabBar.barTintColor;
			st_backImage = tabBar.backgroundImage;
			st_shadImage = tabBar.shadowImage;
		}

		tabBar.backgroundColor = (transparentTabBar) ? [UIColor clearColor] : st_backColor;
		tabBar.backgroundImage = (transparentTabBar) ?  [UIImage new] : st_backImage;
		tabBar.translucent = YES;
		tabBar.shadowImage = (transparentTabBar) ? [UIImage new] : st_shadImage;
		tabBar.tintColor = (isWeatherScreen) ?
			[UIColor whiteColor] : [UIColor colorWithRed:53.0/255.0 green:165.0/255.0 blue:215.0/255.0 alpha:1.0];
		tabBar.barTintColor = (isWeatherScreen) ?
			[UIColor lightGrayColor] : st_btntColor;

		[UIView animateWithDuration:firstDelay delay:0 options:quickAnimation animations:^{

			tabBar.alpha = 1;

		} completion:nil];
	}];

#else

	if (@available(tvOS 13.0, *)) {

		tabBar.backgroundImage = (darkScreen) ?  [UIImage new] : nil;

		UITabBarAppearance *appearance = [UITabBarAppearance new];

		appearance.backgroundColor = [UIColor colorWithWhite:1 alpha:(darkScreen) ? 0.1:0.3];
		appearance.selectionIndicatorTintColor = [UIColor whiteColor];

		UIColor *color = (darkScreen) ? [UIColor whiteColor] : [UIColor darkGrayColor];
		appearance.stackedLayoutAppearance.normal.iconColor = color;
		appearance.stackedLayoutAppearance.normal.titleTextAttributes = @{
			NSForegroundColorAttributeName: color };

		color = [UIColor darkGrayColor];
		appearance.stackedLayoutAppearance.selected.iconColor = color;
		appearance.stackedLayoutAppearance.selected.titleTextAttributes = @{
			NSForegroundColorAttributeName: color };
		appearance.stackedLayoutAppearance.focused.iconColor = color;
		appearance.stackedLayoutAppearance.focused.titleTextAttributes = @{
			NSForegroundColorAttributeName: color };

		appearance.inlineLayoutAppearance = appearance.stackedLayoutAppearance;
		appearance.compactInlineLayoutAppearance = appearance.stackedLayoutAppearance;

		[UIView transitionWithView:tabBar duration:2.0 options:quickAnimation animations:^{
			tabBar.standardAppearance = appearance;
		} completion:nil];

	}

#endif

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

#if !TARGET_OS_TV

	NSArray *tabViewControllers = tabBarController.viewControllers;
	NSUInteger toIndex = [tabViewControllers indexOfObject:viewController];

	[UIView transitionFromView:fromView toView:toView duration:0.3
		options:UIViewAnimationOptionTransitionCrossDissolve completion:^(BOOL finished) {
			if (finished)
				tabBarController.selectedIndex = toIndex;
	}];

#endif

#if !TARGET_OS_TV

	[UIView animateWithDuration:.12 delay:0 options:quickAnimation animations:^{
		self.window.transform = CGAffineTransformMakeScale(1.02, 1.02);
	} completion:^(BOOL finished) {
		[UIView animateWithDuration:.12 delay:0 options:quickAnimation animations:^{
			self.window.transform = CGAffineTransformIdentity;
		} completion:nil];
	}];

#endif

	return YES;
}

@end
