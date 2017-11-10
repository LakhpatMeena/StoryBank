//
//  CDStory+CoreDataProperties.m
//  StoryBank
//
//  Created by Lakhpat Meena on 11/5/17.
//  Copyright © 2017 OutBloom. All rights reserved.
//
//

#import "CDStory+CoreDataProperties.h"

@implementation CDStory (CoreDataProperties)

+ (NSFetchRequest<CDStory *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"CDStory"];
}

@dynamic itemId;
@dynamic score;
@dynamic title;
@dynamic time;
@dynamic url;
@dynamic type;
@dynamic by;
@dynamic readStatus;

@end
