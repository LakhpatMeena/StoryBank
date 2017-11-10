//
//  SBStoryDataTableViewCell.h
//  StoryBank
//
//  Created by Lakhpat Meena on 11/4/17.
//  Copyright © 2017 OutBloom. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SBStoryDataTableViewCell;
@class SBStory;

@protocol SBStoryDataTableViewCellDelegate

- (void)moreButtonPressedWithStoryDataCell:(SBStoryDataTableViewCell *)storyDataTableViewCell;

@end

@interface SBStoryDataTableViewCell : UITableViewCell

@property (nonatomic, weak) id <SBStoryDataTableViewCellDelegate> storyDataTableViewCellDelegate;

- (void)updateCellWithStory:(SBStory *)story;

@end
