//
//  AboutObservatoryViewController.h
//  Hvezdarna
//
//  Created by Michal Zelinka in 2013
//  Copyright (c) 2013- Michal Zelinka. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AboutObservatoryViewController : UIViewController

@property (nonatomic, strong) IBOutlet UIImageView *backgroundView;
@property (nonatomic, strong) IBOutlet UIView *textContentView;
@property (nonatomic, strong) IBOutlet UITextView *textField;
@property (nonatomic, strong) IBOutlet UIButton *webButton;

- (IBAction)webButtonTapped:(id)sender;

@end
