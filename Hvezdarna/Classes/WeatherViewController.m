//
//  WeatherViewController.m
//  Hvezdarna
//
//  Created by Michal Zelinka in 2013
//  Copyright (c) 2013- Michal Zelinka. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "WeatherViewModel.h"
#import "WeatherViewController.h"

#import "UIView+position.h"
#import "Utils.h"


@interface WeatherViewController ()

@property (nonatomic, strong) WeatherViewModel *model;
@property (nonatomic, strong) UIView *blurView;

@end


@implementation WeatherViewController

#pragma mark - View Lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
	{
		_model = [WeatherViewModel new];

		self.title = @"Aktuálně";
		self.tabBarItem.image = [UIImage imageNamed:@"tab-weather"];
	}

	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	[self reloadCameraImage];

	[self.view addGestureRecognizer:[[UITapGestureRecognizer alloc]
		initWithTarget:self action:@selector(backgroundTapped:)]];

	NSInteger hour = [[NSCalendar currentCalendar] component:NSCalendarUnitHour fromDate:[NSDate new]];
	NSString *image = (hour < 6 || hour > 20) ? @"placeholder-evening" : @"placeholder-dusk";
	_backgroundView.image = [UIImage imageNamed:image];

#if TARGET_OS_IOS == 1

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
		_conditionImage.top -= 40;
	}

#endif

	NSArray<UIView *> *views = @[ _conditionImage,
		_temperatureHeadingLabel, _temperatureLabel,
		_pressureHeadingLabel, _pressureLabel,
		_windSpeedHeadingLabel, _windSpeedLabel,
		_humidityHeadingLabel, _humidityLabel
	];

	for (UIView *v in views) {
		v.layer.shadowColor = [UIColor blackColor].CGColor;
		v.layer.shadowOffset = CGSizeZero;
#if TARGET_OS_IOS == 1
		v.layer.shadowOpacity = 1.0;
		v.layer.shadowRadius = 1;
#else
		v.layer.shadowOpacity = 0.45;
		v.layer.shadowRadius = 12;
#endif
	}

	CGFloat colorIntensity = (hour < 6 || hour > 20) ? .11 : .22;

	_blurView = [[MaskAutoAdjustingView alloc] initWithFrame:self.view.frame];
	_blurView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
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

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

#if TARGET_OS_TV == 1

	UIView *blur = _blurView;
	UIView *back = _backgroundView;

	blur.alpha = 0;
	back.alpha = 0;

	UIView *sup = self.tabBarController.view.superview;
	[sup insertSubview:back atIndex:0];
	[sup insertSubview:blur atIndex:0];

	[UIView animateWithDuration:0.5 animations:^{
		blur.alpha = 1;
		back.alpha = 1;
	}];

#endif
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];

#if TARGET_OS_TV == 1

	UIView *blur = _blurView;
	UIView *back = _backgroundView;

	[UIView animateWithDuration:0.5 animations:^{
		blur.alpha = 0;
		back.alpha = 0;
	}];

#endif
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];

	if (![Utils connectionAvailable]) {
#if !TARGET_OS_TV
		[[[UIAlertView alloc] initWithTitle:@"Chyba připojení"
			message:@"Připojení k internetu není k dipozici" delegate:self
				cancelButtonTitle:@"Zavřít" otherButtonTitles:nil] show];
#endif
		return;
	}

	// Refresh image
	[self reloadCameraImage];

	// Also update actual data
	[self reloadScreenData];
}

#if !TARGET_OS_TV
- (UIStatusBarStyle)preferredStatusBarStyle
{
	return UIStatusBarStyleLightContent;
}
#endif


#pragma mark - Data reloading


- (void)reloadCameraImage
{
	__auto_type sself = self;

	[sself setNetworkLocallyActive:YES];

	[_model checkCameraImageWithCompletion:^(NSData * _Nullable data) {

		[sself setNetworkLocallyActive:NO];

		if (!data) return;

		[sself performSelectorOnMainThread:@selector(updateWithCameraData:) withObject:data waitUntilDone:NO];

	}];
}

- (void)reloadScreenData
{
	__auto_type sself = self;

	[sself setNetworkLocallyActive:YES];

	[_model checkWeatherDataWithCompletion:^(WeatherData * _Nullable data, BOOL updated) {

		[sself setNetworkLocallyActive:NO];

		if (!updated || !data) return;

		[sself performSelectorOnMainThread:@selector(updateWithWeatherData:) withObject:data waitUntilDone:NO];

	}];
}

- (void)updateWithWeatherData:(WeatherData *)weather
{
	// Set temperature
	double temperature = round(weather.temperature);
	if (temperature == 0) temperature = 0;
	NSString *temperatureString = [NSString stringWithFormat:@"%.0f °C", temperature];
	_temperatureLabel.text = temperatureString;
	_temperatureLabel.accessibilityLabel = [NSString stringWithFormat:@"%@ %@",
		_temperatureHeadingLabel.text, _temperatureLabel.text];

	// Set wind speed
	NSString *speed = [Utils getLocalUnitValueFromFloat:(float)weather.windSpeed];
	_windSpeedLabel.text =  [NSString stringWithFormat:@"%@ m/s", speed];
	_windSpeedLabel.accessibilityLabel = [NSString stringWithFormat:@"%@ %@",
		_windSpeedHeadingLabel.text, _windSpeedLabel.text];

	// Set pressure
	_pressureLabel.text = [NSString stringWithFormat:@"%tu hPa", weather.pressure];
	_pressureLabel.accessibilityLabel = [NSString stringWithFormat:@"%@ %@",
		_pressureHeadingLabel.text, _pressureLabel.text];

	// Set humidity
	NSUInteger humidity = weather.humidity;
	_humidityLabel.text = [NSString stringWithFormat:@"%tu %%", humidity];
	_humidityLabel.accessibilityLabel = [NSString stringWithFormat:@"%@ %@",
		_humidityHeadingLabel.text, _humidityLabel.text];

	// Set weather icon
	// Options: "Rainy", "Cloudy", "Sunny"
	NSString *condition = @"Sunny";
	if (humidity > 50) condition = @"Cloudy";
	if (humidity > 70) condition = @"Rainy";

	NSString *imageName = [Utils getWeatherIconFromConditionString:condition];
	_conditionImage.image = [[UIImage imageNamed:imageName]
		imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

	_conditionImage.accessibilityLabel = [NSString stringWithFormat:@"%@ %@",
		NSLocalizedString(@"The weather is", @"Condition label -- appendable options: clear, cloudy, rainy"),
		[Utils getVerboseStringFromConditionString:condition]];
}

- (void)updateWithCameraData:(NSData *)data
{
	UIImage *image = [UIImage imageWithData:data];

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
}


#pragma mark - Actions


- (void)backgroundTapped:(UITapGestureRecognizer *)gesture
{
	static BOOL hidden = NO;

	[UIView animateWithDuration:.233 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|
	 UIViewAnimationOptionAllowUserInteraction animations:^{

		hidden = !hidden;

#if !TARGET_OS_TV
		[[UIApplication sharedApplication] setStatusBarHidden:hidden
			withAnimation:UIStatusBarAnimationSlide];
#endif

		for (UIView *v in self.view.subviews)
			if (v != self->_backgroundView) {
				v.alpha = (hidden) ? 0.0 : 1.0;
				if (v != self->_blurView) v.transform = CGAffineTransformMakeTranslation(0,
					(hidden) ? v == self->_conditionImage ? 120:-100:0); }

		self.tabBarController.tabBar.alpha = (hidden) ? 0.0 : 1.0;

	} completion:nil];
}

- (void)setNetworkLocallyActive:(BOOL)active
{
	static NSUInteger counter = 0;

	counter += (active) ? 1 : -1;

	if (counter < 0) counter = 0;

#if !TARGET_OS_TV
	[[NSOperationQueue mainQueue] addOperationWithBlock:^{
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:(counter != 0)];
	}];
#endif
}

@end
