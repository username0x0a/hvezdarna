//
//  Event.m
//  Hvezdarna
//
//  Created by Michal Zelinka in 2013
//  Copyright (c) 2013- Michal Zelinka. All rights reserved.
//

#import "Event.h"
#import "NSObject+Parsing.h"

@implementation Event

+ (instancetype)eventFromDictionary:(NSDictionary *)dictionary
{
	return [[self alloc] initFromDictionary:dictionary];
}

- (instancetype)initFromDictionary:(NSDictionary *)dictionary
{
	if (self = [super init])
	{
		dictionary = [dictionary dictionaryExcludingNSNull];

		_ID = [dictionary[@"id"] parsedNumber].unsignedIntegerValue;
		_title = [dictionary[@"name"] parsedString];

		if (!_ID || !_title) return nil;

		_longDescription = [dictionary[@"desc"] parsedString];
		_shortDescription = [dictionary[@"short_desc"] parsedString];
		_day = [dictionary[@"day"] parsedNumber].integerValue;
		_timestamp = [dictionary[@"time"] parsedNumber].integerValue;
		_price = [dictionary[@"price"] parsedString];
		_link = [dictionary[@"link"] parsedString];
		_opts = [[dictionary[@"opts"] parsedString]
			componentsSeparatedByString:@"|"] ?: @[ ];
	}

	return self;
}

@end
