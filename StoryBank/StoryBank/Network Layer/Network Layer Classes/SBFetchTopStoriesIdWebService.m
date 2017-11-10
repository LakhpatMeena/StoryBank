//
//  SBFetchTopStoriesIdWebService.m
//  StoryBank
//
//  Created by Lakhpat Meena on 11/4/17.
//  Copyright © 2017 OutBloom. All rights reserved.
//

#import "SBFetchTopStoriesIdWebService.h"
#import "SBAppConstants.h"

@implementation SBFetchTopStoriesIdWebService

- (instancetype)init {
    NSString *endPointURLString = @"v0/topstories.json";
    self = [super initWithMethod:@"GET" parameters:nil endpointUrlString:endPointURLString andBaseURL:kBaseURLDev];
    return self;
}

- (void)handleSuccessWithSessionDataTask:(NSURLSessionDataTask *)task andResponseObject:(id)responseObject {
    [super handleSuccessWithSessionDataTask:task andResponseObject:responseObject];
    
    if ([responseObject isKindOfClass:[NSArray class]]) {
        
        [self.fetchTopStoriesIdWebServiceDelegate fetchTopStoriesIdWebService:self successfullyFetchedTopStoriesData:responseObject];
    } else {
        
        [self.fetchTopStoriesIdWebServiceDelegate fetchTopStoriesIdWebService:self failedToFetchTopStoriesDataWithWebServiceError:[NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorBadServerResponse userInfo:nil]];
    }
}

- (void)handleFailureWithSessionDataTask:(NSURLSessionDataTask *)task andWebServiceError:(NSError *)webServiceError {
    [super handleFailureWithSessionDataTask:task andWebServiceError:webServiceError];
    
    [self.fetchTopStoriesIdWebServiceDelegate fetchTopStoriesIdWebService:self failedToFetchTopStoriesDataWithWebServiceError:webServiceError];
}

@end
