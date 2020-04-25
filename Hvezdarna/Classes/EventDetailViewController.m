//
//  EventDetailViewController.m
//  Hvezdarna
//
//  Created by Michal Zelinka in 2013
//  Copyright (c) 2013- Michal Zelinka. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#if !TARGET_OS_TV
#import <SafariServices/SafariServices.h>
#endif

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

#if !TARGET_OS_TV
	self.title = @"Představení";

	self.navigationController.navigationBar.barTintColor =
		[UIColor colorWithWhite:1 alpha:.9];
	self.navigationController.navigationBar.tintColor = [UIColor colorWithWhite:.72 alpha:1];
	self.navigationController.navigationBar.titleTextAttributes = @{
		NSForegroundColorAttributeName: [UIColor colorWithWhite:.46 alpha:1]
	};
#else
	UIEdgeInsets insets = UIEdgeInsetsMake(15, 0, 10, 0);
	_shortDescription.textContainerInset = insets;
	_longDescription.textContainerInset = insets;
	_shortDescription.textContainer.lineFragmentPadding = 0;
	_longDescription.textContainer.lineFragmentPadding = 0;
#endif
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];

#if !TARGET_OS_TV
	self.navigationController.navigationBar.barTintColor =
		[UIColor colorWithWhite:1 alpha:.9];
	self.navigationController.navigationBar.tintColor = [UIColor colorWithWhite:.72 alpha:1];
	self.navigationController.navigationBar.titleTextAttributes = @{
		NSForegroundColorAttributeName: [UIColor colorWithWhite:.46 alpha:1]
	};
#endif
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

#if !TARGET_OS_TV
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Rezervace"
		style:UIBarButtonItemStylePlain target:self action:@selector(openLink)];
	self.navigationItem.rightBarButtonItem.enabled = _event.link.length > 0;
#endif

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
	BOOL wide = width >= 600;

	CGFloat fontSize = (wide) ? 29:26;
#if TARGET_OS_TV == 1
	width = _scrollView.width - _scrollView.layoutMargins.left - _scrollView.layoutMargins.right - _scrollView.contentInset.left - _scrollView.contentInset.right;
	fontSize = 64;
#endif

	_eventTitle.font = [_eventTitle.font fontWithSize:fontSize];
	_eventTitle.text = _event.title;
	_eventTitle.width = width;
	_eventTitle.height = _eventTitle.expandedSize.height;

	_date.text = [Utils getLocalDateStringFromTimestamp:_event.day];
	_time.text = [Utils getLocalTimeStringFromTimestamp:_event.timestamp];
	_price.text = [Utils getLocalMoneyValueFromString:_event.price];

	_infoView.top = _eventTitle.bottom+2.0f;
	_infoView.width = width;

	_shortDescription.text = _event.shortDescription ?: @"";
	_shortDescription.accessibilityLabel = _event.shortDescription;

	_longDescription.text = _event.longDescription ?: @"";
	_longDescription.accessibilityLabel = _event.longDescription;

	NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
	paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
	paragraphStyle.lineSpacing = -2;
	paragraphStyle.alignment = NSTextAlignmentJustified;

	fontSize = (wide) ? 20:18;
#if TARGET_OS_TV == 1
	fontSize = 36;
#endif

	NSAttributedString *attrShortDescription = [[NSAttributedString alloc]
		initWithString:_shortDescription.text attributes:@{
			NSParagraphStyleAttributeName: paragraphStyle,
			NSFontAttributeName: [_shortDescription.font fontWithSize:fontSize],
			NSForegroundColorAttributeName: [UIColor colorWithWhite:94/255.0 alpha:1]
		}];

#if !TARGET_OS_TV
	fontSize = (wide) ? 18:16;
#endif

	NSAttributedString *attrDescription = [[NSAttributedString alloc]
		initWithString:_longDescription.text attributes:@{
			NSParagraphStyleAttributeName: paragraphStyle,
			NSFontAttributeName: [_longDescription.font fontWithSize:fontSize],
			NSForegroundColorAttributeName: [UIColor colorWithWhite:94/255.0 alpha:1]
		}];

	_detailsView.width = width;

	_shortDescription.attributedText = attrShortDescription;
	_shortDescription.width = width;
	_shortDescription.height = _shortDescription.expandedSize.height;

	_longDescription.attributedText = attrDescription;
	_longDescription.width = width;
	_longDescription.top = _shortDescription.bottom+4.0f;
	_longDescription.height = _longDescription.expandedSize.height;
	_detailsView.top = _infoView.bottom;
	_detailsView.height = _longDescription.bottom;

	// Clear old custom fields
	for (UIView *view in _detailsView.subviews)
		if ([view isKindOfClass:[EventDetailCellView class]])
			[view removeFromSuperview];

	int currentY = _detailsView.bottom+16.0f;
#if !TARGET_OS_TV
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
#endif
	_detailsView.height = currentY;

#if TARGET_OS_TV
	CGFloat margin = 80;
#else
	CGFloat margin = 14;
#endif

	// Set the content size to be the size our our whole frame
	_scrollView.contentSize = CGSizeMake(_scrollView.width, _detailsView.bottom + margin);

#if TARGET_OS_TV

	for (UIView *v in _scrollView.subviews)
		if (v.tag == 1234)
			[v removeFromSuperview];

	NSUInteger total = 0;
	if (_scrollView.contentSize.height > _scrollView.height)
		total = ceil(_scrollView.contentSize.height / _scrollView.height) + 1;
	if (total)
		for (NSUInteger i = 0; i < total; i++) {
			UIButton *b = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
//			b.alpha = 0;
			b.tag = 1234;
			b.top = _scrollView.height * i;
			[_scrollView addSubview:b];
			b.fromTrailingEdge = 0;
		}

#endif
}


#pragma mark - Actions


- (void)openLink
{
#if !TARGET_OS_TV
	SFSafariViewController *vc = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:_event.link]];
	vc.modalPresentationStyle = UIModalPresentationPageSheet;
	[self.tabBarController presentViewController:vc animated:YES completion:nil];
#endif
}

@end
