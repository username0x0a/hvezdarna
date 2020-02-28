//
//  EventDetailCellView.m
//  Hvezdarna
//
//  Created by Michal Zelinka in 2013
//  Copyright (c) 2013- Michal Zelinka. All rights reserved.
//

#import "EventDetailCellView.h"
#import "UIView+position.h"
#import <QuartzCore/QuartzCore.h>

@interface EventDetailCellView ()
@end

@implementation EventDetailCellView

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:nil])
	{
		[self.textLabel removeFromSuperview];
		[self.detailTextLabel removeFromSuperview];
	}

	return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{}

- (void)setTextOfDetail:(NSString *)text
{
	_detailText.text = text;

	// Adjust the label the the new height.
	_detailText.height = _detailText.expandedSize.height;
	self.height = _detailText.height+2*13.0f;
	[_detailText centerVerticallyInSuperview];
}

@end
