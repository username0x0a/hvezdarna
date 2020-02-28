//
//  WeatherViewModel.m
//  Hvezdarna
//
//  Created by Michi on 28/02/2020.
//  Copyright © 2020 Heartpix. All rights reserved.
//

#import "WeatherViewModel.h"

@implementation WeatherData @end

@implementation WeatherViewModel

- (void)checkWeatherDataWithCompletion:(void (^)(WeatherData * _Nullable data, BOOL updated))completion
{
	static NSDate *lastUpdate = nil;

	// Allow refreshing only once per 2 minutes
	if (lastUpdate && [[NSDate new] timeIntervalSinceDate:lastUpdate] < 2*kTimeMinuteInSeconds) {
		completion(nil, NO);
		return;
	}

	lastUpdate = [NSDate new];

	NSURL *url = [NSURL URLWithString:@"https://www.hvezdarna.cz/meteo/lastmeteodatanew"];

	[[[NSURLSession sharedSession] dataTaskWithURL:url
		completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {

		NSHTTPURLResponse *resp = (id)response;

		if (![resp isKindOfClass:[NSHTTPURLResponse class]] || resp.statusCode != 200) {
			completion(nil, NO);
			return;
		}

		NSString *respString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

		NSLog(@"Updating actual temperature and data…");

		// Separate values
		NSArray<NSString *> *values = [respString componentsSeparatedByString:@" "];

		// Do basic values number check
		if (values.count < 8) return;

		WeatherData *weather = [WeatherData new];
		weather.temperature = [[values objectAtIndex:3] doubleValue];
		weather.windSpeed = [[values objectAtIndex:5] doubleValue];
		weather.pressure = [[values objectAtIndex:7] intValue];
		weather.humidity = [[values objectAtIndex:4] intValue];

		completion(weather, YES);

	}] resume];
}

- (void)checkCameraImageWithCompletion:(void (^)(NSData * _Nullable))completion
{
	static NSDate *lastUpdate = nil;

	// Allow refreshing only once per 10 minutes
	if (lastUpdate && [[NSDate new] timeIntervalSinceDate:lastUpdate] < 10*kTimeMinuteInSeconds)
		return;

	lastUpdate = [NSDate new];

	// @"http://www.hvezdarna.cz/ryba/ryba512.jpg"
	NSURL *url = [NSURL URLWithString:@"http://www.hvezdarna.cz/kamera/kamera1920.jpg"];

	[[[NSURLSession sharedSession] dataTaskWithURL:url
		completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {

		NSHTTPURLResponse *resp = (id)response;

		if (![resp isKindOfClass:[NSHTTPURLResponse class]] || resp.statusCode != 200) {
			completion(nil);
			return;
		}

		NSLog(@"Updating camera image…");

		completion(data);

	}] resume];
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

@end
