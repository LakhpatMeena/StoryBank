//
//  CDStoreItem+CoreDataProperties.h
//  StoryBank
//
//  Created by Lakhpat Meena on 11/8/17.
//  Copyright © 2017 OutBloom. All rights reserved.
//
//

#import "CDStoreItem+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface CDStoreItem (CoreDataProperties)

+ (NSFetchRequest<CDStoreItem *> *)fetchRequest;

@property (nonatomic) int32_t itemId;
@property (nonatomic) int16_t indexInAPIResponse;

@end

NS_ASSUME_NONNULL_END
