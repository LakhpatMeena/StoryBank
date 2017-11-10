//
//  SBStoryDetailsViewController.h
//  StoryBank
//
//  Created by Lakhpat Meena on 11/6/17.
//  Copyright © 2017 OutBloom. All rights reserved.
//

#import "SBBaseViewController.h"

@interface SBStoryDetailsViewController : SBBaseViewController

@property (nonatomic, strong) NSString *currentURLString;
+ (instancetype)getStoryDetailsViewController;

@end
