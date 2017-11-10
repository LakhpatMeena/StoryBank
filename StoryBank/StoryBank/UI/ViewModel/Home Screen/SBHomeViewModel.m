//
//  SBHomeViewModel.m
//  StoryBank
//
//  Created by Lakhpat Meena on 11/4/17.
//  Copyright © 2017 OutBloom. All rights reserved.
//

#import "SBHomeViewModel.h"
#import "SBFetchTopStoriesIdWebService.h"
#import "SBFetchStoryDataWebService.h"
#import "SBStory.h"
#import "AppDelegate.h"
#import "CDStory+CoreDataClass.h"
#import "SBAppManager.h"
#import "SBAppConstants.h"
#import "NSString+ValidString.h"
#import "CDStoreItem+CoreDataClass.h"

typedef NS_ENUM(NSInteger, SBStoriesDatasourceType) {
    SBStoriesDatasourceTypeServer,
    SBStoriesDatasourceTypeLocal
};

@interface SBHomeViewModel() <SBFetchTopStoriesIdWebServiceDelegate, SBFetchStoryDataWebServiceDelegate> {
    
    NSArray *_arrayOfStoriesId;
    NSMutableArray<SBStory *> *_arrayOfStoriesData;
    NSMutableArray<SBStory *> *_tempArrayOfStoriesData;
    NSArray<SBStory *> *_arrayOfSearchedData;
    NSInteger _currentPage;
    NSInteger _totalStories;
    NSInteger _currentCountToFetch;
    BOOL _requestedForRefresh;
    BOOL _isSearchedDataRequired;
    SBStoriesDatasourceType _storiesDatasourceType;
}

@property (nonatomic, strong) SBFetchTopStoriesIdWebService *fetchTopStoriesIdWebService;
@property (nonatomic, strong) NSOperationQueue *apiRequestQueue;

@end

@implementation SBHomeViewModel

#pragma mark - Public Methods
- (void)fetchInitialStoryItems {
    
    NSDate *lastUpdatedTime = [[NSUserDefaults standardUserDefaults] valueForKey:kLastUpdatedTimeOfStoriesData];
    NSInteger minutesDiff = 0;
    
    if (lastUpdatedTime != nil) {
        minutesDiff = [SBAppManager minutesDifferenceBetweenDate1:[NSDate date] andDate2:lastUpdatedTime];
    }
    
    if ((lastUpdatedTime == nil || minutesDiff > 2) && [SBAppManager isInternetConnectionAvailable]) {
        [self fetchTopStoriesIdsFromServer];
    } else {
        [self fetchTopStoriesIdsFromLocal];
    }
}

- (void)fetchNextStoryItems {
    
    if ([SBAppManager isInternetConnectionAvailable]) {
        [self fetchStoryItemsWithCurrentPageFromServer];
    } else {
        [self fetchStoryItemsWithCurrentPageFromLocal];
    }
}

- (void)refreshStoriesData {
    
    _requestedForRefresh = true;
    [self fetchInitialStoryItems];
}

- (NSInteger)getTotalStoryItemsCount {
    
    if (_isSearchedDataRequired) {
        return [_arrayOfSearchedData count];
    }
    
    return [_arrayOfStoriesData count];
}

- (SBStory *)storyAtIndex:(NSInteger)index {
    
    if (_isSearchedDataRequired) {
        return [_arrayOfSearchedData objectAtIndex:index];
    }
    
    return [_arrayOfStoriesData objectAtIndex:index];
}

- (void)updateReadStatusOfStoryAtIndex:(NSInteger)index {
    SBStory *story = nil;
    
    if (_isSearchedDataRequired) {
        story = [_arrayOfSearchedData objectAtIndex:index];
    } else {
        story = [_arrayOfStoriesData objectAtIndex:index];
    }
    
    story.readStatus = SBStoryStatusRead;
    [self updateStoryItemStatusInLocalWithStory:story];
}

- (void)searchProjectsWithString:(NSString *)text {
    
    if ([text validAndNotEmptyStringObject] != nil) {
        
        _isSearchedDataRequired = true;
        
        NSMutableArray<SBStory *> *arrayOfTempSearchedData = [NSMutableArray array];
        
        for (SBStory *story in _arrayOfStoriesData) {
            if ([story.title localizedCaseInsensitiveContainsString:text]) {
                [arrayOfTempSearchedData addObject:story];
            }
        }
        
        _arrayOfSearchedData = nil;
        _arrayOfSearchedData = [NSArray arrayWithArray:arrayOfTempSearchedData];
        arrayOfTempSearchedData = nil;
    }
}

- (void)endSearchingStoryItems {
    _isSearchedDataRequired = false;
}

#pragma mark - Private Methods
- (void)fetchTopStoriesIdsFromServer {
    
    _isAPIRequestInProgress = true;
    _fetchTopStoriesIdWebService = [[SBFetchTopStoriesIdWebService alloc] init];
    _fetchTopStoriesIdWebService.fetchTopStoriesIdWebServiceDelegate = self;
    [_fetchTopStoriesIdWebService resume];
}

- (void)fetchStoryItemsWithCurrentPageFromServer {
    
    _currentCountToFetch = [self totalStoriesCountToFetchWithCurrentPage];
    
    if (_currentCountToFetch == 0) {
        [self.homeViewModelDelegate noMoreItemsToLoadWithHomeViewModel:self];
    } else {
        NSInteger startingIndex = (_currentPage - 1) * 10;
        
        _apiRequestQueue = [[NSOperationQueue alloc] init];
        _apiRequestQueue.maxConcurrentOperationCount = 10;
        
        NSMutableArray<NSOperation *> *operations = [NSMutableArray array];
        for (NSInteger i=0; i<_currentCountToFetch; i++) {
            NSBlockOperation *apiOperation = [NSBlockOperation blockOperationWithBlock:^{
                
                [self fetchStoryDataWithStoryID:[[_arrayOfStoriesId objectAtIndex:startingIndex + i] integerValue]];
            }];
            [operations addObject:apiOperation];
        }
        
        _isAPIRequestInProgress = true;
        [_apiRequestQueue addOperations:operations waitUntilFinished:NO];
    }
}

- (void)fetchStoryDataWithStoryID:(NSInteger)storyID {
    
    SBFetchStoryDataWebService *fetchStoryDataWebService = [[SBFetchStoryDataWebService alloc] initWithStoryId:[NSString stringWithFormat:@"%ld", storyID]];
    fetchStoryDataWebService.fetchStoryDataWebServiceDelegate = self;
    [fetchStoryDataWebService resume];
}

- (NSInteger)totalStoriesCountToFetchWithCurrentPage {
    
    if (_currentPage * 10 <= _totalStories) {
        return 10;
    }
    return _totalStories - (_currentPage - 1)*10;
}

- (void)storyDataFetched {
    
    if (_tempArrayOfStoriesData == nil || [_tempArrayOfStoriesData count] == 0) {
        [self.homeViewModelDelegate homeViewModel:self failedToFetchStoryItemsWithWebServiceError:[NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorBadServerResponse userInfo:nil]];
    } else {
        _currentPage++;
        [_tempArrayOfStoriesData sortUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"score" ascending:NO]]];
        
        if (_arrayOfStoriesData == nil) {
            _arrayOfStoriesData = [NSMutableArray array];
        }
        
        if (_requestedForRefresh) {
            _requestedForRefresh = false;
            [_arrayOfStoriesData removeAllObjects];
        }
        
        [self insertStoriesDataInDatabaseWithStories:_tempArrayOfStoriesData];
        [_arrayOfStoriesData addObjectsFromArray:_tempArrayOfStoriesData];
        _tempArrayOfStoriesData = nil;
        
        [self.homeViewModelDelegate successfullyFetchedStoryItemsWithHomeViewModel:self];
    }
}

- (void)saveStoriesIDLocalAndFetchTopItems {
    
    _totalStories = [_arrayOfStoriesId count];
    [self saveStoriesIdLocal];
    _currentPage = 1;
    [self fetchStoryItemsWithCurrentPageFromServer];
}

- (void)reduceCountAndCheckForCompletion {
    
    _currentCountToFetch--;
    if (_currentCountToFetch == 0) {
        [self storyDataFetched];
        _isAPIRequestInProgress = false;
    }
}

#pragma mark - CoreData Related Methods
- (void)fetchTopStoriesIdsFromLocal {
    NSManagedObjectContext *context = [AppDelegate sharedInstance].managedObjectContext;
    
    NSFetchRequest *fetchRequest = [CDStoreItem fetchRequest];
    NSError *fetchError = nil;
    NSArray *currentStoriesId = [[context executeFetchRequest:fetchRequest error:&fetchError] sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"indexInAPIResponse" ascending:YES]]];
    
    if (fetchError != nil) {
        NSLog(@"Not able to get stories id with error: %@", fetchError.description);
        [self.homeViewModelDelegate homeViewModel:self failedToFetchStoryItemsWithWebServiceError:fetchError];
    } else {
        if (currentStoriesId == nil || [currentStoriesId count] == 0) {
            [self.homeViewModelDelegate successfullyFetchedStoryItemsWithHomeViewModel:self];
        } else {
            
            NSMutableArray *tempStoriesId = [NSMutableArray array];
            for (CDStoreItem *storeItem in currentStoriesId) {
                [tempStoriesId addObject:[NSNumber numberWithInt:storeItem.itemId]];
            }
            _arrayOfStoriesId = [[NSArray alloc] initWithArray:tempStoriesId copyItems:YES];
            tempStoriesId = nil;
            _totalStories = [_arrayOfStoriesId count];
            _currentPage = 1;
            [self fetchStoryItemsWithCurrentPageFromLocal];
        }
    }
}

- (void)fetchStoryItemsWithCurrentPageFromLocal {
    
    _currentCountToFetch = [self totalStoriesCountToFetchWithCurrentPage];
    
    if (_currentCountToFetch == 0) {
        [self.homeViewModelDelegate noMoreItemsToLoadWithHomeViewModel:self];
    } else {
        
        NSManagedObjectContext *context = [AppDelegate sharedInstance].managedObjectContext;
        
        NSInteger startingIndex = (_currentPage - 1) * 10;
        
        if (_tempArrayOfStoriesData == nil) {
            _tempArrayOfStoriesData = [NSMutableArray array];
        }
        
        NSFetchRequest *fetchRequest = [CDStory fetchRequest];
        
        for (NSInteger i=0; i<_currentCountToFetch; i++) {
            NSInteger itemId = [[_arrayOfStoriesId objectAtIndex:startingIndex+i] integerValue];
            fetchRequest.predicate = [NSPredicate predicateWithFormat:@"itemId == %@", [NSNumber numberWithInteger:itemId]];
            NSError *error = nil;
            NSArray *localStories = [context executeFetchRequest:fetchRequest error:&error];
            if (error != nil) {
                NSLog(@"Not able to fetch story details for itemId %ld with error: %@", itemId, error.description);
            } else {
                if (localStories && [localStories count]>0) {
                    CDStory *story = [localStories firstObject];
                    SBStory *storyToAdd = [[SBStory alloc] initWithPersistentData:story];
                    [_tempArrayOfStoriesData addObject:storyToAdd];
                }
            }
        }
        
        if (_tempArrayOfStoriesData == nil || [_tempArrayOfStoriesData count] == 0) {
            [self.homeViewModelDelegate successfullyFetchedStoryItemsWithHomeViewModel:self];
        } else {
            _currentPage++;
            [_tempArrayOfStoriesData sortUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"score" ascending:NO]]];
            
            if (_arrayOfStoriesData == nil) {
                _arrayOfStoriesData = [NSMutableArray array];
            }
            
            if (_requestedForRefresh) {
                _requestedForRefresh = false;
                [_arrayOfStoriesData removeAllObjects];
            }
            
            [_arrayOfStoriesData addObjectsFromArray:_tempArrayOfStoriesData];
            _tempArrayOfStoriesData = nil;
            
            [self.homeViewModelDelegate successfullyFetchedStoryItemsWithHomeViewModel:self];
        }
    }
}

- (void)clearAllStoriesDataFromLocal {
    
    NSManagedObjectContext *context = [AppDelegate sharedInstance].managedObjectContext;
    
    NSFetchRequest *fetchRequest = [CDStory fetchRequest];
    
    NSBatchDeleteRequest *deleteRequest = [[NSBatchDeleteRequest alloc] initWithFetchRequest:fetchRequest];
    deleteRequest.resultType = NSBatchDeleteResultTypeCount;
    
    NSError *deleteError = nil;
    NSBatchDeleteResult *deleteResult = [context executeRequest:deleteRequest error:&deleteError];
    
    if (deleteError != nil) {
        NSLog(@"Not able to delete old stories with error: %@", deleteError.description);
    } else {
        NSLog(@" %@ records deleted from story table.", deleteResult.result);
    }
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] saveContext];
}

- (void)insertStoriesDataInDatabaseWithStories:(NSArray<SBStory *> *)stories {
    
    NSManagedObjectContext *context = [AppDelegate sharedInstance].managedObjectContext;
    
    NSFetchRequest *fetchRequest = [CDStory fetchRequest];
    
    for (SBStory *story in stories) {
        
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"itemId == %@", [NSNumber numberWithInteger:story.itemId]];
        NSError *error = nil;
        NSArray *localStories = [context executeFetchRequest:fetchRequest error:&error];
        if (error != nil) {
            NSLog(@"Not able to update/add story details for itemId %ld with error: %@", story.itemId, error.description);
        } else {
            if (localStories && [localStories count]>0) {
                CDStory *storyToUpdate = [localStories firstObject];
                storyToUpdate.score = story.score;
                storyToUpdate.title = story.title;
                storyToUpdate.time = story.time;
                storyToUpdate.url = story.url;
                storyToUpdate.type = story.type;
                storyToUpdate.by = story.by;
                //To set the current read status of story from saved details
                story.readStatus = storyToUpdate.readStatus;
            } else {
                CDStory *newStory = [CDStory newStoryInManagedObjectContext:context];
                newStory.itemId = (int32_t)story.itemId;
                newStory.score = story.score;
                newStory.title = story.title;
                newStory.time = story.time;
                newStory.url = story.url;
                newStory.type = story.type;
                newStory.by = story.by;
                newStory.readStatus = story.readStatus;
            }
        }
    }
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] saveContext];
}

- (void)updateStoryItemStatusInLocalWithStory:(SBStory *)story {
    
    NSManagedObjectContext *context = [AppDelegate sharedInstance].managedObjectContext;
    
    NSFetchRequest *fetchRequest = [CDStory fetchRequest];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"itemId == %@", [NSNumber numberWithInteger:story.itemId]];
    NSError *error = nil;
    NSArray *localStories = [context executeFetchRequest:fetchRequest error:&error];
    
    if (error != nil) {
        NSLog(@"Not able to update story status with error: %@", error.description);
    } else {
        CDStory *storyToUpdate = [localStories firstObject];
        storyToUpdate.readStatus = story.readStatus;
        [(AppDelegate *)[[UIApplication sharedApplication] delegate] saveContext];
    }
}

- (void)saveStoriesIdLocal {
    [self deleteOldStoriesFromLocal];
    [self clearAllStoriesIDFromLocal];
    
    NSManagedObjectContext *context = [AppDelegate sharedInstance].managedObjectContext;
    
    for (NSInteger i=0; i<_totalStories; i++) {
        CDStoreItem *storeItem = [CDStoreItem newStoreItemInManagedObjectContext:context];
        storeItem.itemId = (int32_t)[[_arrayOfStoriesId objectAtIndex:i] intValue];
        storeItem.indexInAPIResponse = i;
    }
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] saveContext];
}

- (void)deleteOldStoriesFromLocal {
    NSManagedObjectContext *context = [AppDelegate sharedInstance].managedObjectContext;
    
    NSFetchRequest *fetchRequest = [CDStoreItem fetchRequest];
    NSError *fetchError = nil;
    NSArray *currentStoriesId = [context executeFetchRequest:fetchRequest error:&fetchError];
    NSMutableArray *tempStoriesId = [NSMutableArray array];
    for (CDStoreItem *storeItem in currentStoriesId) {
        [tempStoriesId addObject:[NSNumber numberWithInt:storeItem.itemId]];
    }
    
    NSMutableSet *needToDelete = [NSMutableSet setWithArray:tempStoriesId];
    NSSet *needToKeep = [NSSet setWithArray:_arrayOfStoriesId];
    [needToDelete minusSet:needToKeep];
    
    for (NSNumber *item in needToDelete) {
        [self deleteStoryDataFromLocalWithItemId:[item integerValue]];
    }
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] saveContext];
}

- (void)deleteStoryDataFromLocalWithItemId:(NSInteger)itemId {
    NSManagedObjectContext *context = [AppDelegate sharedInstance].managedObjectContext;
    
    NSFetchRequest *fetchRequest = [CDStory fetchRequest];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"itemId == %@", [NSNumber numberWithInteger:itemId]];
    NSError *error = nil;
    NSArray *localStories = [context executeFetchRequest:fetchRequest error:&error];
    
    if (error != nil) {
        NSLog(@"Not able to fetch story details with error: %@", error.description);
    } else {
        if (localStories && [localStories count]>0) {
            CDStory *storyToDelete = [localStories firstObject];
            [context deleteObject:storyToDelete];
            [(AppDelegate *)[[UIApplication sharedApplication] delegate] saveContext];
        }
    }
}

- (void)clearAllStoriesIDFromLocal {
    
    NSManagedObjectContext *context = [AppDelegate sharedInstance].managedObjectContext;
    
    NSFetchRequest *fetchRequest = [CDStoreItem fetchRequest];
    
    NSBatchDeleteRequest *deleteRequest = [[NSBatchDeleteRequest alloc] initWithFetchRequest:fetchRequest];
    deleteRequest.resultType = NSBatchDeleteResultTypeCount;
    
    NSError *deleteError = nil;
    NSBatchDeleteResult *deleteResult = [context executeRequest:deleteRequest error:&deleteError];
    
    if (deleteError != nil) {
        NSLog(@"Not able to delete old stories id with error: %@", deleteError.description);
    } else {
        NSLog(@" %@ records deleted from Store Items table.", deleteResult.result);
    }
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] saveContext];
}

#pragma mark - SBFetchTopStoriesIdWebService Delegate Methods
- (void)fetchTopStoriesIdWebService:(SBFetchTopStoriesIdWebService *)webService successfullyFetchedTopStoriesData:(NSArray *)stories {
    
    _isAPIRequestInProgress = false;
    
    NSDate *lastUpdatedTimeOfStoriesData = [NSDate date];
    [[NSUserDefaults standardUserDefaults] setObject:lastUpdatedTimeOfStoriesData forKey:kLastUpdatedTimeOfStoriesData];
    
    if ([stories count] == 0) {
        [self.homeViewModelDelegate successfullyFetchedStoryItemsWithHomeViewModel:self];
    } else {
        
        if ([stories count] >= 50) {
            _arrayOfStoriesId = [[NSArray alloc] initWithArray:[stories subarrayWithRange:NSMakeRange(0, 50)] copyItems:YES];
        } else {
            _arrayOfStoriesId = [[NSArray alloc] initWithArray:stories copyItems:YES];
        }
        
        [self saveStoriesIDLocalAndFetchTopItems];
    }
}

- (void)fetchTopStoriesIdWebService:(SBFetchTopStoriesIdWebService *)webService failedToFetchTopStoriesDataWithWebServiceError:(NSError *)error {
    
    _isAPIRequestInProgress = false;
    [self.homeViewModelDelegate homeViewModel:self failedToFetchStoryItemsWithWebServiceError:error];
}

#pragma mark - SBFetchStoryDataWebService Delegate Methods
- (void)fetchStoryDataWebService:(SBFetchStoryDataWebService *)webService successfullyFetchedStoryData:(SBStory *)story {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (_tempArrayOfStoriesData == nil) {
            _tempArrayOfStoriesData = [NSMutableArray array];
        }
        [_tempArrayOfStoriesData addObject:story];
        
        [self reduceCountAndCheckForCompletion];
    });
}

- (void)fetchStoryDataWebService:(SBFetchStoryDataWebService *)webService failedToFetchStoryDataWithWebServiceError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self reduceCountAndCheckForCompletion];
    });
}

@end
