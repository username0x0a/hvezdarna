//
//  Event.h
//  Hvezdarna
//
//  Created by Michal Zelinka in 2013
//  Copyright (c) 2013- Michal Zelinka. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Event : NSObject

@property (atomic) NSUInteger ID;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy, nullable) NSString *shortDescription;
@property (nonatomic, copy, nullable) NSString *longDescription;
@property (atomic) NSInteger day;
@property (atomic) NSInteger timestamp;
@property (nonatomic, copy, nullable) NSString *price;
@property (nonatomic, copy, nullable) NSString *link;
@property (nonatomic, strong) NSArray *opts;

+ (nullable instancetype)eventFromDictionary:(NSDictionary *)dictionary;
- (nullable instancetype)initFromDictionary:(NSDictionary *)dictionary;

@end

NS_ASSUME_NONNULL_END
