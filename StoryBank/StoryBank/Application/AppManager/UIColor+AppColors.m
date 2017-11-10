//
//  UIColor+AppColors.m
//  StoryBank
//
//  Created by Lakhpat Meena on 11/4/17.
//  Copyright © 2017 OutBloom. All rights reserved.
//

#import "UIColor+AppColors.h"

@implementation UIColor (AppColors)

+ (instancetype)getDarkOrangeColor {
    
    UIColor *darkOrangeColor = [UIColor colorWithRed:241/255.0 green:105/255.0 blue:80/255.0 alpha:1.0];
    return darkOrangeColor;
}

+ (instancetype)getLightBlackColor {
    
    UIColor *lightBlackColor = [UIColor colorWithRed:34/255.0 green:34/255.0 blue:34/255.0 alpha:1.0];
    return lightBlackColor;
}

@end
