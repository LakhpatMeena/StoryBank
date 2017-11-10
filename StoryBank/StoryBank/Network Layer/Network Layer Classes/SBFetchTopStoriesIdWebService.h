//
//  SBFetchTopStoriesIdWebService.h
//  StoryBank
//
//  Created by Lakhpat Meena on 11/4/17.
//  Copyright © 2017 OutBloom. All rights reserved.
//

#import "SBWebService.h"

@class SBFetchTopStoriesIdWebService;

@protocol SBFetchTopStoriesIdWebServiceDelegate

- (void)fetchTopStoriesIdWebService:(SBFetchTopStoriesIdWebService *)webService successfullyFetchedTopStoriesData:(NSArray *)stories;

- (void)fetchTopStoriesIdWebService:(SBFetchTopStoriesIdWebService *)webService failedToFetchTopStoriesDataWithWebServiceError:(NSError *)error;

@end

@interface SBFetchTopStoriesIdWebService : SBWebService

@property (nonatomic, weak) id <SBFetchTopStoriesIdWebServiceDelegate> fetchTopStoriesIdWebServiceDelegate;

- (instancetype)init;

@end
