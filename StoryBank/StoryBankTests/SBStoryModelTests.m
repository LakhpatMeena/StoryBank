//
//  SBStoryModelTests.m
//  StoryBankTests
//
//  Created by Lakhpat Meena on 11/5/17.
//  Copyright © 2017 OutBloom. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SBStory.h"

@interface SBStoryModelTests : XCTestCase

@property (nonatomic) SBStory *story;

@end

@implementation SBStoryModelTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testInitWithResponseDictionaryFromOrderDashBoardAPIResponse {
    
    double time = 1509574559.0;
    NSInteger itemId = 98743;
    NSInteger score = 110;
    NSString *title = @"title";
    NSString *by = @"author";
    
    NSDictionary *mockDict = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithDouble:time], @"time", [NSNumber numberWithInteger:itemId], @"id", [NSNumber numberWithInteger:score], @"score", title, @"title", by, @"by", nil];
    
    _story = [[SBStory alloc] initWithStoryData:mockDict];
    
    XCTAssertNotNil(_story, @"SBStory instance is not created.");
    XCTAssertTrue([_story.title isEqualToString:title]);
    XCTAssertTrue(_story.score == score);
    
}

- (void)testInitWithStoryDataFromInvalidDict {
    
    _story = [[SBStory alloc] initWithStoryData:nil];
    
    XCTAssertNotNil(_story, @"SBStory instance is not created.");
    
}

@end
