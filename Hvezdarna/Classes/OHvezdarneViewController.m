//
//  OHvezdarneViewController.m
//  Hvezdarna
//
//  Created by Michal Zelinka in 2013
//  Copyright (c) 2013- Michal Zelinka. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "OHvezdarneViewController.h"
#import "Utils.h"

#import "SVWebViewController.h"
#import <objc/runtime.h>

@class MaskAutoAdjustingView;


@implementation OHvezdarneViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
	{
		self.title = @"O hvězdárně";
		self.tabBarItem.image = [UIImage imageNamed:@"about"];
	}

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	object_setClass(_textContentView, [MaskAutoAdjustingView class]);

#define C(a) ((id)[UIColor colorWithWhite:1.0 alpha:a].CGColor)

	CAGradientLayer *l = [CAGradientLayer layer];
	l.frame = _textContentView.bounds;
	l.colors = @[ C(0), C(1), C(1), C(0) ];
	l.locations = @[ @0.0f, @(16/l.frame.size.height), @((l.frame.size.height-16)/l.frame.size.height), @1.0f ];
	l.startPoint = CGPointMake(0.5f, 0.0f);
	l.endPoint = CGPointMake(0.5f, 1.0f);
	_textContentView.layer.mask = l;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
		return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
	else if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
		return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);

	return NO;
}

- (IBAction)webButtonTapped:(id)sender
{
	SVModalWebViewController *vc = [[SVModalWebViewController alloc]
		initWithURL:[NSURL URLWithString:@"http://hvezdarna.cz/"]];
	if (isIPad()) vc.modalPresentationStyle = UIModalPresentationPageSheet;
	[self presentViewController:vc animated:YES completion:nil];
}

@end
