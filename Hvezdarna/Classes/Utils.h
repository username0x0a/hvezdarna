//
//  Utils.h
//  Hvezdarna
//
//  Created by Michal Zelinka in 2013
//  Copyright (c) 2013- Michal Zelinka. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

enum {
    UtilsWebBrowserNavigation = 0,
    UtilsWebBrowserModal
};

typedef NSUInteger UtilsWebBrowserStyle;


@interface Utils : NSObject

+ (NSString *) getValueFromString:(NSString *)data withStarters:(NSArray*)starters andEnding:(NSString *)ending;
+ (NSInteger) getDayTimestampFromCustomLocalDate:(NSString *)date;
+ (NSInteger) getDayTimestampFromCustomLocalTime:(NSString *)time;
+ (NSInteger) getLocalDayTimestampFromTimestamp:(NSInteger)timestamp;
+ (NSTimeInterval) unixTimestamp;
+ (NSString *) getLocalTimeStringFromTimestamp:(NSInteger)timestamp;
+ (NSString *) getLocalDateStringFromTimestamp:(NSInteger)timestamp;
+ (NSString *) getLocalMoneyValueFromString:(NSString *)price;
+ (NSString *) getLocalUnitValueFromFloat:(float)value;
+ (NSString *) getLocalDayOfWeekStringFromTimestamp:(NSInteger)timestamp;
+ (NSString *) getVerboseStringFromConditionString:(NSString *)condition;
+ (NSString *) getWeatherIconFromConditionString:(NSString *)condition;
+ (void) openURL:(NSString *)url inDelegate:(UIViewController *)delegate withStyle:(UtilsWebBrowserStyle)style;
+ (BOOL) connectionAvailable;

@end


@interface UIFont (Utils)

+ (UIFont *)systemFontOfSize:(CGFloat)size;
+ (UIFont *)lightSystemFontOfSize:(CGFloat)size;
+ (UIFont *)boldSystemFontOfSize:(CGFloat)size;
+ (UIFont *)preferredFontForTextStyle:(NSString *)style;

@end


@interface UIImage (Utils)

+ (UIImage *)pixelImageWithColor:(UIColor *)color;

@end


@interface NSDictionary (Utils)

- (NSDictionary *)dictionaryExcludingNSNull;

@end


@interface UIView (UTils)

- (NSArray *)allSubviews;

@end


@interface MaskAutoAdjustingView : UIView
@end
