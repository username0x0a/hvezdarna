//
//  ProgramDetailViewController.m
//  Hvezdarna
//
//  Created by Michal Zelinka in 2013
//  Copyright (c) 2013- Michal Zelinka. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ProgramDetailViewController.h"
#import "ProgramDetailCellView.h"
#import "Program.h"
#import "Utils.h"
#import "UIView+position.h"
#import "SplitViewBarButtonItemPresenter.h"
#import <SVModalWebViewController.h>

@implementation ProgramDetailViewController

@synthesize program = _program;
@synthesize description = _description;
@synthesize scroll_view = _scroll_view;

#pragma mark Initialization

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	self.splitViewController.delegate = self;
    return self;
}

#pragma mark View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title  = @"Představení";

	if (isIOS7)
	{
		self.navigationController.navigationBar.barTintColor =
			[UIColor colorWithWhite:1 alpha:.9];
		self.navigationController.navigationBar.tintColor = [UIColor colorWithWhite:.8 alpha:1];
		self.navigationController.navigationBar.titleTextAttributes = @{
			UITextAttributeTextColor: [UIColor lightGrayColor]
		};
		_scroll_view.contentInset = _scroll_view.scrollIndicatorInsets =
			UIEdgeInsetsMake(kUIStatusBarHeight+kUINavigationBarHeight, 0, kUITabBarHeight, 0);
	}
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
	if (!self.program) {
		[self.content_view setHidden:YES];
		return;
	}

	[self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Rezervace" style:UIBarButtonItemStyleBordered target:self action:@selector(openLink)]];
	[[self.navigationItem rightBarButtonItem] setEnabled:([self.program.link length] > 0)];

	[self.event_title setNumberOfLines:0];
	[self.event_title setFrame:CGRectMake(20, 12, 280, 31)];
	[self.event_title setText:[self.program title]];
	[self.event_title sizeToFit];
	
	[self.date setText:[Utils getLocalDateStringFromTimestamp:[self.program day]]];
	[self.price setText:[Utils getLocalMoneyValueFromString:[self.program price]]];
	[self.time setText:[Utils getLocalTimeStringFromTimestamp:[self.program timestamp]]];
	_info_view.top = _event_title.bottom+2.0f;

	_description.textAlignment = RTTextAlignmentJustify;
	_description.textColor = [UIColor colorWithWhite:144/255.0 alpha:1];
	_description.font = [UIFont systemFontOfSize:17];
	_description.text = _program.description;
	_description.lineSpacing = -1;
	_description.size = _description.optimumSize;
	_details_view.top = _info_view.bottom+4.0f;
	
	// Clear old custom fields
	for (UIView* view in [self.details_view subviews])
		if ([view isKindOfClass:[ProgramDetailCellView class]])
			[view removeFromSuperview];
	
	int last_option_bottom = _description.bottom+16.0f;
	for (NSString *option in [self.program opts])
	{
		UINib *nibForCells = [UINib nibWithNibName:@"ProgramDetailCellView" bundle:nil];
		NSArray *topLevelObjects = [nibForCells instantiateWithOwner:self options:nil];
		ProgramDetailCellView *cell = [topLevelObjects objectAtIndex:0];
		if ([option rangeOfString:@": "].location == NSNotFound)
			[cell setTextOfDetail:option];
		else {
			NSString *val = [option stringByReplacingOccurrencesOfString:@": " withString:@" je "];
			[cell setTextOfDetail:val];
		}
		[cell setWidth:[self.details_view width]];
		[self.details_view addSubview:cell];
		[cell setTop:last_option_bottom];
		last_option_bottom = [cell bottom];
	}
	[self.details_view setHeight:last_option_bottom];
	
    // set the content size to be the size our our whole frame
    [self.scroll_view setContentSize:CGSizeMake(self.view.frame.size.width, self.details_view.frame.origin.y+self.details_view.frame.size.height + 10)];
    // then set frame to be the size of the view's frame
    self.scroll_view.frame = self.view.frame;
}

- (void) viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	[[self view] removeFromSuperview];
}

#pragma mark Other View-related

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Functions

- (void)setProgram:(Program *)program
{
    _program = program;
}

- (void)openLink
{
	SVModalWebViewController *vc = [[SVModalWebViewController alloc]
									initWithURL:[NSURL URLWithString:_program.link]];
	if (isIPad()) vc.modalPresentationStyle = UIModalPresentationPageSheet;
	[self.tabBarController presentViewController:vc animated:YES completion:nil];
}

#pragma mark Split View Delegate

- (id <SplitViewBarButtonItemPresenter>)splitViewBarButtonItemPresenter
{
    id detailVC = [self.splitViewController.viewControllers lastObject];
    if (![detailVC conformsToProtocol:@protocol(SplitViewBarButtonItemPresenter)]) {
        detailVC = nil;
    }
    return detailVC;
}

- (BOOL)splitViewController:(UISplitViewController *)svc
   shouldHideViewController:(UIViewController *)vc
              inOrientation:(UIInterfaceOrientation)orientation
{
    return [self splitViewBarButtonItemPresenter] ? UIInterfaceOrientationIsPortrait(orientation) : NO;
}

- (void)splitViewController:(UISplitViewController *)svc
     willHideViewController:(UIViewController *)aViewController
          withBarButtonItem:(UIBarButtonItem *)barButtonItem
       forPopoverController:(UIPopoverController *)pc
{
    barButtonItem.title = self.title;
    [self splitViewBarButtonItemPresenter].splitViewBarButtonItem = barButtonItem;
}

- (void)splitViewController:(UISplitViewController *)svc
     willShowViewController:(UIViewController *)aViewController
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    [self splitViewBarButtonItemPresenter].splitViewBarButtonItem = nil;
}

@end
