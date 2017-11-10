//
//  CDStoreItem+CoreDataClass.h
//  StoryBank
//
//  Created by Lakhpat Meena on 11/8/17.
//  Copyright © 2017 OutBloom. All rights reserved.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CDStoreItem;

NS_ASSUME_NONNULL_BEGIN

@interface CDStoreItem : NSManagedObject


+ (NSEntityDescription *)entityInManagedObjectContext:(NSManagedObjectContext *)context;
+ (CDStoreItem *)newStoreItemInManagedObjectContext:(NSManagedObjectContext *)context;

@end

NS_ASSUME_NONNULL_END

#import "CDStoreItem+CoreDataProperties.h"
