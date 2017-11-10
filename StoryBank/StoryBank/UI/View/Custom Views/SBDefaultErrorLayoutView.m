//
//  SBDefaultErrorLayoutView.m
//  StoryBank
//
//  Created by Lakhpat Meena on 11/5/17.
//  Copyright © 2017 OutBloom. All rights reserved.
//

#import "SBDefaultErrorLayoutView.h"

@interface SBDefaultErrorLayoutView ()

@property (weak, nonatomic) IBOutlet UILabel *errorMessageLabel;

@end

@implementation SBDefaultErrorLayoutView

- (IBAction)tryAgainButtonAction:(id)sender {
    
    [self.errorLayoutViewDelegate tryAgainButtonClickedOnErrorLayoutView:self];
}

- (void)updateWithMessage:(NSString *)message {
    
    _errorMessageLabel.text = message;
}

@end
