//
//  NSString+ValidString.m
//  StoryBank
//
//  Created by Lakhpat Meena on 11/4/17.
//  Copyright © 2017 OutBloom. All rights reserved.
//

#import "NSString+ValidString.h"

@implementation NSString (ValidString)

- (NSString *)validAndNotEmptyStringObject {
    NSString *validAndNotEmptyString = nil;
    
    if([self isKindOfClass:[NSString class]])
    {
        if(![[(NSString *)self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""])
        {
            return (NSString *)self;
        }
    }
    
    return validAndNotEmptyString;
}

@end
