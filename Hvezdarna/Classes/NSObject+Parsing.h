//
//  NSObject+Parsing.h
//  Tripomatic
//
//  Created by Michal Zelinka on 03/09/15.
//  Copyright (c) 2015 Tripomatic. All rights reserved.
//

#import <Foundation/Foundation.h>

// -----------------------------------------------------------------------
/// @name Parsing helpers
// -----------------------------------------------------------------------

@interface NSObject (Parsing)

@property (nonatomic, readonly) NSArray *parsedArray;
@property (nonatomic, readonly) NSDictionary *parsedDictionary;
@property (nonatomic, readonly) NSString *parsedString;
@property (nonatomic, readonly) NSNumber *parsedNumber;

- (id)parsedKindOfClass:(Class)cls;

// TODO: publish with alternative accessory methods on top?
//- (id)objectForKeyedSubscript:(id)key;
//- (id)objectAtIndexedSubscript:(NSUInteger)idx;

@end

// -----------------------------------------------------------------------
/// @name Parsing macros
// -----------------------------------------------------------------------

// Object macros
NS_INLINE id objectOrNull(id obj)  { return obj ?: [NSNull null]; }

// String macros
#define nonEmptyString(str)               [str parsedString]

// Number macros
#define numberOrNil(number)               [number parsedNumber]

// Dictionary macros
#define dictionaryOrNil(dict)             [dict parsedDictionary]

// Array macros
#define arrayOrNil(array)                 [array parsedArray]

// -----------------------------------------------------------------------
/// @name Copying protocols type preservation
// -----------------------------------------------------------------------

@interface NSString (CopyingTypePreserve)

- (NSString *)copy;
- (NSMutableString *)mutableCopy;

@end

@interface NSArray<ObjectType> (CopyingTypePreserve)

- (NSArray<ObjectType> *)copy;
- (NSMutableArray<ObjectType> *)mutableCopy;

@end

@interface NSSet<ObjectType> (CopyingTypePreserve)

- (NSSet<ObjectType> *)copy;
- (NSMutableSet<ObjectType> *)mutableCopy;

@end

@interface NSDictionary<KeyType, ObjectType> (CopyingTypePreserve)

- (NSDictionary<KeyType, ObjectType> *)copy;
- (NSMutableDictionary<KeyType, ObjectType> *)mutableCopy;

@end
