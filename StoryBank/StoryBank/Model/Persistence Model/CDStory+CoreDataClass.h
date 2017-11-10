//
//  CDStory+CoreDataClass.h
//  StoryBank
//
//  Created by Lakhpat Meena on 11/5/17.
//  Copyright © 2017 OutBloom. All rights reserved.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CDStory;

NS_ASSUME_NONNULL_BEGIN

@interface CDStory : NSManagedObject

+ (NSEntityDescription *)entityInManagedObjectContext:(NSManagedObjectContext *)context;
+ (CDStory *)newStoryInManagedObjectContext:(NSManagedObjectContext *)context;

@end

NS_ASSUME_NONNULL_END

#import "CDStory+CoreDataProperties.h"
