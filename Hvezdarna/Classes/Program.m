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

@synthesize title           = _title;
@synthesize description     = _description;
@synthesize day             = _day;
@synthesize timestamp       = _timestamp;
@synthesize price           = _price;
@synthesize link            = _link;
@synthesize opts            = _opts;

+(id)programWithTitle:(NSString*)title description:(NSString*)description day:(NSInteger)day timestamp:(NSInteger)timestamp price:(NSString*)price link:(NSString*)link opts:(NSString*)opts {
    
    Program *program = [[Program alloc] init];
    
    [program setTitle:title];
    [program setDescription:description];
	[program setDay:day];
    [program setTimestamp:timestamp];
    [program setPrice:price];
    [program setLink:link];
	[program setOpts:[opts componentsSeparatedByString:@"|"]];
    
    return program;
}

- (NSString*)smallDescription {
    
    if ([self.description length] > kSmallTextLength)
        return [[self description] stringByPaddingToLength:kSmallTextLength withString:@"…" startingAtIndex:0];
	else
		return [self description];
}

@end
