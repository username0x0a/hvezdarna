//
//  EventsListCellView.m
//  Hvezdarna
//
//  Created by Michal Zelinka in 2013
//  Copyright (c) 2013- Michal Zelinka. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "EventsListCellView.h"
#import "Event.h"
#import "Utils.h"


@implementation EventsListCellView

- (void)setEvent:(Event *)event
{
	_event = event;

	self.textLabel.text = event.title;
	self.detailTextLabel.text = [[event.shortDescription
		stringByReplacingOccurrencesOfString:@"\n" withString:@" "]
		stringByReplacingOccurrencesOfString:@"  " withString:@" "];
	self.timeLabel.text = [Utils getLocalTimeStringFromTimestamp:event.timestamp];

	self.selectionStyle = UITableViewCellSelectionStyleNone;
}

-(void)layoutSubviews
{
	[super layoutSubviews];

#if TARGET_OS_IOS == 1
	CGRect fr = self.textLabel.frame;
	fr.size.width = _timeLabel.left - fr.origin.x;
	self.textLabel.frame = fr;

	fr = self.detailTextLabel.frame;
	fr.size.width = _timeLabel.left - fr.origin.x;
	self.detailTextLabel.frame = fr;
#endif
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
#if TARGET_OS_IOS == 1
	self.backgroundColor = self.contentView.backgroundColor = (highlighted) ?
		[UIColor colorWithWhite:.4 alpha:.05] : [UIColor clearColor];
#else
	[super setHighlighted:highlighted animated:animated];
#endif
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
#if TARGET_OS_IOS == 1
	void (^perform)(void) = ^{
		self.backgroundColor = self.contentView.backgroundColor = (selected) ?
			[UIColor colorWithWhite:.4 alpha:.05] : [UIColor clearColor];
	};

	if (animated) [UIView animateWithDuration:.5 animations:perform];
	else perform();
#else
	[super setSelected:selected animated:animated];
#endif
}

@end
