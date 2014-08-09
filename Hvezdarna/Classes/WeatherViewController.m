//
//  WeatherViewController.m
//  Hvezdarna
//
//  Created by Michal Zelinka in 2013
//  Copyright (c) 2013- Michal Zelinka. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "WeatherViewController.h"
#import "WebCam.h"
#import "UIView+position.h"
#import "Utils.h"
#import "AFHTTPRequestOperation.h"

#define kInfoButtonPadding  10


@interface WeatherViewController ()

@property(nonatomic,copy) NSString *twitter_link;
@property (nonatomic, strong) UIView *blurView;

@end


@implementation WeatherViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
	{
		self.title = @"Aktuálně";
		self.tabBarItem.image = [UIImage imageNamed:@"actual"];
    }

    return self;
}

- (void)backgroundTapped:(UITapGestureRecognizer *)gesture
{
	static BOOL hidden = NO;

	[UIView animateWithDuration:.233 animations:^{

		hidden = !hidden;

		[[UIApplication sharedApplication] setStatusBarHidden:hidden withAnimation:UIStatusBarAnimationSlide];

		for (UIView *v in self.view.subviews)
			if (v != _backgroundView)
			{
				v.alpha = (hidden) ? 0.0 : 1.0;
				if (v != _blurView) v.transform = CGAffineTransformMakeTranslation(0,
					(hidden) ? v == _conditionImage ? 120:-100:0);
			}

		self.tabBarController.tabBar.alpha = (hidden) ? 0.0 : 1.0;
		self.tabBarController.tabBar.transform = CGAffineTransformMakeTranslation(0,
			(hidden) ? kUITabBarHeight:0);

	}];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self reloadCameraImage];

	[self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapped:)]];

	_blurView = [[MaskAutoAdjustingView alloc] initWithFrame:self.view.frame];
	_blurView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//	NSTimeInterval dayInterval = (NSInteger)([[NSDate new] timeIntervalSince1970] + 2*60*60) % 86400;
//	CGFloat colorIntensity = (dayInterval < 6.5*60*60 || dayInterval > 22*60*60) ? .11 : .22;
	CGFloat colorIntensity = .22;
	_blurView.backgroundColor = [UIColor colorWithWhite:colorIntensity alpha:.84];
	[self.view insertSubview:_blurView aboveSubview:_backgroundView];

#define C(a) ((id)[UIColor colorWithWhite:1.0 alpha:a].CGColor)

	CAGradientLayer *l = [CAGradientLayer layer];
	l.frame = _blurView.bounds;
	l.colors = @[ C(.95), C(0), C(0), C(.95), C(.95) ];
	l.locations = @[ @0.0f, @0.5f, @0.78f, @1.0f, @1.0f ];
	l.startPoint = CGPointMake(0.5f, 0.0f);
	l.endPoint = CGPointMake(0.5f, 1.0f);
	_blurView.layer.mask = l;
}

- (void)reloadCameraImage
{
	static NSDate *lastUpdate = nil;

	// Allow refreshing only once per 2 minutes
	if (lastUpdate && [[NSDate new] timeIntervalSinceDate:lastUpdate] < 2*kTimeMinuteInSeconds)
		return;

	lastUpdate = [NSDate new];

	[[NSOperationQueue new] addOperationWithBlock:^{

		// @"http://www.hvezdarna.cz/ryba/ryba512.jpg"

		NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://www.hvezdarna.cz/kamera/kamera1920.jpg"]];
		UIImage *image = [UIImage imageWithData:data];

		if (!image) return;

		[[NSOperationQueue mainQueue] addOperationWithBlock:^{

			UIImageView *imageView = [[UIImageView alloc] initWithFrame:_backgroundView.bounds];
			imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
			imageView.contentMode = UIViewContentModeScaleAspectFill;
			imageView.alpha = 0.0;
			imageView.image = image;

			[_backgroundView addSubview:imageView];
			[UIView animateWithDuration:1.3 animations:^{

				imageView.alpha = 1.0;

			} completion:^(BOOL finished) {

				NSArray *layers = [_backgroundView.subviews copy];

				for (UIView *v in layers)
					if (v != imageView)
						[v removeFromSuperview];

			}];

		}];
	}];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
	if (![Utils connectionAvailable]) {
		[[[UIAlertView alloc] initWithTitle:@"Chyba připojení"
			message:@"Připojení k internetu není k dipozici" delegate:self
				cancelButtonTitle:@"Zavřít" otherButtonTitles:nil] show];
		return;
	}
    
//    // Let's ask for the latest tweet
//
//	NSURL *tweet_url = [NSURL URLWithString:@"https://twitter.com/HvezdarnaBrno"];
//	NSURLRequest *tweet_request = [NSURLRequest requestWithURL:tweet_url];
//	AFHTTPRequestOperation *tweet_operation = [[AFHTTPRequestOperation alloc] initWithRequest:tweet_request];
//	[tweet_operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id response) {
//		NSLog(@"Getting latest tweet…");
//
//		NSString * tweet = [Utils getValueFromString:operation.responseString withStarters:@[@"li class=\"js-stream-item"] andEnding:@"li class=\"js-stream-item"];
//		if (tweet) {
//			self.twitter_link = [@"https://twitter.com" stringByAppendingString:[Utils getValueFromString:tweet withStarters:@[@"class=\"details with-icn js-details", @"href=\""] andEnding:@"\""]];
//			NSLog(@"Tweet link: %@", self.twitter_link);
//			tweet = [Utils getValueFromString:tweet withStarters:@[@"p class=\"js-tweet-text tweet-text", @">"] andEnding:@"</p"];
//			NSRange r;
//			while ((r = [tweet rangeOfString:@"<a[^>]*>.*?</a>" options:NSRegularExpressionSearch]).location != NSNotFound)
//				tweet = [tweet stringByReplacingCharactersInRange:r withString:@""];
//			[self showTextInfoButton:tweet withTarget:self andSelector:@selector(openTwitterLink:) andAnimate:YES];
//		}
//		
//	} failure:nil];
//	[tweet_operation start];

	// Refresh image
	[self reloadCameraImage];

	// Also update actual data

	AFHTTPRequestOperation *request = [[AFHTTPRequestOperation alloc]
		initWithRequest:[NSURLRequest requestWithURL:
			[NSURL URLWithString:@"http://www.hvezdarna.cz/meteo/lastmeteodata"]]];

	[request setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id response){

		NSLog(@"Updating actual temperature and data…");
		
		// Parse values
		NSArray *values = [operation.responseString componentsSeparatedByString:@" "];
		
		// Set temperature
		double temperature = [[values objectAtIndex:4] doubleValue];
		NSString *temperatureString = [NSString stringWithFormat:@"%.0f °C", temperature];
		_temperatureLabel.text = temperatureString;
		_temperatureLabel.accessibilityLabel = [NSString stringWithFormat:@"%@ %@",
			_temperatureHeadingLabel.text, _temperatureLabel.text];

		// Set wind speed
		NSString *windSpeed = [Utils getLocalUnitValueFromFloat:[[values objectAtIndex:8] floatValue]];
		_windSpeedLabel.text =  [NSString stringWithFormat:@"%@ m/s", windSpeed];
		_windSpeedLabel.accessibilityLabel = [NSString stringWithFormat:@"%@ %@",
			_windSpeedHeadingLabel.text, _windSpeedLabel.text];

		// Set pressure
		int pressure = [[values objectAtIndex:15] intValue];
		_pressureLabel.text = [NSString stringWithFormat:@"%d hPa", pressure];
		_pressureLabel.accessibilityLabel = [NSString stringWithFormat:@"%@ %@",
			_pressureHeadingLabel.text, _pressureLabel.text];

		// Set humidity
		int humidity = [[values objectAtIndex:7] intValue];
		_humidityLabel.text = [NSString stringWithFormat:@"%d %%", humidity];
		_humidityLabel.accessibilityLabel = [NSString stringWithFormat:@"%@ %@",
			_humidityHeadingLabel.text, _humidityLabel.text];

		// Set weather icon
		NSString *condition = [values objectAtIndex:17];
		NSString *imageName = [Utils getWeatherIconFromConditionString:condition];
		_conditionImage.image = [UIImage imageNamed:imageName];

		_conditionImage.accessibilityLabel = [NSString stringWithFormat:@"%@ %@",
			NSLocalizedString(@"The weather is", @"Condition label -- appendable options: clear, cloudy, rainy"),
			[Utils getVerboseStringFromConditionString:condition]];

	} failure:nil];

	[request start];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	if (isIPad())
		return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
				interfaceOrientation == UIInterfaceOrientationLandscapeRight);

	return NO;
}

- (void)startImageActivity
{
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}
- (void)stopImageActivity
{
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}


#pragma mark UIScrollView


- (IBAction)openTwitterLink:(id)sender
{
	[Utils openURL:self.twitter_link inDelegate:self withStyle:UtilsWebBrowserModal];
}

- (IBAction)openHomepage
{
	[Utils openURL:@"http://hvezdarna.cz/" inDelegate:self withStyle:UtilsWebBrowserModal];
}

@end
