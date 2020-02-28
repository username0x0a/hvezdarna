//
//  EventsListSectionView.h
//  Hvezdarna
//
//  Created by Michal Zelinka in 2013
//  Copyright (c) 2013- Michal Zelinka. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventsListSectionView : UIView

@property (nonatomic, strong) UILabel *title;

- (void)setTitleText:(NSString *)text;

@end
