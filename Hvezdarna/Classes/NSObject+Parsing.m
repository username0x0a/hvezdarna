//
//  NSObject+Parsing.m
//  Tripomatic
//
//  Created by Michal Zelinka on 03/09/15.
//  Copyright (c) 2015 Tripomatic. All rights reserved.
//

#import "NSObject+Parsing.h"


@implementation NSObject (Parsing)

- (id)parsedArray
{
	return ([self isKindOfClass:[NSArray class]]) ? self : nil;
}

- (id)parsedDictionary
{
	return ([self isKindOfClass:[NSDictionary class]]) ? self : nil;
}

- (id)parsedString
{
	return ([self isKindOfClass:[NSString class]] && ((NSString *)self).length) ? self : nil;
}

- (id)parsedNumber
{
	return ([self isKindOfClass:[NSNumber class]]) ? self : nil;
}

- (id)parsedKindOfClass:(Class)cls
{
	return ([self isKindOfClass:cls]) ? self : nil;
}

- (id)objectAtIndexedSubscript:(NSUInteger)idx
{
	return nil;
}

- (id)objectForKeyedSubscript:(id)key
{
	return nil;
}

@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"

@implementation NSString (CopyingTypePreserve) @end

@implementation NSArray (CopyingTypePreserve) @end

@implementation NSSet (CopyingTypePreserve) @end

@implementation NSDictionary (CopyingTypePreserve) @end

#pragma clang diagnostic pop
