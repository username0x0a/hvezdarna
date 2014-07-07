//
//  webCam.m
//  Hvezdarna
//
//  Created by Michal Zelinka in 2013
//  Copyright (c) 2013- Michal Zelinka. All rights reserved.
//

#import "WebCam.h"
#import "UIImageView+AFNetworking.h"
#import <QuartzCore/QuartzCore.h>

@implementation WebCam

@synthesize URL             = _URL;
@synthesize imageView       = _imageView;
@synthesize minimumScale    = _minimumScale;
@synthesize maximumScale    = _maximumScale;
@synthesize scrollView      = _scrollView;

+ (id)webCamWithURL:(NSString*)URL andImageViewFrame:(CGRect)frame andInsertToSuperView:(UIView*)view {
    
    WebCam *cam    = [[WebCam alloc] init];
    if (cam) {
        [cam setURL:URL];
        [[cam imageView] setFrame:frame];
        [view addSubview:[cam imageView]];
    }
    return cam;
}

+ (id)webCamZoomableWithURL:(NSString *)URL andImageViewFrame:(CGRect)frame andInsertToSuperView:(UIView*)view {
    
    WebCam *cam    = [[WebCam alloc] init];
    if (cam) {
        [cam setURL:URL];
        [cam enableZoomWithFrame:frame];        
        [view addSubview:[cam scrollView]];
    }
    return cam;
}

- (id)init {
    self    = [super init];
    if (self) {
        [self setImageView:[[UIImageView alloc] initWithFrame:CGRectZero]];
        
        self.minimumScale   = 1.0;
        self.maximumScale   = 1.8;
    }
    return self;
}

- (void)downloadWith:(void (^)(UIImageView *imageView,UIImage *image))success
          orFailure:(void (^)(UIImageView *imageView,BOOL diskCacheUsed))failure {    

	__weak WebCam *weakSelf = self;
    [self.imageView setUseDiskCache:YES];
    [self.imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.URL] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30.0] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {        
        
        if (success)
            success(weakSelf.imageView,image);

    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, BOOL diskCacheUsed) {
        if (failure)
            failure(weakSelf.imageView,diskCacheUsed);
    }];
}

#pragma mark UIScrollView Zoom

-(void)enableZoomWithFrame:(CGRect)frame {
    [self.imageView setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    [self.imageView setUserInteractionEnabled:YES];
    [self.imageView setMultipleTouchEnabled:YES];
    
    UITapGestureRecognizer *tapGesture  = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleFitZoom:)];
    [tapGesture setNumberOfTapsRequired:2];
    [self.imageView addGestureRecognizer:tapGesture];
    
    self.scrollView  = [[UIScrollView alloc] initWithFrame:frame];
    [self.scrollView setContentSize:CGSizeMake(frame.size.width, frame.size.height)];
    
    [self.scrollView setDelegate:self];
    
    [self.scrollView setMaximumZoomScale:self.maximumScale];
    [self.scrollView setMinimumZoomScale:self.minimumScale];
    
    [self.scrollView setShowsHorizontalScrollIndicator:NO];
    [self.scrollView setShowsVerticalScrollIndicator:NO];
    
    [self.scrollView addSubview:self.imageView];
    
    
}

-(void)setMaximumScale:(float)maximumScale {
    _maximumScale   = maximumScale;
    if (self.scrollView != nil) {
        [self.scrollView setMaximumZoomScale:maximumScale];
    }
}
-(void)setMinimumScale:(float)minimumScale {
    _minimumScale   = minimumScale;
    if (self.scrollView != nil) {
        [self.scrollView setMinimumZoomScale:minimumScale];
    }
}

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)toggleFitZoom:(UITapGestureRecognizer*)gesture {
    if (gesture.state == UIGestureRecognizerStateEnded) {
        if (self.scrollView.zoomScale > 1) {
            [self.scrollView setZoomScale:1.0 animated:YES];
        } else {
            float zoomScale     = (self.imageView.frame.size.width/self.imageView.image.size.width) + (self.imageView.image.size.height/self.imageView.frame.size.height) - 1;
            NSLog(@"%f",zoomScale);
            [self.scrollView setZoomScale:zoomScale  animated:YES];
            
        }
    }
}

@end
