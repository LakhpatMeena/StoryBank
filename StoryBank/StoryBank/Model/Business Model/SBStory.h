//
//  SBStory.h
//  StoryBank
//
//  Created by Lakhpat Meena on 11/4/17.
//  Copyright © 2017 OutBloom. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SBStory;
@class CDStory;

typedef NS_ENUM(NSInteger, SBStoryStatus) {
    SBStoryStatusUnread,
    SBStoryStatusRead
};

@interface SBStory : NSObject

@property (nonatomic, assign) NSInteger itemId;
@property (nonatomic, assign) NSInteger score;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSDate *time;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *by;
@property (nonatomic, assign) SBStoryStatus readStatus;

- (instancetype)initWithStoryData:(NSDictionary *)storyDict;
- (instancetype)initWithPersistentData:(CDStory *)story;

@end
