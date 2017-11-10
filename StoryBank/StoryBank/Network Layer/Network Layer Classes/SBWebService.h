//
//  SBWebService.h
//  StoryBank
//
//  Created by Lakhpat Meena on 11/4/17.
//  Copyright © 2017 OutBloom. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AFHTTPSessionManager;

@interface SBWebService : NSObject {
    
    NSString *_httpMethodName;
    NSString *_urlEndPointString;
    NSString *_parameters;
    NSString *_baseURL;
    NSTimeInterval _timeOutTimeInterval;
    
    NSURLSessionTask *_currentTask;
    AFHTTPSessionManager *_sessionManager;
}

- (instancetype)initWithMethod:(NSString *)method parameters:(NSString *)parameters endpointUrlString:(NSString *)endpointUrlString andBaseURL:(NSString *)baseURL;


/* This method is called to start the web service. */
- (void)resume;

/* This method is called to cancel the web service. */
- (void)cancel;


/* This method is called to get sessionManager. Subclasses can override this method to allow custom creation of sessionManager. */
- (AFHTTPSessionManager *)sessionManager;

/* This method is called to get header fields. Subclasses can override this method by definately calling super first and then setting their own header fields. */
- (NSDictionary *)httpHeaderFields;

/* This method is declared in interface file for the visibility to subclasses and so that they can override it. This method should not be called explicitly by an external object. */
- (void)handleSuccessWithSessionDataTask:(NSURLSessionDataTask *)task andResponseObject:(id)responseObject;

/* This method is declared in interface file for the visibility to subclasses and so that they can override it. This method should not be called explicitly by an external object. */
- (void)handleFailureWithSessionDataTask:(NSURLSessionDataTask *)task andWebServiceError:(NSError *)webServiceError;

@end
