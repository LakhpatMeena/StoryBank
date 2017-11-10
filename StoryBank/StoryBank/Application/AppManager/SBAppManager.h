//
//  SBAppManager.h
//  StoryBank
//
//  Created by Lakhpat Meena on 11/4/17.
//  Copyright © 2017 OutBloom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SBAppManager : NSObject

/* This method returns the current status of availability of internet. */
+ (BOOL)isInternetConnectionAvailable;
+ (NSDate *)getDateFromTimeInterval:(NSTimeInterval)timeInterval;
+ (NSString *)stringFromNSDate:(NSDate *)date;
+ (int)minutesDifferenceBetweenDate1:(NSDate *)date1 andDate2:(NSDate *)date2;

@end
