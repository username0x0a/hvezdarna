//
//  ProgramCellView.m
//  Hvezdarna
//
//  Created by Michal Zelinka in 2013
//  Copyright (c) 2013- Michal Zelinka. All rights reserved.
//

#import "ProgramCellView.h"
#import "Program.h"
#import "Utils.h"
#import <QuartzCore/QuartzCore.h>


@implementation ProgramCellView

- (void)setProgram:(Program *)program
{
    _program = program;
	self.title.text = program.title;
	self.description.text = program.description;
	self.time.text = [Utils getLocalTimeStringFromTimestamp:program.timestamp];
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

//- (void)drawRect:(CGRect)rect
//{
//    [super drawRect:rect];
//    
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    
//    if (self.highlighted != YES)
//    {
//        
//        // Create a gradient from white to red
//        CGFloat colors [] = {
//            252.0/255.0, 252.0/255.0, 252.0/255.0, 1.0,
//            228.0/255.0, 228.0/255.0, 228.0/255.0, 1.0
//        };
//        
//        CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
//        CGGradientRef gradient = CGGradientCreateWithColorComponents(baseSpace, colors, NULL, 2);
//        
//        CGColorSpaceRelease(baseSpace), baseSpace = NULL;
//        CGContextSaveGState(context);
//        CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
//        CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
//        
//        CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
//        CGGradientRelease(gradient), gradient = NULL;
//        
//        CGContextRestoreGState(context);
//        CGContextDrawPath(context, kCGPathStroke);
//    }
//    
//    CGContextMoveToPoint(context, 0, rect.size.height);
//    CGContextAddLineToPoint(context, rect.size.width, rect.size.height);
//    CGContextSetStrokeColorWithColor(context, [[UIColor colorWithRed:208.0/255.0 green:208.0/255.0 blue:208.0/255.0 alpha:1.0] CGColor]);
//    CGContextSetLineWidth(context, 1.0);
//    CGContextStrokePath(context);
//}

@end
