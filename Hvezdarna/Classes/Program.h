//
//  Program.h
//  Hvezdarna
//
//  Created by Michal Zelinka in 2013
//  Copyright (c) 2013- Michal Zelinka. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Program : NSObject

@property (atomic) NSInteger ID;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *shortDescription;
@property (nonatomic, copy) NSString *longDescription;
@property (atomic) NSInteger day;
@property (atomic) NSInteger timestamp;
@property (nonatomic, copy) NSString *price;
@property (nonatomic, copy) NSString *link;
@property (nonatomic, strong) NSArray *opts;

+ (instancetype)programFromDictionary:(NSDictionary *)dictionary;
- (instancetype)initFromDictionary:(NSDictionary *)dictionary;

- (NSString *)smallDescription;

@end
