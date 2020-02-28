//
//  UIView+position.m
//
//  Apache license
//
//  Created by Tyler Neylon on 3/19/10 (http://bynomial.com/blog/?p=24)
//  Copyleft 2010 Bynomial.
//

#import "UIView+position.h"

@implementation UIView (position)

- (CGPoint)origin {
  return self.frame.origin;
}

- (void)setOrigin:(CGPoint)newOrigin {
  CGRect frame = self.frame;
  frame.origin = newOrigin;
  self.frame = frame;
}

- (CGSize)size {
  return self.frame.size;
}

- (void)setSize:(CGSize)newSize {
  CGRect frame = self.frame;
  frame.size = newSize;
  self.frame = frame;
}

- (CGFloat)left {
  return self.frame.origin.x;
}

- (void)setLeft:(CGFloat)newX {
  CGRect frame = self.frame;
  frame.origin.x = newX;
  self.frame = frame;
}

- (CGFloat)top {
  return self.frame.origin.y;
}

- (void)setTop:(CGFloat)newY {
  CGRect frame = self.frame;
  frame.origin.y = newY;
  self.frame = frame;
}

- (CGFloat)right {
  CGRect frame = self.frame;
  return frame.origin.x + frame.size.width;
}

- (void)setRight:(CGFloat)newRight {
  CGRect frame = self.frame;
  frame.origin.x = newRight - frame.size.width;
  self.frame = frame;
}

- (CGFloat)bottom {
  CGRect frame = self.frame;
  return frame.origin.y + frame.size.height;
}

- (void)setBottom:(CGFloat)newBottom {
  CGRect frame = self.frame;
  frame.origin.y = newBottom - frame.size.height;
  self.frame = frame;
}

- (CGFloat)width {
  return self.frame.size.width;
}

- (void)setWidth:(CGFloat)newWidth {
  CGRect frame = self.frame;
  frame.size.width = newWidth;
  self.frame = frame;
}

- (CGFloat)height {
  return self.frame.size.height;
}

- (void)setHeight:(CGFloat)newHeight {
  CGRect frame = self.frame;
  frame.size.height = newHeight;
  self.frame = frame;
}

- (void)addCenteredSubview:(UIView *)subview {
  CGRect bounds = self.bounds;
  CGRect subFrame = subview.frame;

  subFrame.origin.x = (int)((bounds.size.width - subFrame.size.width) / 2);
  subFrame.origin.y = (int)((bounds.size.height - subFrame.size.height) / 2);
  subview.frame = subFrame;

  [self addSubview:subview];
}

- (void)moveToCenterOfSuperview
{
  if (!self.superview)
    NSLog(@"Trying to move view inside superview before attaching. Expect weird stuff.");

  CGRect frame = self.frame;
  CGRect superBounds = self.superview.bounds;

  frame.origin.x = (int)((superBounds.size.width - frame.size.width) / 2);
  frame.origin.y = (int)((superBounds.size.height - frame.size.height) / 2);

  self.frame = frame;
}

- (void)centerVerticallyInSuperview
{
  if (!self.superview)
    NSLog(@"Trying to move view inside superview before attaching. Expect weird stuff.");

  CGRect frame = self.frame;
  CGRect superBounds = self.superview.bounds;

  frame.origin.y = (int)((superBounds.size.height - frame.size.height) / 2);

  self.frame = frame;
}

- (void)centerHorizontallyInSuperview
{
  if (!self.superview)
    NSLog(@"Trying to move view inside superview before attaching. Expect weird stuff.");

  CGRect frame = self.frame;
  CGRect superBounds = self.superview.bounds;

  frame.origin.x = (int)((superBounds.size.width - frame.size.width) / 2);

  self.frame = frame;
}

- (CGFloat)fromRightEdge
{
  UIView *superView = self.superview;
  if (!superView) return 0;

  CGRect frame = self.frame;
  CGRect superBounds = superView.bounds;

  return CGRectGetWidth(superBounds) - frame.size.width - frame.origin.x;
}

- (void)setFromRightEdge:(CGFloat)fromRightEdge
{
  UIView *superView = self.superview;
  if (!superView) return;

  CGRect frame = self.frame;
  CGRect superBounds = superView.bounds;

  frame.origin.x = CGRectGetWidth(superBounds) - frame.size.width - fromRightEdge;

  self.frame = frame;
}

- (CGFloat)fromBottomEdge
{
  UIView *superView = self.superview;
  if (!superView) return 0;

  CGRect frame = self.frame;
  CGRect superBounds = superView.bounds;

  return CGRectGetHeight(superBounds) - frame.size.height - frame.origin.y;
}

- (void)setFromBottomEdge:(CGFloat)fromBottomEdge
{
  UIView *superView = self.superview;
  if (!superView) return;

  CGRect frame = self.frame;
  CGRect superBounds = superView.bounds;

  frame.origin.y = CGRectGetHeight(superBounds) - frame.size.height - fromBottomEdge;

  self.frame = frame;
}

- (CGFloat)fromLeadingEdge
{
  return self.frame.origin.x;
}

- (CGFloat)fromTrailingEdge
{
  UIView *superView = self.superview;
  if (!superView) return 0;

  CGRect frame = self.frame;
  CGRect superBounds = superView.bounds;

  return CGRectGetWidth(superBounds) - frame.size.width - frame.origin.x;
}

- (void)setFromLeadingEdge:(CGFloat)fromLeadingEdge
{
  CGRect frame = self.frame;
  frame.origin.x = fromLeadingEdge;
  self.frame = frame;
}

- (void)setFromTrailingEdge:(CGFloat)fromTrailingEdge
{
  UIView *superView = self.superview;
  if (!superView) return;

  CGRect frame = self.frame;
  CGRect superBounds = superView.bounds;

  frame.origin.x = CGRectGetWidth(superBounds) - frame.size.width - fromTrailingEdge;

  self.frame = frame;
}

@end
