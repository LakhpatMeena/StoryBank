//
//  SBBaseViewController.m
//  StoryBank
//
//  Created by Lakhpat Meena on 11/5/17.
//  Copyright © 2017 OutBloom. All rights reserved.
//

#import "SBBaseViewController.h"
#import "UIColor+AppColors.h"

@interface SBBaseViewController ()

@end

@implementation SBBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Public Methods
- (void)showDefaultErrorLayout:(BOOL)toShow {
    
    if (_errorLayoutView == nil) {
        [self createErrorLayoutView];
    }
    
    [_errorLayoutView updateWithMessage:[self messageForDefaultErrorLayoutView]];
    _errorLayoutView.hidden = toShow?false:true;
}

- (void)createErrorLayoutView {
    
    _errorLayoutView = [[[NSBundle mainBundle] loadNibNamed:@"SBDefaultErrorLayoutView" owner:nil options:nil] objectAtIndex:0];
    _errorLayoutView.errorLayoutViewDelegate = self;
    _errorLayoutView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_errorLayoutView];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_errorLayoutView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view  attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_errorLayoutView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view  attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_errorLayoutView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil  attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:250.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_errorLayoutView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil  attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:250.0]];
}

- (void)showNoNetworkConnectionView:(BOOL)toShow {
    if (_noInternetConnectionView == nil) {
        [self createNoInternetConnectionView];
    }
    
    _noInternetConnectionView.hidden = toShow?false:true;
    _isNoConnectionViewVisible = toShow;
}

- (void)createNoInternetConnectionView {
    _noInternetConnectionView = [[UIView alloc] init];
    _noInternetConnectionView.backgroundColor = [UIColor getDarkOrangeColor];
    _noInternetConnectionView.translatesAutoresizingMaskIntoConstraints = NO;
    
    UILabel *textLabel = [[UILabel alloc] init];
    textLabel.text = [self messageForNoInternetConnectionView];
    textLabel.numberOfLines = 2;
    textLabel.font = [UIFont fontWithName:@"AvenirNext-Medium" size:12];
    textLabel.textAlignment = NSTextAlignmentCenter;
    textLabel.textColor = [UIColor whiteColor];
    textLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [_noInternetConnectionView addSubview:textLabel];
    
    [_noInternetConnectionView addConstraint:[NSLayoutConstraint constraintWithItem:textLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:_noInternetConnectionView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:20]];
    [_noInternetConnectionView addConstraint:[NSLayoutConstraint constraintWithItem:textLabel attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:_noInternetConnectionView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:-20]];
    [_noInternetConnectionView addConstraint:[NSLayoutConstraint constraintWithItem:textLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_noInternetConnectionView attribute:NSLayoutAttributeTop multiplier:1.0 constant:12]];
    
    [self.view addSubview:_noInternetConnectionView];
    [self setConstraintsOnNoInternetConnectionView];
}

- (void)setConstraintsOnNoInternetConnectionView {
    //Nothing, subclasses will handle accordingly.
}

- (NSString *)messageForNoInternetConnectionView {
    return @"You are offline! Please connect to get udpated data.";
}

- (NSString *)messageForDefaultErrorLayoutView {
    return @"Something went terribly wrong.";
}

- (void)tryAgainButtonAction {
    //Nothing, subclasses will handle accordingly.
}

#pragma mark - SBDefaultErrorLayoutView Delegate Methods
- (void)tryAgainButtonClickedOnErrorLayoutView:(SBDefaultErrorLayoutView *)errorLayoutView {
    [self tryAgainButtonAction];
}

@end
