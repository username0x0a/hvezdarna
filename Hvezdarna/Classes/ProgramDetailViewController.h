//
//  ProgramDetailViewController.h
//  Hvezdarna
//
//  Created by Michal Zelinka in 2013
//  Copyright (c) 2013- Michal Zelinka. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RTLabel.h"

@class Program;

@interface ProgramDetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (nonatomic,retain) Program *program;
@property (nonatomic,retain) IBOutlet UILabel *choose_event;
@property (nonatomic,retain) IBOutlet UIView *content_view;
@property (nonatomic,retain) IBOutlet UIScrollView *scroll_view;
@property (nonatomic,retain) IBOutlet UILabel *event_title;
@property (nonatomic,retain) IBOutlet RTLabel *description;
@property (nonatomic,retain) IBOutlet UIView *info_view;
@property (nonatomic,retain) IBOutlet UIView *details_view;
@property (nonatomic,retain) IBOutlet UILabel *price;
@property (nonatomic,retain) IBOutlet UILabel *price_label;
@property (nonatomic,retain) IBOutlet UILabel *date;
@property (nonatomic,retain) IBOutlet UILabel *time;

- (void)openLink;
@end
