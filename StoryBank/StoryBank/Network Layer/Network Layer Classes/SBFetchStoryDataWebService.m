//
//  SBFetchStoryDataWebService.m
//  StoryBank
//
//  Created by Lakhpat Meena on 11/4/17.
//  Copyright © 2017 OutBloom. All rights reserved.
//

#import "SBFetchStoryDataWebService.h"
#import "SBAppConstants.h"
#import "SBStory.h"

@implementation SBFetchStoryDataWebService

- (instancetype)initWithStoryId:(NSString *)storyId {
    NSString *endPointURLString = [NSString stringWithFormat:@"v0/item/%@.json", storyId];
    self = [super initWithMethod:@"GET" parameters:nil endpointUrlString:endPointURLString andBaseURL:kBaseURLDev];
    
    if (self) {
        
        _storyId = [storyId copy];
    }
    
    return self;
}

- (void)handleSuccessWithSessionDataTask:(NSURLSessionDataTask *)task andResponseObject:(id)responseObject {
    [super handleSuccessWithSessionDataTask:task andResponseObject:responseObject];
    
    if ([responseObject isKindOfClass:[NSDictionary class]]) {
        
        if ([responseObject valueForKey:@"id"]) {
            
            SBStory *story = [[SBStory alloc] initWithStoryData:responseObject];
            [self.fetchStoryDataWebServiceDelegate fetchStoryDataWebService:self successfullyFetchedStoryData:story];
        } else {
            [self.fetchStoryDataWebServiceDelegate fetchStoryDataWebService:self failedToFetchStoryDataWithWebServiceError:[NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorBadServerResponse userInfo:nil]];
        }
    } else {
        [self.fetchStoryDataWebServiceDelegate fetchStoryDataWebService:self failedToFetchStoryDataWithWebServiceError:[NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorBadServerResponse userInfo:nil]];
    }
}

- (void)handleFailureWithSessionDataTask:(NSURLSessionDataTask *)task andWebServiceError:(NSError *)webServiceError {
    [super handleFailureWithSessionDataTask:task andWebServiceError:webServiceError];
    [self.fetchStoryDataWebServiceDelegate fetchStoryDataWebService:self failedToFetchStoryDataWithWebServiceError:webServiceError];
}

@end
