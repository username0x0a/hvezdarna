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


@interface WeatherViewController ()

@property (nonatomic, strong) UIView *blurView;

@end


@implementation WeatherViewController

#pragma mark - View Lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
	{
		self.title = @"Aktuálně";
		self.tabBarItem.image = [UIImage imageNamed:@"actual"];
	}

	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	[self reloadCameraImage];

	[self.view addGestureRecognizer:[[UITapGestureRecognizer alloc]
		initWithTarget:self action:@selector(backgroundTapped:)]];

	if (isIPad() || isWidescreen() || isUltraWidescreen())
	{
		_temperatureHeadingLabel.top += 32;
		_temperatureLabel.top += 32;
		_detailsContainer.top += 40;
	}

	if (isIPad())
	{
		_detailsContainer.left -= 50;
		_detailsContainer.width += 100;
	}

	if (isUltraWidescreen())
	{
		_temperatureHeadingLabel.top += 16;
		_temperatureLabel.top += 16;
		_detailsContainer.top += 16;
		_detailsContainer.left -= 20;
		_detailsContainer.width += 40;
	}

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

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];

	if (![Utils connectionAvailable]) {
		[[[UIAlertView alloc] initWithTitle:@"Chyba připojení"
			message:@"Připojení k internetu není k dipozici" delegate:self
				cancelButtonTitle:@"Zavřít" otherButtonTitles:nil] show];
		return;
	}

	// Refresh image
	[self reloadCameraImage];

	// Also update actual data
	[self reloadScreenData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	if (isIPad())
		return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
				interfaceOrientation == UIInterfaceOrientationLandscapeRight);

	return NO;
}


#pragma mark - Data reloading


- (void)reloadCameraImage
{
	static NSDate *lastUpdate = nil;

	// Allow refreshing only once per 10 minutes
	if (lastUpdate && [[NSDate new] timeIntervalSinceDate:lastUpdate] < 10*kTimeMinuteInSeconds)
		return;

	lastUpdate = [NSDate new];

	// @"http://www.hvezdarna.cz/ryba/ryba512.jpg"

	AFHTTPRequestOperation *request = [[AFHTTPRequestOperation alloc]
		initWithRequest:[NSURLRequest requestWithURL:
			[NSURL URLWithString:@"http://www.hvezdarna.cz/kamera/kamera1920.jpg"]]];

	[request setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id response) {

		UIImage *image = [UIImage imageWithData:operation.responseData];

		if (!image) return;

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

	} failure:nil];

	[request start];
}

- (void)reloadScreenData
{
	static NSDate *lastUpdate = nil;

	// Allow refreshing only once per 2 minutes
	if (lastUpdate && [[NSDate new] timeIntervalSinceDate:lastUpdate] < 2*kTimeMinuteInSeconds)
		return;

	lastUpdate = [NSDate new];

	AFHTTPRequestOperation *request = [[AFHTTPRequestOperation alloc]
		initWithRequest:[NSURLRequest requestWithURL:
			[NSURL URLWithString:@"http://www.hvezdarna.cz/meteo/lastmeteodata"]]];

	[request setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id response){

		NSLog(@"Updating actual temperature and data…");
		
		// Separate values
		NSArray *values = [operation.responseString componentsSeparatedByString:@" "];

		// Do basic values number check
		if (values.count < 18) return;
		
		// Set temperature
		double temperature = [[values objectAtIndex:4] doubleValue];
		temperature = round(temperature);
		if (temperature == 0) temperature = 0;
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

//- (void)reloadTwitterStuff
//{
//	// Let's ask for the latest tweet
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
//}


#pragma mark - Actions


- (void)backgroundTapped:(UITapGestureRecognizer *)gesture
{
	static BOOL hidden = NO;

	[UIView animateWithDuration:.233 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|
	 UIViewAnimationOptionAllowUserInteraction animations:^{

		hidden = !hidden;

		if (isIOS7)
			[[UIApplication sharedApplication] setStatusBarHidden:hidden
				withAnimation:UIStatusBarAnimationSlide];

		for (UIView *v in self.view.subviews)
			if (v != _backgroundView) {
				v.alpha = (hidden) ? 0.0 : 1.0;
				if (v != _blurView) v.transform = CGAffineTransformMakeTranslation(0,
					(hidden) ? v == _conditionImage ? 120:-100:0); }

		self.tabBarController.tabBar.alpha = (hidden) ? 0.0 : 1.0;
		self.tabBarController.tabBar.transform = CGAffineTransformMakeTranslation(0,
			(hidden) ? kUITabBarHeight:0);

	} completion:nil];
}

- (void)startImageActivity
{
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}
- (void)stopImageActivity
{
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}


@end
