//
//  EventDetailViewController.h
//  Hvezdarna
//
//  Created by Michal Zelinka in 2013
//  Copyright (c) 2013- Michal Zelinka. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Event;


@interface EventDetailViewController : UIViewController

@property (nonatomic, strong) Event *event;

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UILabel *eventTitle;
@property (nonatomic, strong) IBOutlet UITextView *shortDescription;
@property (nonatomic, strong) IBOutlet UITextView *longDescription;
@property (nonatomic, strong) IBOutlet UIView *infoView;
@property (nonatomic, strong) IBOutlet UIView *detailsView;
@property (nonatomic, strong) IBOutlet UILabel *price;
@property (nonatomic, strong) IBOutlet UILabel *date;
@property (nonatomic, strong) IBOutlet UILabel *time;

@end
