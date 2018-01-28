//
//  ProgramCellView.m
//  Hvezdarna
//
//  Created by Michal Zelinka in 2013
//  Copyright (c) 2013- Michal Zelinka. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ProgramCellView.h"
#import "Program.h"
#import "Utils.h"


@implementation ProgramCellView

- (void)setProgram:(Program *)program
{
    _program = program;
	_title.text = program.title;
	_descriptionLabel.text = [program.shortDescription
		stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
	_time.text = [Utils getLocalTimeStringFromTimestamp:program.timestamp];
	self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
	self.backgroundColor = self.contentView.backgroundColor = (highlighted) ?
		[UIColor colorWithWhite:.96 alpha:1] : [UIColor whiteColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
	void (^perform)(void) = ^{
		self.backgroundColor = self.contentView.backgroundColor = (selected) ?
		[UIColor colorWithWhite:.96 alpha:1] : [UIColor whiteColor];
	};

	if (animated) [UIView animateWithDuration:.5 animations:perform];
	else perform();
}

@end
