//
//  webCam.h
//  Hvezdarna
//
//  Created by Michal Zelinka in 2013
//  Copyright (c) 2013- Michal Zelinka. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WebCam : NSObject <UIScrollViewDelegate>

@property (nonatomic,retain) NSString       *URL;

@property (nonatomic,strong) UIImageView    *imageView;

@property (nonatomic,strong) UIScrollView   *scrollView;

@property (nonatomic) float                 minimumScale;
@property (nonatomic) float                 maximumScale;

+ (id)webCamWithURL:(NSString *)URL andImageViewFrame:(CGRect)frame andInsertToSuperView:(UIView*)view;

+ (id)webCamZoomableWithURL:(NSString *)URL andImageViewFrame:(CGRect)frame andInsertToSuperView:(UIView*)view;

- (void)downloadWith:(void (^)(UIImageView *imageView,UIImage *image))success
          orFailure:(void (^)(UIImageView *imageView,BOOL diskCacheUsed))failure;

#pragma mark UIScrollView Zoom

- (void)enableZoomWithFrame:(CGRect)frame;
- (void)toggleFitZoom:(UITapGestureRecognizer*)gesture;

@end
