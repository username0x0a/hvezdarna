//
//  WeatherViewModel.h
//  Hvezdarna
//
//  Created by Michi on 28/02/2020.
//  Copyright © 2020 Heartpix. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WeatherData : NSObject

@property (atomic) double temperature;
@property (atomic) double windSpeed;
@property (atomic) NSUInteger pressure;
@property (atomic) NSUInteger humidity;

@end

@interface WeatherViewModel : NSObject

- (void)checkWeatherDataWithCompletion:(void (^)(WeatherData *_Nullable data, BOOL updated))completion;
- (void)checkCameraImageWithCompletion:(void (^)(NSData *_Nullable data))completion;

@end

NS_ASSUME_NONNULL_END
