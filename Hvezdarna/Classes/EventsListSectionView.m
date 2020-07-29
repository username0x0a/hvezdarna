//
//  EventsListSectionView.m
//  Hvezdarna
//
//  Created by Michal Zelinka in 2013
//  Copyright (c) 2013- Michal Zelinka. All rights reserved.
//

#import "EventsListSectionView.h"
#import "UIView+position.h"


@implementation EventsListSectionView

- (id)initWithFrame:(CGRect)frame
{
	if (self = [super initWithFrame:frame])
	{
		self.backgroundColor = [UIColor colorWithWhite:.9f alpha:.9f];

		if (@available(iOS 11.0, *)) {
			self.backgroundColor = [UIColor colorNamed:@"table-header-background"];
		}

		CGFloat sepLine = 1.0 / [UIScreen mainScreen].scale;

		for (int i = 0; i < 2; i++) {
			UIView *line = [[UIView alloc] initWithFrame:self.bounds];
			line.height = sepLine;
			line.backgroundColor = [UIColor colorWithWhite:.65f alpha:.7f];
			line.autoresizingMask = (i) ? UIViewAutoresizingFlexibleTopMargin : UIViewAutoresizingFlexibleBottomMargin;
			line.autoresizingMask |= UIViewAutoresizingFlexibleWidth;
			[self addSubview:line];
			if (i) line.top = self.height;
		}

		_title = [[UILabel alloc] initWithFrame:self.bounds];
		_title.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_title.textAlignment = NSTextAlignmentCenter;
		_title.backgroundColor = [UIColor clearColor];
		_title.textColor = [UIColor lightGrayColor];
		_title.font = [UIFont boldSystemFontOfSize:15.0];
		_title.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
		[self addSubview:_title];
	}

	return self;
}

- (void)setTitleText:(NSString *)text
{
	text = text ?: @"";

	NSAttributedString *attrText = [[NSAttributedString alloc]
	initWithString:text attributes:@{
		NSForegroundColorAttributeName: _title.textColor,
		NSBackgroundColorAttributeName: _title.backgroundColor,
		NSFontAttributeName: _title.font,
		NSKernAttributeName: @1,
	}];

	_title.attributedText = attrText;
}

@end
