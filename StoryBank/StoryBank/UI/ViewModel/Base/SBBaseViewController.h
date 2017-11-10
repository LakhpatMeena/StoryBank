//
//  SBBaseViewController.h
//  StoryBank
//
//  Created by Lakhpat Meena on 11/5/17.
//  Copyright © 2017 OutBloom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SBDefaultErrorLayoutView.h"

@interface SBBaseViewController : UIViewController <SBDefaultErrorLayoutViewDelegate>

@property (nonatomic, strong) UIView *noInternetConnectionView;
@property (nonatomic, strong) SBDefaultErrorLayoutView *errorLayoutView;
@property (nonatomic, assign) BOOL isNoConnectionViewVisible;

- (void)showDefaultErrorLayout:(BOOL)toShow;
- (void)showNoNetworkConnectionView:(BOOL)toShow;
- (void)setConstraintsOnNoInternetConnectionView;
- (void)tryAgainButtonAction;
- (NSString *)messageForNoInternetConnectionView;
- (NSString *)messageForDefaultErrorLayoutView;

@end
