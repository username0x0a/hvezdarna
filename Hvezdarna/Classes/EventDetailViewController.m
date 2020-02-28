//
//  EventDetailViewController.m
//  Hvezdarna
//
//  Created by Michal Zelinka in 2013
//  Copyright (c) 2013- Michal Zelinka. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <SafariServices/SafariServices.h>

#import "EventDetailViewController.h"
#import "EventDetailCellView.h"
#import "Event.h"
#import "Utils.h"
#import "UIView+position.h"


@implementation EventDetailViewController


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

	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Rezervace"
		style:UIBarButtonItemStylePlain target:self action:@selector(openLink)];
	self.navigationItem.rightBarButtonItem.enabled = _event.link.length > 0;

	[self recalculateContent];
}

- (void)viewDidLayoutSubviews
{
	[super viewDidLayoutSubviews];
	[self recalculateContent];
}

- (void)recalculateContent
{
	CGFloat width = self.view.width - 2*20;

	_eventTitle.numberOfLines = 0;
	_eventTitle.text = _event.title;
	_eventTitle.width = width;
	_eventTitle.height = [_eventTitle sizeThatFits:CGSizeMake(width, CGFLOAT_MAX)].height;

	_date.text = [Utils getLocalDateStringFromTimestamp:_event.day];
	_price.text = [Utils getLocalMoneyValueFromString:_event.price];
	_time.text = [Utils getLocalTimeStringFromTimestamp:_event.timestamp];
	_infoView.width = width;
	_infoView.top = _eventTitle.bottom+2.0f;

    _shortDescription.text = _event.shortDescription;
    _shortDescription.accessibilityLabel = _event.shortDescription;

	_longDescription.text = _event.longDescription;
	_longDescription.accessibilityLabel = _event.longDescription;

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

	_detailsView.width = width;

	_shortDescription.attributedText = attrShortDescription;
	_shortDescription.width = width;
	_shortDescription.height = [_shortDescription sizeThatFits:CGSizeMake(_shortDescription.width, INT_MAX)].height;

	_longDescription.attributedText = attrDescription;
	_longDescription.width = width;
    _longDescription.top = _shortDescription.bottom+4.0f;
	_longDescription.height = [_longDescription sizeThatFits:CGSizeMake(_longDescription.width, INT_MAX)].height;

	_detailsView.top = _infoView.bottom;

	// Clear old custom fields
	for (UIView *view in _detailsView.subviews)
		if ([view isKindOfClass:[EventDetailCellView class]])
			[view removeFromSuperview];

	int currentY = _longDescription.bottom+16.0f;
	for (NSString *option in _event.opts)
	{
		UINib *nibForCells = [UINib nibWithNibName:@"EventDetailCellView" bundle:nil];
		NSArray *topLevelObjects = [nibForCells instantiateWithOwner:self options:nil];
		EventDetailCellView *cell = [topLevelObjects objectAtIndex:0];
		cell.width = _detailsView.width;
		NSString *val = [option stringByReplacingOccurrencesOfString:@": " withString:@" je "];
		[cell setTextOfDetail:val];
		[_detailsView addSubview:cell];
		cell.top = currentY;
		currentY = cell.bottom;
	}
	_detailsView.height = currentY;

	// Set the content size to be the size our our whole frame
	_scrollView.contentSize = CGSizeMake(self.view.width, _detailsView.bottom + 14);
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
	SFSafariViewController *vc = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:_event.link]];
	vc.modalPresentationStyle = UIModalPresentationPageSheet;
	[self.tabBarController presentViewController:vc animated:YES completion:nil];
}

@end
