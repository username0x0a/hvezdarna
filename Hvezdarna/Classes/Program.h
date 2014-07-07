//
//  Program.h
//  Hvezdarna
//
//  Created by Michal Zelinka in 2013
//  Copyright (c) 2013- Michal Zelinka. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Program : NSObject

@property (nonatomic,retain) NSString *title;
@property (nonatomic,retain) NSString *description;
@property (nonatomic) NSInteger day;
@property (nonatomic) NSInteger timestamp;
@property (nonatomic,retain) NSString *price;
@property (nonatomic,retain) NSString *link;
@property (nonatomic,retain) NSArray *opts;

+ (id) programWithTitle:(NSString*)title description:(NSString*)description day:(NSInteger)day timestamp:(NSInteger)timestamp price:(NSString*)price link:(NSString*)link opts:(NSString*)opts;

- (NSString*)smallDescription;

@end
