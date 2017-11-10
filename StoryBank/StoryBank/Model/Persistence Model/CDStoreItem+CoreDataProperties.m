//
//  CDStoreItem+CoreDataProperties.m
//  StoryBank
//
//  Created by Lakhpat Meena on 11/8/17.
//  Copyright © 2017 OutBloom. All rights reserved.
//
//

#import "CDStoreItem+CoreDataProperties.h"

@implementation CDStoreItem (CoreDataProperties)

+ (NSFetchRequest<CDStoreItem *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"CDStoreItem"];
}

@dynamic itemId;
@dynamic indexInAPIResponse;

@end
