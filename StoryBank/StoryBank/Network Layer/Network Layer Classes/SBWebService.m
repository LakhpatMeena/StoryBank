//
//  SBWebService.m
//  StoryBank
//
//  Created by Lakhpat Meena on 11/4/17.
//  Copyright © 2017 OutBloom. All rights reserved.
//

#import "SBWebService.h"
#import "AFNetworking.h"
#import "SBAppConstants.h"
#import "SBAppManager.h"

@implementation SBWebService

- (instancetype)initWithMethod:(NSString *)method parameters:(NSString *)parameters endpointUrlString:(NSString *)endpointUrlString andBaseURL:(NSString *)baseURL {
    self = [super init];
    if(self)
    {
        _httpMethodName = [method copy];
        _parameters = [parameters copy];
        _urlEndPointString = [endpointUrlString copy];
        _baseURL = [baseURL copy];
        _timeOutTimeInterval = kSBWebServiceRequestTimeOut;
    }
    return self;
}

- (void)dealloc {
    [_sessionManager invalidateSessionCancelingTasks:YES];
    _sessionManager = nil;
}

#pragma mark - Public Methods
- (void)resume {
    [self cancel];
    _currentTask = [self dataTask];
    
    if(_currentTask != nil) {
        NSLog(@"Starting webservice with URL: %@", [[_currentTask currentRequest] URL]);
        [_currentTask resume];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSLog(@"Unable to start webservice with URL: %@ because dataTask was not properly created.", [[_currentTask currentRequest] URL]);
            
            [self handleFailureWithSessionDataTask:(NSURLSessionDataTask *)_currentTask andWebServiceError:[[NSError alloc] initWithDomain:NSURLErrorDomain code:NSURLErrorBadURL userInfo:nil]];
            
            [self cancel];
        });
    }
    
}

- (void)cancel {
    if(_currentTask) {
        NSLog(@"Cancelling webservice with URL: %@", [[_currentTask currentRequest] URL]);
        NSURLSessionTask *task = _currentTask;
        _currentTask = nil;
        [task cancel];
    }
}


#pragma mark - Helper Methods For Prepration Of The NSURLSessionTask

- (AFHTTPSessionManager *)sessionManager {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:_baseURL] sessionConfiguration:configuration];
    [manager.requestSerializer setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    [manager.requestSerializer setTimeoutInterval:_timeOutTimeInterval];
    
    return manager;
}

- (NSDictionary *)httpHeaderFields {
    return nil;
}

#pragma mark - Private Helper Methods

- (NSURLSessionTask *)dataTask {
    //Setting up AFHTTPSessionManager
    AFHTTPSessionManager *sessionManager = [self getSessionManagerForRequestTask];
    
    //Setting up header fields
    NSDictionary *headerFields = [self httpHeaderFields];
    if(headerFields)
    {
        for(NSString *key in headerFields)
        {
            [sessionManager.requestSerializer setValue:[headerFields valueForKey:key] forHTTPHeaderField:key];
        }
    }
    
    NSURLSessionTask *dataTask = [self taskWithSessionManager:sessionManager methodName:_httpMethodName urlEndPointString:_urlEndPointString parameters:_parameters];
    return dataTask;
}

- (AFHTTPSessionManager *)getSessionManagerForRequestTask {
    if(_sessionManager == nil) {
        _sessionManager = [self sessionManager];
    }
    
    return _sessionManager;
}


- (NSURLSessionTask *)taskWithSessionManager:(AFHTTPSessionManager *)sessionManager methodName:(NSString *)methodName urlEndPointString:(NSString *)urlEndPointString parameters:(NSString *)parameters {
    NSURLSessionTask *task = nil;
    
    if([methodName isEqualToString:@"GET"]) {
        task = [sessionManager GET:urlEndPointString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            if(task != _currentTask)
            {
                return;
            }
            
            [self handleSuccessWithSessionDataTask:task andResponseObject:responseObject];
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            if(task != _currentTask)
            {
                return ;
            }
            
            NSError *newErrorObject = [NSError errorWithDomain:error.domain code:error.code userInfo:nil];
            
            [self handleFailureWithSessionDataTask:task andWebServiceError:newErrorObject];
        }];
    } else if([methodName isEqualToString:@"POST"]) {
        task = [sessionManager POST:urlEndPointString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            if(task != _currentTask)
            {
                return ;
            }
            
            [self handleSuccessWithSessionDataTask:task andResponseObject:responseObject];
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            if(task != _currentTask)
            {
                return ;
            }
            
            NSError *newErrorObject = [NSError errorWithDomain:error.domain code:error.code userInfo:nil];
            
            [self handleFailureWithSessionDataTask:task andWebServiceError:newErrorObject];
            [self cancel];
        }];
    }
    
    return task;
}


#pragma mark - Response Handling Private Methods

- (void)handleSuccessWithSessionDataTask:(NSURLSessionDataTask *)task andResponseObject:(id)responseObject {
    NSLog(@"Webservice with URL: %@ finished.", [[task currentRequest] URL]);
}


- (void)handleFailureWithSessionDataTask:(NSURLSessionDataTask *)task andWebServiceError:(NSError *)webServiceError {
    NSLog(@"Webservice with URL: %@ failed with error code: %ld.", [[task currentRequest] URL], (long)[webServiceError code]);
}


@end
