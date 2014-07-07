//
//  ProgramDetailCellView.m
//  Hvezdarna
//
//  Created by Michal Zelinka in 2013
//  Copyright (c) 2013- Michal Zelinka. All rights reserved.
//

#import "ProgramDetailCellView.h"
#import "UIView+position.h"
#import <QuartzCore/QuartzCore.h>

@interface ProgramDetailCellView ()
@end

@implementation ProgramDetailCellView

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    return (self = [super init]);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{}

- (void) setTextOfDetail:(NSString *)text
{
	_detailText.text = text;
	CGSize expectedLabelSize = [text sizeWithFont:_detailText.font
								constrainedToSize:CGSizeMake(_detailText.width, 9999)
									lineBreakMode:_detailText.lineBreakMode];
	
	// Adjust the label the the new height.
	_detailText.height = expectedLabelSize.height;
	self.height = _detailText.height+26.0f;
	[_detailText centerVerticallyInSuperview];
}

@end
