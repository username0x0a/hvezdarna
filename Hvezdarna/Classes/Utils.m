//
//  Utils.m
//  Hvezdarna
//
//  Created by Michal Zelinka in 2013
//  Copyright (c) 2013- Michal Zelinka. All rights reserved.
//

#include <netinet/in.h>
#import <SystemConfiguration/SCNetworkReachability.h>
#import "Utils.h"
#import "SVWebViewController.h"
#import "SVModalWebViewController.h"

@implementation Utils

+ (NSString*) getValueFromString:(NSString*)data withStarters:(NSArray*)starters andEnding:(NSString*)ending {

	NSRange range = NSMakeRange(0, [data length]-1);

	for (NSString *starter in starters) {
		NSRange tmp = [data rangeOfString:starter options:0 range:range];
		if (tmp.location == NSNotFound)
			return nil;
		range.length = range.length - (tmp.location - range.location) - [starter length];
		range.location = tmp.location + [starter length];
	}
	
	NSRange tmp = [data rangeOfString:ending options:0 range:range];
	if (tmp.location == NSNotFound)
		return nil;
	range.length = tmp.location - range.location;
	
	return [data substringWithRange:range];
}

+ (NSInteger) getDayTimestampFromCustomLocalDate:(NSString*)date {
	
	NSDateComponents* dc = [[NSDateComponents alloc] init];
	[dc setDay:[date intValue]];
	if      ([date rangeOfString:@"led"].location != NSNotFound)      [dc setMonth:1];
	else if ([date rangeOfString:@"únor"].location != NSNotFound)      [dc setMonth:2];
	else if ([date rangeOfString:@"břez"].location != NSNotFound)     [dc setMonth:3];
	else if ([date rangeOfString:@"dub"].location != NSNotFound)      [dc setMonth:4];
	else if ([date rangeOfString:@"květ"].location != NSNotFound)     [dc setMonth:5];
	else if ([date rangeOfString:@"července"].location != NSNotFound ||
			 [date rangeOfString:@"červenec"].location != NSNotFound)   [dc setMonth:7];
	else if ([date rangeOfString:@"červ"].location != NSNotFound)     [dc setMonth:6];
	else if ([date rangeOfString:@"srp"].location != NSNotFound)      [dc setMonth:8];
	else if ([date rangeOfString:@"září"].location != NSNotFound)       [dc setMonth:9];
	else if ([date rangeOfString:@"říj"].location != NSNotFound)      [dc setMonth:10];
	else if ([date rangeOfString:@"list"].location != NSNotFound)  [dc setMonth:11];
	else if ([date rangeOfString:@"pros"].location != NSNotFound)   [dc setMonth:12];
	else return 0;
	NSDateComponents *now = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:[NSDate date]];
	[dc setYear:[now year]];
	if ([dc month] < [now month]) [dc setYear:[now year]+1];
	[dc setHour:0]; [dc setMinute:0]; [dc setSecond:0];
	NSCalendar *cal = [NSCalendar currentCalendar];
	[cal setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"CET"]];
	[cal setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"cs_CZ"]];
	NSNumber *n = [NSNumber numberWithDouble:[[cal dateFromComponents:dc] timeIntervalSince1970]];
	return [n intValue];
}

+ (NSInteger) getDayTimestampFromCustomLocalTime:(NSString*)time {
	NSArray* t = [time componentsSeparatedByString:@":"];
	return [[t objectAtIndex:0] intValue] * 3600 + [[t objectAtIndex:1] intValue] * 60;
}

+ (NSInteger) getLocalDayTimestampFromTimestamp:(NSInteger)timestamp {
	return timestamp / 86400 * 86400;
}

+ (NSInteger) unixTimestamp {
	return [[NSDate date] timeIntervalSince1970];
}

+ (NSString*) getLocalTimeStringFromTimestamp:(NSInteger)timestamp {
	NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp];
	NSCalendar *cal = [NSCalendar currentCalendar];
	[cal setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"CET"]];
	[cal setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"cs_CZ"]];
	NSDateComponents *c = [cal components:NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:date];
	NSString *minute = [NSString stringWithFormat:([c minute] < 10 ? @"0%d" : @"%d"), [c minute]];
	return [NSString stringWithFormat:@"%d.%@", [c hour], minute];
}

+ (NSString*) getLocalDayOfWeekStringFromTimestamp:(NSInteger)timestamp {
	NSArray *days = @[@"Pondělí", @"Úterý", @"Středa", @"Čtvrtek", @"Pátek", @"Sobota", @"Neděle"];
	timestamp += 2*60*60; // UTC->CET max difference
	int idx = (timestamp / 86400 % 7 + 3) % 7;
	return [days objectAtIndex:idx];
}

+ (NSString*) getLocalDateStringFromTimestamp:(NSInteger)timestamp {
	NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp];
	NSCalendar *cal = [NSCalendar currentCalendar];
	[cal setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"CET"]];
	[cal setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"cs_CZ"]];
	NSDateComponents *c = [cal components:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit fromDate:date];
	return [NSString stringWithFormat:@"%d. %@", [c day], [self getLocalMonthNameFromNumber:[c month]]];
}

+ (NSString*) getLocalMoneyValueFromString:(NSString*)price {
	if ([price intValue] > 0) return [NSString stringWithFormat:@"%@ Kč", price];
	else return @"zdarma";
}

+ (NSString*) getLocalUnitValueFromFloat:(float)value {
	NSInteger int_value =[[NSNumber numberWithFloat:value] intValue];
	if (value == int_value)
		return [NSString stringWithFormat:@"%d", int_value];
	NSString *ret = [NSString stringWithFormat:@"%.1f", value];
	return [ret stringByReplacingOccurrencesOfString:@"." withString:@","];
}

+ (NSString*) getLocalMonthNameFromNumber:(NSInteger)month {
	if (month == 1) return @"ledna";
	if (month == 2) return @"února";
	if (month == 3) return @"března";
	if (month == 4) return @"dubna";
	if (month == 5) return @"května";
	if (month == 6) return @"června";
	if (month == 7) return @"července";
	if (month == 8) return @"srpna";
	if (month == 9) return @"září";
	if (month == 10) return @"října";
	if (month == 11) return @"listopadu";
	if (month == 12) return @"prosince";
	return @"";
}

+ (NSString*) getWeatherIconFromConditionString:(NSString*)condition {
	
	// WS-2300 forecast values: "Rainy", "Cloudy", "Sunny"

	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *components = [calendar components:NSHourCalendarUnit fromDate:[NSDate new]];
	NSInteger hour = [components hour];

	BOOL night = hour < 6 || hour >= 22;

	if ([condition isEqualToString:@"Sunny"])
		return (night) ? @"clear_moon" : @"clear_sun";

	if ([condition isEqualToString:@"Cloudy"]) return @"cloudy";
	if ([condition isEqualToString:@"Rainy"]) return @"rain";
	return nil;
}

+ (void) openURL:(NSString*)url inDelegate:(UIViewController *)delegate withStyle:(UtilsWebBrowserStyle)style {
		
	NSURL *URL = [NSURL URLWithString:url];
	
	if (style == UtilsWebBrowserModal)
	{
		SVModalWebViewController *webViewController = [[SVModalWebViewController alloc] initWithURL:URL];
		webViewController.modalPresentationStyle = UIModalPresentationPageSheet;
		webViewController.availableActions = SVWebViewControllerAvailableActionsOpenInSafari | SVWebViewControllerAvailableActionsCopyLink | SVWebViewControllerAvailableActionsMailLink;
		[delegate.tabBarController presentViewController:webViewController animated:YES completion:nil];
	}
	else if (style == UtilsWebBrowserNavigation)
	{
		SVWebViewController *webViewController = [[SVWebViewController alloc] initWithURL:URL];
		[delegate.navigationController pushViewController:webViewController animated:YES];
	}

}

+ (BOOL) connectionAvailable {
	// Create zero addy
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    // Recover reachability flags
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr*)&zeroAddress);
    SCNetworkReachabilityFlags flags;
    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);
    if (!didRetrieveFlags)
    {
        NSLog(@"Error. Could not recover network reachability flags");
        return 0;
    }
    BOOL isReachable = flags & kSCNetworkFlagsReachable;
    BOOL needsConnection = flags & kSCNetworkFlagsConnectionRequired;
    return (isReachable && !needsConnection) ? YES : NO;
}

@end


@implementation UIFont (Utils)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

+ (UIFont *)systemFontOfSize:(CGFloat)size
{
	return [UIFont fontWithName:@"Avenir-Medium" size:size];
}

+ (UIFont *)lightSystemFontOfSize:(CGFloat)size
{
	return [UIFont fontWithName:@"Avenir-Light" size:size];
}

+ (UIFont *)boldSystemFontOfSize:(CGFloat)size
{
	return [UIFont fontWithName:@"Avenir-Heavy" size:size];
}

#pragma clang diagnostic pop

@end


@implementation MaskAutoAdjustingView

- (void)setFrame:(CGRect)frame
{
	[super setFrame:frame];
	self.layer.mask.frame = self.bounds;
}

@end
