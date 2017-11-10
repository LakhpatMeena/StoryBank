//
//  SBStory.m
//  StoryBank
//
//  Created by Lakhpat Meena on 11/4/17.
//  Copyright © 2017 OutBloom. All rights reserved.
//

#import "SBStory.h"
#import "NSString+ValidString.h"
#import "SBAppManager.h"
#import "CDStory+CoreDataClass.h"

@implementation SBStory

- (instancetype)initWithStoryData:(NSDictionary *)storyDict {
    self = [super init];
    if (self) {
        _itemId = [[storyDict valueForKey:@"id"] integerValue];
        _score = [[storyDict valueForKey:@"score"] integerValue];
        _title = [[storyDict valueForKey:@"title"] validAndNotEmptyStringObject];
        _time = [SBAppManager getDateFromTimeInterval:[[storyDict valueForKey:@"time"] doubleValue]];
        _type = [[storyDict valueForKey:@"type"] validAndNotEmptyStringObject];
        _by = [[storyDict valueForKey:@"by"] validAndNotEmptyStringObject];
        _url = [[storyDict valueForKey:@"url"] validAndNotEmptyStringObject];
        _readStatus = SBStoryStatusUnread;
    }
    return self;
}

- (instancetype)initWithPersistentData:(CDStory *)story {
    self = [super init];
    if (self) {
        _itemId = story.itemId;
        _score = story.score;
        _title = story.title;
        _time = story.time;
        _type = story.type;
        _by = story.by;
        _url = story.url;
        _readStatus = story.readStatus;
    }
    return self;
}

@end
