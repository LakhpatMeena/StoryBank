//
//  CDStoreItem+CoreDataClass.m
//  StoryBank
//
//  Created by Lakhpat Meena on 11/8/17.
//  Copyright © 2017 OutBloom. All rights reserved.
//
//

#import "CDStoreItem+CoreDataClass.h"

@implementation CDStoreItem

+ (NSEntityDescription *)entityInManagedObjectContext:(NSManagedObjectContext *)context {
    return [NSEntityDescription entityForName:@"CDStoreItem" inManagedObjectContext:context];
}

+ (CDStoreItem *)newStoreItemInManagedObjectContext:(NSManagedObjectContext *)context {
    CDStoreItem *storeItem = (CDStoreItem *)[NSEntityDescription insertNewObjectForEntityForName:@"CDStoreItem" inManagedObjectContext:context];
    return storeItem;
}

@end
