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
		[self addSubview:_title];
	}

	return self;
}

//- (void)drawRect:(CGRect)rect
//{
//	[_title sizeToFit];
//	[_title moveToCenterOfSuperview];
//
//	if (isIOS7)
//	{
//		CGFloat padding = 10.0;
//
//		CGContextRef context = UIGraphicsGetCurrentContext();
//
//		UIColor *color = [UIColor lightGrayColor];
//		CGContextSetStrokeColorWithColor(context, [color CGColor]);
//		CGContextSetLineWidth(context, 2.0);
//
//		CGContextMoveToPoint(context, padding, rect.size.height/2);
//		CGContextAddLineToPoint(context, _title.left-padding, rect.size.height/2);
//		CGContextStrokePath(context);
//
//		CGContextMoveToPoint(context, _title.right+padding, rect.size.height/2);
//		CGContextAddLineToPoint(context, rect.size.width-padding, rect.size.height/2);
//		CGContextStrokePath(context);
//	}
//	else
//	{
//		CGContextRef context = UIGraphicsGetCurrentContext();
//
//		CGFloat colors [ ] = {
//			77.0/255.0, 206.0/255.0, 247.0/255.0, 1.0,58.0/255.0, 163.0/255.0, 213.0/255.0, 1.0
//		};
//
//		CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
//		CGGradientRef gradient = CGGradientCreateWithColorComponents(baseSpace, colors, NULL, 2);
//
//		CGColorSpaceRelease(baseSpace), baseSpace = NULL;
//		CGContextSaveGState(context);
//		CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
//		CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
//
//		CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
//		CGGradientRelease(gradient), gradient = NULL;
//
//		CGContextRestoreGState(context);
//		CGContextDrawPath(context, kCGPathStroke);
//
//		UIColor     *color      = [UIColor colorWithRed:28.0/255.0 green:134.0/255.0 blue:171.0/255.0 alpha:1.0];
//		CGContextMoveToPoint(context, 0, rect.size.height);
//		CGContextAddLineToPoint(context, rect.size.width, rect.size.height);
//		CGContextSetStrokeColorWithColor(context, [color CGColor]);
//		CGContextSetLineWidth(context, 1.0);
//		CGContextStrokePath(context);
//
//		CGContextMoveToPoint(context, 0, 0);
//		CGContextAddLineToPoint(context, rect.size.width, 0);
//		CGContextSetStrokeColorWithColor(context, [color CGColor]);
//		CGContextSetLineWidth(context, 1.0);
//		CGContextStrokePath(context);
//	}
//}


@end
