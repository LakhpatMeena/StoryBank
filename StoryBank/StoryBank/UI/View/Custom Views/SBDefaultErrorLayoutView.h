//
//  SBDefaultErrorLayoutView.h
//  StoryBank
//
//  Created by Lakhpat Meena on 11/5/17.
//  Copyright © 2017 OutBloom. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SBDefaultErrorLayoutView;

@protocol SBDefaultErrorLayoutViewDelegate

- (void)tryAgainButtonClickedOnErrorLayoutView:(SBDefaultErrorLayoutView *)errorLayoutView;

@end

@interface SBDefaultErrorLayoutView : UIView

@property (nonatomic, weak) id <SBDefaultErrorLayoutViewDelegate> errorLayoutViewDelegate;

- (void)updateWithMessage:(NSString *)message;


@end
