//
//  SBAppManager.m
//  StoryBank
//
//  Created by Lakhpat Meena on 11/4/17.
//  Copyright © 2017 OutBloom. All rights reserved.
//

#import "SBAppManager.h"
#import "Reachability.h"

@implementation SBAppManager

#pragma mark - Public Methods
+ (BOOL)isInternetConnectionAvailable {
    
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        return NO;
    } else {
        return YES;
    }
}

+ (NSDate *)getDateFromTimeInterval:(NSTimeInterval)timeInterval {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    return date;
}

+ (NSString *)stringFromNSDate:(NSDate *)date {
    
    NSString *dateFormat = @"dd MMM yyyy, hh.mm a";
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:dateFormat];
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    
    NSString *dateString = nil;
    
    if ([dateFormatter stringFromDate:date] != nil) {
        
        dateString = [dateFormatter stringFromDate:date];
        return dateString;
    }
    
    return dateString;
}

+ (int)minutesDifferenceBetweenDate1:(NSDate *)date1 andDate2:(NSDate *)date2 {
    
    NSTimeInterval diffInterval = [date1 timeIntervalSinceDate:date2];
    int minutes = diffInterval / 60;
    return minutes;
}


@end
