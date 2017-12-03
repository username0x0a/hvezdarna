//
//  EventDetailViewController.m
//  Hvezdarna
//
//  Created by Michal Zelinka in 2013
//  Copyright (c) 2013- Michal Zelinka. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "EventDetailViewController.h"
#import "ProgramDetailCellView.h"
#import "Program.h"
#import "Utils.h"
#import "UIView+position.h"
#import "SplitViewBarButtonItemPresenter.h"
#import <SVModalWebViewController.h>


@implementation EventDetailViewController


#pragma mark - Initialization


- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
		self.splitViewController.delegate = self;

	return self;
}


#pragma mark - View Lifecycle


- (void)viewDidLoad
{
	[super viewDidLoad];

	self.title = @"Představení";

	if (isUltraWidescreen())
		_eventTitle.font = [_eventTitle.font fontWithSize:_eventTitle.font.pointSize+3];

	self.navigationController.navigationBar.barTintColor =
		[UIColor colorWithWhite:1 alpha:.9];
	self.navigationController.navigationBar.tintColor = [UIColor colorWithWhite:.72 alpha:1];
	self.navigationController.navigationBar.titleTextAttributes = @{
		NSForegroundColorAttributeName: [UIColor colorWithWhite:.46 alpha:1]
	};
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];

	self.navigationController.navigationBar.barTintColor =
		[UIColor colorWithWhite:1 alpha:.9];
	self.navigationController.navigationBar.tintColor = [UIColor colorWithWhite:.72 alpha:1];
	self.navigationController.navigationBar.titleTextAttributes = @{
		NSForegroundColorAttributeName: [UIColor colorWithWhite:.46 alpha:1]
	};
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.navigationController setNavigationBarHidden:NO animated:YES];

	if (!_program) {
		[_scrollView setHidden:YES];
		return;
	}

	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Rezervace" style:UIBarButtonItemStyleBordered target:self action:@selector(openLink)];
	self.navigationItem.rightBarButtonItem.enabled = _program.link.length > 0;

	_eventTitle.numberOfLines = 0;
	_eventTitle.frame = CGRectMake(20, 12, 280, 31);
	_eventTitle.text = _program.title;
	[_eventTitle sizeToFit];

	_date.text = [Utils getLocalDateStringFromTimestamp:_program.day];
	_price.text = [Utils getLocalMoneyValueFromString:_program.price];
	_time.text = [Utils getLocalTimeStringFromTimestamp:_program.timestamp];
	_infoView.top = _eventTitle.bottom+2.0f;

    _shortDescription.text = _program.shortDescription;
    _shortDescription.accessibilityLabel = _program.shortDescription;

	_longDescription.text = _program.longDescription;
	_longDescription.accessibilityLabel = _program.longDescription;

	NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
	paragraphStyle.lineSpacing = -2;
    paragraphStyle.alignment = NSTextAlignmentJustified;

	NSAttributedString *attrShortDescription = [[NSAttributedString alloc]
		initWithString:_shortDescription.text attributes:@{
			NSParagraphStyleAttributeName: paragraphStyle,
			NSFontAttributeName: [_shortDescription.font fontWithSize:17],
			NSForegroundColorAttributeName: [UIColor colorWithWhite:94/255.0 alpha:1]
		}];

	NSAttributedString *attrDescription = [[NSAttributedString alloc]
        initWithString:_longDescription.text attributes:@{
            NSParagraphStyleAttributeName: paragraphStyle,
            NSFontAttributeName: [_longDescription.font fontWithSize:17],
            NSForegroundColorAttributeName: [UIColor colorWithWhite:94/255.0 alpha:1]
        }];

	_shortDescription.attributedText = attrShortDescription;
	_shortDescription.height = [_shortDescription sizeThatFits:CGSizeMake(_shortDescription.width, INT_MAX)].height;

	_longDescription.attributedText = attrDescription;
    _longDescription.top = _shortDescription.bottom+4.0f;
	_longDescription.height = [_longDescription sizeThatFits:CGSizeMake(_longDescription.width, INT_MAX)].height;

	_detailsView.top = _infoView.bottom;

	// Clear old custom fields
	for (UIView* view in _detailsView.subviews)
		if ([view isKindOfClass:[ProgramDetailCellView class]])
			[view removeFromSuperview];

	int currentY = _longDescription.bottom+16.0f;
	for (NSString *option in _program.opts)
	{
		UINib *nibForCells = [UINib nibWithNibName:@"ProgramDetailCellView" bundle:nil];
		NSArray *topLevelObjects = [nibForCells instantiateWithOwner:self options:nil];
		ProgramDetailCellView *cell = [topLevelObjects objectAtIndex:0];
		NSString *val = [option stringByReplacingOccurrencesOfString:@": " withString:@" je "];
		[cell setTextOfDetail:val];
		cell.width = _detailsView.width;
		[_detailsView addSubview:cell];
		cell.top = currentY;
		currentY = cell.bottom;
	}
	_detailsView.height = currentY;

    // set the content size to be the size our our whole frame
	_scrollView.contentSize = CGSizeMake(self.view.width, _detailsView.bottom + 10);
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}


#pragma mark - Other View-related


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Actions


- (void)openLink
{
	SVModalWebViewController *vc = [[SVModalWebViewController alloc]
		initWithURL:[NSURL URLWithString:_program.link]];
	if (isIPad()) vc.modalPresentationStyle = UIModalPresentationPageSheet;
	vc.barsTintColor = [UIColor colorWithRed:53.0/255.0 green:165.0/255.0 blue:215.0/255.0 alpha:1.0];
	[self.tabBarController presentViewController:vc animated:YES completion:nil];
}


#pragma mark - Split View Delegate


- (id <SplitViewBarButtonItemPresenter>)splitViewBarButtonItemPresenter
{
    id detailVC = [self.splitViewController.viewControllers lastObject];
    if (![detailVC conformsToProtocol:@protocol(SplitViewBarButtonItemPresenter)])
        detailVC = nil;

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
