//
//  ProgramSectionView.m
//  Hvezdarna
//
//  Created by Michal Zelinka in 2013
//  Copyright (c) 2013- Michal Zelinka. All rights reserved.
//

#import "ProgramSectionView.h"
#import "UIView+position.h"


@implementation ProgramSectionView

- (id)initWithFrame:(CGRect)frame
{
	if (self = [super initWithFrame:frame])
	{
		self.backgroundColor = [UIColor colorWithWhite:.9f alpha:.9f];

		_title = [[UILabel alloc] initWithFrame:self.bounds];
		_title.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_title.textAlignment = NSTextAlignmentCenter;
		_title.backgroundColor = [UIColor clearColor];
		_title.textColor = [UIColor lightGrayColor];
		_title.font = [UIFont boldSystemFontOfSize:14.0];
		_title.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
		[self addSubview:_title];
	}

	return self;
}

- (void)setTitleText:(NSString *)text
{
	if (!text.length) _title.text = text;
	if (!text.length) return;

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
