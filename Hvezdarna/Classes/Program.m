//
//  Program.m
//  Hvezdarna
//
//  Created by Michal Zelinka in 2013
//  Copyright (c) 2013- Michal Zelinka. All rights reserved.
//

#import "Program.h"

#define kSmallTextLength 100

@implementation Program

+ (instancetype)programFromDictionary:(NSDictionary *)dictionary
{
	return [[self alloc] initFromDictionary:dictionary];
}

- (instancetype)initFromDictionary:(NSDictionary *)dictionary
{
	if (self = [super init])
	{
		dictionary = [dictionary dictionaryExcludingNSNull];

		_ID = [dictionary[@"id"] integerValue];
		_title = dictionary[@"name"];
		_longDescription = dictionary[@"desc"];
		_shortDescription = dictionary[@"short_desc"];
		_day = [dictionary[@"day"] integerValue];
		_timestamp = [dictionary[@"time"] integerValue];
		_price = dictionary[@"price"];
		_link = dictionary[@"link"];
		_opts = [dictionary[@"opts"] componentsSeparatedByString:@"|"];
	}

	return self;
}

- (NSString *)smallDescription
{
    if (_longDescription.length > kSmallTextLength)
        return [[_longDescription substringToIndex:kSmallTextLength ] stringByAppendingString:@"…"];

	return _longDescription;
}

@end
