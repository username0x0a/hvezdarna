//
//  Utils.m
//  Hvezdarna
//
//  Created by Michal Zelinka in 2013
//  Copyright (c) 2013- Michal Zelinka. All rights reserved.
//

#import <SystemConfiguration/SCNetworkReachability.h>
#if !TARGET_OS_TV
#import <SafariServices/SafariServices.h>
#endif
#import <netinet/in.h>

#import "NSObject+Parsing.h"
#import "Utils.h"

@implementation Utils

+ (NSString *) getValueFromString:(NSString *)data withStarters:(NSArray*)starters andEnding:(NSString *)ending {

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

+ (NSInteger) getDayTimestampFromCustomLocalDate:(NSString *)date {
	
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
	NSDateComponents *now = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
	[dc setYear:[now year]];
	if ([dc month] < [now month]) [dc setYear:[now year]+1];
	[dc setHour:0]; [dc setMinute:0]; [dc setSecond:0];
	NSCalendar *cal = [NSCalendar currentCalendar];
	[cal setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"CET"]];
	[cal setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"cs_CZ"]];
	NSNumber *n = @([[cal dateFromComponents:dc] timeIntervalSince1970]);
	return [n intValue];
}

+ (NSInteger) getDayTimestampFromCustomLocalTime:(NSString *)time {
	NSArray* t = [time componentsSeparatedByString:@":"];
	return [[t objectAtIndex:0] intValue] * 3600 + [[t objectAtIndex:1] intValue] * 60;
}

+ (NSInteger) getLocalDayTimestampFromTimestamp:(NSInteger)timestamp {
	return timestamp / kTimeDayInSeconds * kTimeDayInSeconds;
}

+ (NSTimeInterval) unixTimestamp {
	return [[NSDate date] timeIntervalSince1970];
}

+ (NSString *) getLocalTimeStringFromTimestamp:(NSInteger)timestamp {
	NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp];
	NSCalendar *cal = [NSCalendar currentCalendar];
	[cal setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"CET"]];
	[cal setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"cs_CZ"]];
	NSDateComponents *c = [cal components:NSCalendarUnitHour|NSCalendarUnitMinute fromDate:date];
	return [NSString stringWithFormat:@"%zd.%02zd", c.hour, c.minute];
}

+ (NSString *) getLocalDayOfWeekStringFromTimestamp:(NSInteger)timestamp {
	NSArray *days = @[ @"Pondělí", @"Úterý", @"Středa", @"Čtvrtek", @"Pátek", @"Sobota", @"Neděle" ];
	timestamp += 2 * kTimeHourInSeconds; // UTC->CET max difference
	int idx = (timestamp / kTimeDayInSeconds % 7 + 3) % 7;
	return [days objectAtIndex:idx];
}

+ (NSString *) getLocalDateStringFromTimestamp:(NSInteger)timestamp {
	NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp];
	NSCalendar *cal = [NSCalendar currentCalendar];
	[cal setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"CET"]];
	[cal setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"cs_CZ"]];
	NSDateComponents *c = [cal components:NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear fromDate:date];
	return [NSString stringWithFormat:@"%zd. %@", [c day], [self getLocalMonthNameFromNumber:[c month]]];
}

+ (NSString *) getLocalMoneyValueFromString:(NSString *)price {
	if ([price intValue] > 0) return [NSString stringWithFormat:@"%@ Kč", price];
	else return @"zdarma";
}

+ (NSString *) getLocalUnitValueFromFloat:(float)value {
	NSInteger intValue = [@(value) integerValue];
	if (value == intValue)
		return [NSString stringWithFormat:@"%zd", intValue];
	NSString *ret = [NSString stringWithFormat:@"%.1f", value];
	return [ret stringByReplacingOccurrencesOfString:@"." withString:@","];
}

+ (NSString *) getLocalMonthNameFromNumber:(NSInteger)month {
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

+ (NSString *) getWeatherIconFromConditionString:(NSString *)condition {
	
	// WS-2300 forecast values: "Rainy", "Cloudy", "Sunny"

	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *components = [calendar components:NSCalendarUnitHour fromDate:[NSDate new]];
	NSInteger hour = [components hour];

	BOOL night = hour < 6 || hour >= 22;

	if ([condition isEqualToString:@"Sunny"])
		return (night) ? @"weather-clear_moon" : @"weather-clear_sun";

	if ([condition isEqualToString:@"Cloudy"]) return @"weather-cloudy";
	if ([condition isEqualToString:@"Rainy"]) return @"weather-rain";

	return nil;
}

+ (NSString *) getVerboseStringFromConditionString:(NSString *)condition {

	// WS-2300 forecast values: "Rainy", "Cloudy", "Sunny"

	if ([condition isEqualToString:@"Sunny"])
		return NSLocalizedString(@"Clear", @"Condition");

	if ([condition isEqualToString:@"Cloudy"])
		return NSLocalizedString(@"Cloudy", @"Condition");

	if ([condition isEqualToString:@"Rainy"])
		return NSLocalizedString(@"Rainy", @"Condition");

	return nil;
}

+ (void) openURL:(NSString *)url inDelegate:(UIViewController *)delegate {
#if TARGET_OS_IOS == 1
	NSURL *URL = [NSURL URLWithString:url];

	SFSafariViewController *vc = [[SFSafariViewController alloc] initWithURL:URL];
	vc.modalPresentationStyle = UIModalPresentationPageSheet;
	[delegate.tabBarController presentViewController:vc animated:YES completion:nil];
#endif
}

+ (BOOL) connectionAvailable {
	// Create zero addy
	struct sockaddr_in zeroAddress;
	bzero(&zeroAddress, sizeof(zeroAddress));
	zeroAddress.sin_len = sizeof(zeroAddress);
	zeroAddress.sin_family = AF_INET;
	// Recover reachability flags
	SCNetworkReachabilityRef defaultRouteReachability =
		SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr*)&zeroAddress);
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

+ (UIFont *)lightSystemFontOfSize:(CGFloat)size
{
	if ([UIFont respondsToSelector:@selector(systemFontOfSize:weight:)])
		return [UIFont systemFontOfSize:size weight:UIFontWeightLight];
	return [UIFont systemFontOfSize:size];
}

@end


@implementation UIImage (Utils)

+ (UIImage *)pixelImageWithColor:(UIColor *)color
{
	CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
	UIGraphicsBeginImageContext(rect.size);
	CGContextRef context = UIGraphicsGetCurrentContext();

	CGContextSetFillColorWithColor(context, [color CGColor]);
	CGContextFillRect(context, rect);

	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

	return image;
}

@end


@implementation UILabel (Utils)

- (CGSize)expandedSize
{
	return [self sizeThatFits:CGSizeMake(self.width, CGFLOAT_MAX)];
}

@end


@implementation UITextView (Utils)

- (CGSize)expandedSize
{
	return [self sizeThatFits:CGSizeMake(self.width, CGFLOAT_MAX)];
}

@end


@implementation NSDictionary (Utils)

- (NSDictionary *)dictionaryExcludingNSNull
{
	NSMutableDictionary *mutable = [self mutableCopy];
	NSMutableArray *keysToRemove = [NSMutableArray array];

	for (NSString *key in self.allKeys)
		if ([self[key] isKindOfClass:[NSNull class]])
			[keysToRemove addObject:key];

	[mutable removeObjectsForKeys:keysToRemove];

	return [mutable copy];
}

@end


@implementation UIView (Utils)

- (NSArray<__kindof UIView *> *)allSubviews
{
	NSMutableArray *all = [NSMutableArray array];

	[all addObjectsFromArray:self.subviews];

	for (UIView *v in self.subviews)
		[all addObjectsFromArray:v.allSubviews];

	return all;
}

- (NSArray<__kindof UIView *> *)viewsForClass:(Class)cls
{
	NSMutableArray<__kindof UIView *> *views = [NSMutableArray array];

	for (UIView *v in self.subviews)
	{
		if ([v parsedKindOfClass:cls])
			[views addObject:v];

		[views addObjectsFromArray:[v viewsForClass:cls]];
	}

	return views;
}

@end


@implementation MaskAutoAdjustingView

- (void)setFrame:(CGRect)frame
{
	[super setFrame:frame];
	self.layer.mask.frame = self.bounds;
}

@end
