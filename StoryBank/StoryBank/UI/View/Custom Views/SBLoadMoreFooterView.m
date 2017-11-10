//
//  SBLoadMoreFooterView.m
//  StoryBank
//
//  Created by Lakhpat Meena on 11/4/17.
//  Copyright © 2017 OutBloom. All rights reserved.
//

#import "SBLoadMoreFooterView.h"

@interface SBLoadMoreFooterView ()

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicatorView;
@property (weak, nonatomic) IBOutlet UILabel *noMoreTextLabel;

@end

@implementation SBLoadMoreFooterView

- (void)showNoMoreTextLabel:(BOOL)toShow {
    
    if (toShow) {
        _noMoreTextLabel.hidden = false;
    } else {
        _noMoreTextLabel.hidden = true;
    }
}

- (void)showLoadingIndicatorView:(BOOL)toShow {
    
    if (toShow) {
        _loadingIndicatorView.hidden = false;
        [_loadingIndicatorView startAnimating];
    } else {
        _loadingIndicatorView.hidden = true;
        [_loadingIndicatorView stopAnimating];
    }
}

@end
