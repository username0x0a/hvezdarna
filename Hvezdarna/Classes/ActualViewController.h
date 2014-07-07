//
//  AktualneViewController.h
//  Hvezdarna
//
//  Created by Michal Zelinka in 2013
//  Copyright (c) 2013- Michal Zelinka. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UICustomButton;


@interface ActualViewController : UIViewController <UIScrollViewDelegate>

@property (nonatomic, strong) IBOutlet UIImageView *backgroundView;

@property (nonatomic, strong) IBOutlet UILabel *temperatureHeadingLabel;
@property (nonatomic, strong) IBOutlet UILabel *temperatureLabel;

@property (nonatomic, strong) IBOutlet UILabel *windSpeedHeadingLabel;
@property (nonatomic, strong) IBOutlet UILabel *windSpeedLabel;
@property (nonatomic, strong) IBOutlet UILabel *humidityHeadingLabel;
@property (nonatomic, strong) IBOutlet UILabel *humidityLabel;
@property (nonatomic, strong) IBOutlet UILabel *pressureHeadingLabel;
@property (nonatomic, strong) IBOutlet UILabel *pressureLabel;

@property (nonatomic, strong) IBOutlet UIImageView *conditionImage;

@end
