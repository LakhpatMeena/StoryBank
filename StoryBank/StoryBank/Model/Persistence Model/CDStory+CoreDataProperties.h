//
//  CDStory+CoreDataProperties.h
//  StoryBank
//
//  Created by Lakhpat Meena on 11/5/17.
//  Copyright © 2017 OutBloom. All rights reserved.
//
//

#import "CDStory+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface CDStory (CoreDataProperties)

+ (NSFetchRequest<CDStory *> *)fetchRequest;

@property (nonatomic) int32_t itemId;
@property (nonatomic) int16_t score;
@property (nullable, nonatomic, copy) NSString *title;
@property (nullable, nonatomic, copy) NSDate *time;
@property (nullable, nonatomic, copy) NSString *url;
@property (nullable, nonatomic, copy) NSString *type;
@property (nullable, nonatomic, copy) NSString *by;
@property (nonatomic) BOOL readStatus;

@end

NS_ASSUME_NONNULL_END
