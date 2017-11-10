//
//  SBStoryDataTableViewCell.m
//  StoryBank
//
//  Created by Lakhpat Meena on 11/4/17.
//  Copyright © 2017 OutBloom. All rights reserved.
//

#import "SBStoryDataTableViewCell.h"
#import "SBStory.h"
#import "SBAppManager.h"
#import "UIColor+AppColors.h"

@interface SBStoryDataTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *byLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@end

@implementation SBStoryDataTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

#pragma mark - Public Methods
- (void)updateCellWithStory:(SBStory *)story {
    
    _titleLabel.text = story.title;
    
    if (story.readStatus == SBStoryStatusRead) {
        _titleLabel.font = [UIFont fontWithName:@"AvenirNext-Medium" size:14];
    } else {
        _titleLabel.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:14];
    }
    
    _byLabel.text = [NSString stringWithFormat:@"%@ ,", story.by];
    [self updateTimeTextWithTime:story.time];
}

- (IBAction)moreButtonAction:(id)sender {
    
    [self.storyDataTableViewCellDelegate moreButtonPressedWithStoryDataCell:self];
}


#pragma mark - Private Methods
- (void)updateTimeTextWithTime:(NSDate *)time {
    int minutes = [SBAppManager minutesDifferenceBetweenDate1:[NSDate date] andDate2:time];

    if (minutes < 60) {
        NSString *suffix = (minutes==1)?@"minute ago":@"minutes ago";
        _timeLabel.text = [NSString stringWithFormat:@"%d %@", minutes, suffix];
        _timeLabel.textColor = [UIColor getDarkOrangeColor];
    } else {
        _timeLabel.text = [SBAppManager stringFromNSDate:time];
        _timeLabel.textColor = [[UIColor getLightBlackColor] colorWithAlphaComponent:0.5];
    }
}

@end
