//
//  SBStoryDetailsViewController.m
//  StoryBank
//
//  Created by Lakhpat Meena on 11/6/17.
//  Copyright © 2017 OutBloom. All rights reserved.
//

#import "SBStoryDetailsViewController.h"
#import <WebKit/WebKit.h>
#import "SBStoryDetailsViewModel.h"
#import "SBAppManager.h"

static void *canGoBackContext = &canGoBackContext;

@interface SBStoryDetailsViewController () <WKUIDelegate, WKNavigationDelegate, NSURLConnectionDelegate>

@property (nonatomic, strong) WKWebView *detailsWebView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicatorView;
@property (nonatomic, strong) SBStoryDetailsViewModel *storyDetailsViewModel;

@end

@implementation SBStoryDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _storyDetailsViewModel = [[SBStoryDetailsViewModel alloc] init];
    
    _detailsWebView = [[WKWebView alloc] initWithFrame:self.view.frame];
    _detailsWebView.UIDelegate = self;
    _detailsWebView.navigationDelegate = self;
    [self.view addSubview:_detailsWebView];
    
    [self.view bringSubviewToFront:_indicatorView];
    [self setupAndLaodURL];
    [self setupNavigationBarItems];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self checkForNetworkConnectivity];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

+ (instancetype)getStoryDetailsViewController {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    SBStoryDetailsViewController *storyDetailsViewController = (SBStoryDetailsViewController *)[storyboard instantiateViewControllerWithIdentifier:@"SBStoryDetailsViewController"];
    
    return storyDetailsViewController;
}

#pragma mark - Private methods
- (void)setupAndLaodURL {
    _storyDetailsViewModel.currentURLString = _currentURLString;
    [self.view bringSubviewToFront:_indicatorView];
    [self loadURLWithCurrentURLString];
}

- (void)loadURLWithCurrentURLString {
    NSURL *urlToBeLoaded = [[NSURL alloc] initWithString:_storyDetailsViewModel.currentURLString];
    NSURLRequest *currentRequest = nil;
    
    if ([SBAppManager isInternetConnectionAvailable]) {
        currentRequest = [[NSURLRequest alloc] initWithURL:urlToBeLoaded];
    } else {
        currentRequest = [[NSURLRequest alloc] initWithURL:urlToBeLoaded cachePolicy:NSURLRequestReturnCacheDataDontLoad timeoutInterval:30.0];
    }
    [_detailsWebView loadRequest:currentRequest];
}

- (void)setupNavigationBarItems {
    
    [self.detailsWebView addObserver:self
                   forKeyPath:@"canGoBack"
                      options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew)
                      context:canGoBackContext];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Back_Arrow"] style:UIBarButtonItemStylePlain target:self action:@selector(handleBackButtonTapped:)];
}

- (void)showIndicatorView:(BOOL)toShow {
    if (toShow) {
        _indicatorView.hidden = false;
        [_indicatorView startAnimating];
    } else {
        _indicatorView.hidden = true;
        [_indicatorView stopAnimating];
    }
}

- (void)handleBackButtonTapped:(UIBarButtonItem*)sender {
    if ([_detailsWebView canGoBack]) {
        [self.detailsWebView goBack];
    } else {
        [self.detailsWebView removeObserver:self forKeyPath:@"canGoBack"];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)handleDoneButtonTapped:(UIBarButtonItem*)sender {
    [self.detailsWebView removeObserver:self forKeyPath:@"canGoBack"];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)checkForNetworkConnectivity {
    
    if ([SBAppManager isInternetConnectionAvailable]) {
        _detailsWebView.frame = self.view.frame;
        [self showNoNetworkConnectionView:false];
    } else {
        _detailsWebView.frame = CGRectMake(0, 112, self.view.frame.size.width, self.view.frame.size.height - 112);
        [self showNoNetworkConnectionView:true];
    }
}

#pragma mark - Base Class Methods
- (void)tryAgainButtonAction {
    [self showDefaultErrorLayout:NO];
    [self checkForNetworkConnectivity];
    [self loadURLWithCurrentURLString];
}

- (NSString *)messageForDefaultErrorLayoutView {
    if ([SBAppManager isInternetConnectionAvailable]) {
        return @"Something went terribly wrong.";
    } else {
        return @"Not connected to internet.";
    }
}

- (void)setConstraintsOnNoInternetConnectionView {
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.noInternetConnectionView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view  attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.noInternetConnectionView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view  attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.noInternetConnectionView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.topLayoutGuide  attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
    [self.noInternetConnectionView addConstraint:[NSLayoutConstraint constraintWithItem:self.noInternetConnectionView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil  attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:50.0]];
}

#pragma mark - KVO methods
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (!(context == canGoBackContext)) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }
    
    if ([keyPath isEqualToString:@"canGoBack"]) {
        if (self.detailsWebView.canGoBack) {
            if (self.navigationItem.rightBarButtonItem == nil) {
                self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStyleDone target:self action:@selector(handleDoneButtonTapped:)];
            }
        } else {
            self.navigationItem.rightBarButtonItem = nil;
        }
        return;
    }
    
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}


#pragma mark - WKWebViewNavigation Delegate Methods
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    NSString *urlString = [NSString stringWithFormat:@"%@", webView.URL];
    
    if(webView.URL == nil || [[urlString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""] || [[urlString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@"about:blank"]) {
        
        decisionHandler(WKNavigationActionPolicyCancel);
    } else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    [self showIndicatorView:true];
}

-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [self showIndicatorView:false];
    NSLog(@"Navigation finished! %@", webView.URL);
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [self showIndicatorView:false];
    NSLog(@"Failed provisional navigation: %@", error);
    [self showDefaultErrorLayout:YES];
}



@end
