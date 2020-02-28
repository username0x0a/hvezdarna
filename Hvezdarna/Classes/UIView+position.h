//
//  UIView+position.h
//
//  Apache license
//
//  Created by Tyler Neylon on 3/19/10 (http://bynomial.com/blog/?p=24)
//  Copyleft 2010 Bynomial.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIView (position)

@property (nonatomic) CGPoint origin;
@property (nonatomic) CGSize size;

@property (nonatomic) CGFloat left;
@property (nonatomic) CGFloat top;

@property (nonatomic) CGFloat fromLeadingEdge;
@property (nonatomic) CGFloat fromTrailingEdge;

// Setting these modifies the origin but not the size.
@property (nonatomic) CGFloat right;
@property (nonatomic) CGFloat bottom;
@property (nonatomic) CGFloat fromRightEdge;
@property (nonatomic) CGFloat fromBottomEdge;

@property (nonatomic) CGFloat width;
@property (nonatomic) CGFloat height;

// Methods for centering.
- (void)addCenteredSubview:(UIView *)subview;
- (void)moveToCenterOfSuperview;
- (void)centerVerticallyInSuperview;
- (void)centerHorizontallyInSuperview;

@end
