//
//  CDStory+CoreDataClass.m
//  StoryBank
//
//  Created by Lakhpat Meena on 11/5/17.
//  Copyright © 2017 OutBloom. All rights reserved.
//
//

#import "CDStory+CoreDataClass.h"

@implementation CDStory

+ (NSEntityDescription *)entityInManagedObjectContext:(NSManagedObjectContext *)context {
    return [NSEntityDescription entityForName:@"CDStory" inManagedObjectContext:context];
}

+ (CDStory *)newStoryInManagedObjectContext:(NSManagedObjectContext *)context {
    CDStory *story = (CDStory *)[NSEntityDescription insertNewObjectForEntityForName:@"CDStory" inManagedObjectContext:context];
    return story;
}

@end
