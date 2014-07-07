//
//  UIScrollView+AutoContentSize.m
//  Hvezdarna
//
//  Created by Michal Zelinka in 2013
//  Copyright (c) 2013- Michal Zelinka. All rights reserved.
//

#import "UIScrollView+AutoContentSize.h"

@implementation UIScrollView (AutoContentSize)

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    return self;
}

- (void) setAutosizeContent:(BOOL)autosizeContent {
	
    if (autosizeContent) {
        CGFloat contentWidth =
		self.frame.size.width == self.superview.frame.size.width ?
		self.superview.frame.size.width :
		self.frame.size.width;
        CGFloat contentHeight =
		self.frame.size.height == self.superview.frame.size.height ?
		self.superview.frame.size.height :
		self.frame.size.height;
        self.contentSize = CGSizeMake(contentWidth, contentHeight);
    }
}

@end
