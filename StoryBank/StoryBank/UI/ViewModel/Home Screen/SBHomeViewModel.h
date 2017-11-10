//
//  SBHomeViewModel.h
//  StoryBank
//
//  Created by Lakhpat Meena on 11/4/17.
//  Copyright © 2017 OutBloom. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SBHomeViewModel;
@class SBStory;

@protocol SBHomeViewModelDelegate

- (void)successfullyFetchedStoryItemsWithHomeViewModel:(SBHomeViewModel *)homeViewModel;
- (void)homeViewModel:(SBHomeViewModel *)homeViewModel failedToFetchStoryItemsWithWebServiceError:(NSError *)error;
- (void)noMoreItemsToLoadWithHomeViewModel:(SBHomeViewModel *)homeViewModel;

@end

@interface SBHomeViewModel : NSObject

@property (nonatomic, weak) id <SBHomeViewModelDelegate> homeViewModelDelegate;
@property (nonatomic, assign) BOOL isAPIRequestInProgress;

- (void)fetchInitialStoryItems;
- (void)fetchNextStoryItems;
- (void)refreshStoriesData;
- (NSInteger)getTotalStoryItemsCount;
- (SBStory *)storyAtIndex:(NSInteger)index;
- (void)updateReadStatusOfStoryAtIndex:(NSInteger)index;
- (void)searchProjectsWithString:(NSString *)text;
- (void)endSearchingStoryItems;

@end
