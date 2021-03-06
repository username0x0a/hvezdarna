//
//  AboutObservatoryViewController.m
//  Hvezdarna
//
//  Created by Michal Zelinka in 2013
//  Copyright (c) 2013- Michal Zelinka. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#if !TARGET_OS_TV
#import <SafariServices/SafariServices.h>
#endif

#import "AboutObservatoryViewController.h"
#import "Utils.h"

#import <objc/runtime.h>


@implementation AboutObservatoryViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
	{
		self.title = @"O hvězdárně";
		self.tabBarItem.image = [UIImage imageNamed:@"tab-about"];
	}

	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];

#if TARGET_OS_IOS == 1
	object_setClass(_textContentView, [MaskAutoAdjustingView class]);

#define C(a) ((id)[UIColor colorWithWhite:1.0 alpha:a].CGColor)

	CAGradientLayer *l = [CAGradientLayer layer];
	l.frame = _textContentView.bounds;
	l.colors = @[ C(0), C(1), C(1), C(0) ];
	l.locations = @[ @0.0f, @(16/l.frame.size.height), @((l.frame.size.height-16)/l.frame.size.height), @1.0f ];
	l.startPoint = CGPointMake(0.5f, 0.0f);
	l.endPoint = CGPointMake(0.5f, 1.0f);
	_textContentView.layer.mask = l;
#endif
}

- (void)viewDidLayoutSubviews
{
	[super viewDidLayoutSubviews];

#if TARGET_OS_IOS == 1
	CGFloat width = self.view.width;
	CGFloat height = _webButton.top - _logoView.bottom - 2*17;

	if (width > 500) width = 486;
	else width -= 2*17;

	_textContentView.width = width;
	[_textContentView centerHorizontallyInSuperview];

	_textContentView.height = height;
	_textContentView.top = _logoView.bottom + 17;
#endif
}

- (IBAction)webButtonTapped:(id)sender
{
#if !TARGET_OS_TV
	SFSafariViewController *vc = [[SFSafariViewController alloc]
		initWithURL:[NSURL URLWithString:@"http://hvezdarna.cz/"]];
	vc.modalPresentationStyle = UIModalPresentationPageSheet;
	[self presentViewController:vc animated:YES completion:nil];
#endif
}

@end
