//
//  EventDetailCellView.h
//  Hvezdarna
//
//  Created by Michal Zelinka in 2013
//  Copyright (c) 2013- Michal Zelinka. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventDetailCellView : UITableViewCell;

@property (nonatomic, strong) IBOutlet UILabel *detailText;

- (void) setTextOfDetail:(NSString *)text;

@end
