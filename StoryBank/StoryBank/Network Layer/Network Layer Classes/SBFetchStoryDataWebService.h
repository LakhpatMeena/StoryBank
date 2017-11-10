//
//  SBFetchStoryDataWebService.h
//  StoryBank
//
//  Created by Lakhpat Meena on 11/4/17.
//  Copyright © 2017 OutBloom. All rights reserved.
//

#import "SBWebService.h"

@class SBFetchStoryDataWebService;
@class SBStory;

@protocol SBFetchStoryDataWebServiceDelegate

- (void)fetchStoryDataWebService:(SBFetchStoryDataWebService *)webService successfullyFetchedStoryData:(SBStory *)story;

- (void)fetchStoryDataWebService:(SBFetchStoryDataWebService *)webService failedToFetchStoryDataWithWebServiceError:(NSError *)error;

@end

@interface SBFetchStoryDataWebService : SBWebService

@property (nonatomic, readonly) NSString *storyId;
@property (nonatomic, weak) id <SBFetchStoryDataWebServiceDelegate> fetchStoryDataWebServiceDelegate;

- (instancetype)initWithStoryId:(NSString *)storyId;

@end
