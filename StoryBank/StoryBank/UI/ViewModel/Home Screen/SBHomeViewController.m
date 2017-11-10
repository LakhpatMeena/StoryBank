//
//  SBHomeViewController.m
//  StoryBank
//
//  Created by Lakhpat Meena on 11/4/17.
//  Copyright © 2017 OutBloom. All rights reserved.
//

#import "SBHomeViewController.h"
#import "SBHomeViewModel.h"
#import "SBStoryDataTableViewCell.h"
#import "SBLoadMoreFooterView.h"
#import "UIColor+AppColors.h"
#import "SBAppManager.h"
#import "SBStoryDetailsViewController.h"
#import "SBStory.h"

#define kTryingHardAlertMessage @"Hey dear! we are trying hard to give you everything."

@interface SBHomeViewController () <UITableViewDelegate, UITableViewDataSource, SBStoryDataTableViewCellDelegate, SBHomeViewModelDelegate, UITextFieldDelegate> {
    
    BOOL _isLoadingMoreItems;
    BOOL _isRefreshingStories;
    BOOL _isSearchEnabled;
    UIButton *_noDataButton;
}

@property (nonatomic, strong) SBHomeViewModel *homeViewModel;
@property (nonatomic, strong) SBLoadMoreFooterView *loadMoreFooterView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@property (nonatomic, weak) IBOutlet UITableView *storyItemsTableView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *apiInProgressindicatorView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintHomeViewTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintSearchViewHeight;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *searchBarButtonItem;
@property (weak, nonatomic) IBOutlet UIView *searchItemsContainerView;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (weak, nonatomic) IBOutlet UIButton *searchCancelButton;

@end

@implementation SBHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Story Bank";
    
    _homeViewModel = [[SBHomeViewModel alloc] init];
    _homeViewModel.homeViewModelDelegate = self;
    
    [self setupStoryTableView];
    [self setupRefreshControlWithTableView];
    [self showDefaultErrorLayout:false];
    [self setupSearchStoriesView];
    [self fetchInitialData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self checkForNetworkConnectivity];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Methods
- (void)setupStoryTableView {
    // Story Items table view setup
    _storyItemsTableView.delegate = self;
    _storyItemsTableView.dataSource = self;
    _storyItemsTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _storyItemsTableView.estimatedRowHeight = 95;
    _storyItemsTableView.rowHeight = UITableViewAutomaticDimension;
    
    UINib *nib = [UINib nibWithNibName:@"SBStoryDataTableViewCell" bundle:nil];
    [_storyItemsTableView registerNib:nib forCellReuseIdentifier:@"SBStoryDataTableViewCell"];
}

- (void)setupRefreshControlWithTableView {
    
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.tintColor = [UIColor getDarkOrangeColor];
    NSAttributedString *refreshTitle = [[NSAttributedString alloc] initWithString:@"Refreshing your stories..." attributes:@{NSForegroundColorAttributeName:[UIColor getDarkOrangeColor], NSFontAttributeName:[UIFont fontWithName:@"AvenirNext-Medium" size:12]}];
    _refreshControl.attributedTitle = refreshTitle;
    [_refreshControl addTarget:self action:@selector(refreshStoriesData:) forControlEvents:UIControlEventValueChanged];
    
    if (@available(iOS 10.0, *)) {
        [_storyItemsTableView setRefreshControl:_refreshControl];
    } else {
        // Fallback on earlier versions
        [_storyItemsTableView addSubview:_refreshControl];
    }
}

- (void)setupSearchStoriesView {
    
    _searchItemsContainerView.hidden = true;
    _constraintSearchViewHeight.constant = 0;
    _searchTextField.delegate = self;
}

- (void)checkForNetworkConnectivity {
    
    if (![SBAppManager isInternetConnectionAvailable]) {
        _constraintHomeViewTop.constant = 50;
        [self showNoNetworkConnectionView:true];
    } else {
        _constraintHomeViewTop.constant = 0;
        [self showNoNetworkConnectionView:false];
    }
}

- (void)showAlertViewWithMessage:(NSString *)message {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [alert dismissViewControllerAnimated:YES completion:nil];
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showIndicatorView:(BOOL)toShow {
    if (toShow) {
        _apiInProgressindicatorView.hidden = false;
        [_apiInProgressindicatorView startAnimating];
    } else {
        _apiInProgressindicatorView.hidden = true;
        [_apiInProgressindicatorView stopAnimating];
    }
}

- (void)showZeroView {
    
    _storyItemsTableView.hidden = true;
    
    _noDataButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_noDataButton addTarget:self action:@selector(refreshStoriesTableViewData) forControlEvents:UIControlEventTouchUpInside];
    
    [_noDataButton setTitle:@"No New Stories Around. Click To Refresh!" forState:UIControlStateNormal];
    [_noDataButton setTitleColor:[UIColor getDarkOrangeColor] forState:UIControlStateNormal];
    [_noDataButton.titleLabel setFont:[UIFont fontWithName:@"AvenirNext-Medium" size:12]];
    _noDataButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    _noDataButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_noDataButton];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_noDataButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.storyItemsTableView  attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_noDataButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.storyItemsTableView  attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
    [_noDataButton addConstraint:[NSLayoutConstraint constraintWithItem:_noDataButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil  attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:50.0]];
    [_noDataButton addConstraint:[NSLayoutConstraint constraintWithItem:_noDataButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil  attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:300.0]];
}

- (void)hideZeroView {
    if (_noDataButton) {
        _noDataButton.hidden = true;
        [_noDataButton removeFromSuperview];
        _noDataButton = nil;
    }
}

- (void)createFooterView {
    
    _loadMoreFooterView = [[[NSBundle mainBundle] loadNibNamed:@"SBLoadMoreFooterView" owner:nil options:nil] objectAtIndex:0];
    [_loadMoreFooterView showNoMoreTextLabel:false];
    [self.storyItemsTableView setTableFooterView:_loadMoreFooterView];
}

- (void)setConstraintsOnNoInternetConnectionView {
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.noInternetConnectionView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view  attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.noInternetConnectionView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view  attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.noInternetConnectionView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.topLayoutGuide  attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
    [self.noInternetConnectionView addConstraint:[NSLayoutConstraint constraintWithItem:self.noInternetConnectionView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil  attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:50.0]];
}

- (void)refreshStoriesData:(UIRefreshControl *)refreshControl {
    
    if (!_isSearchEnabled) {
        _isRefreshingStories = true;
        [self refreshStoriesTableViewData];
    }
}

- (void)refreshStoriesTableViewData {
    
    [self checkForNetworkConnectivity];
    
    if ([self.homeViewModel getTotalStoryItemsCount] == 0) {
        [self showIndicatorView:true];
        [self hideZeroView];
    }
    
    [self.homeViewModel refreshStoriesData];
}

#pragma mark - Fetch Data Methods
- (void)fetchInitialData {
    
    [self checkForNetworkConnectivity];
    
    _storyItemsTableView.hidden = true;
    [self showIndicatorView:true];
    [self.homeViewModel fetchInitialStoryItems];
}

- (void)fetchMoreData {
    
    [self checkForNetworkConnectivity];
    
    if (_loadMoreFooterView == nil) {
        [self createFooterView];
        [self.storyItemsTableView setContentOffset:CGPointMake(0, self.storyItemsTableView.contentSize.height - self.storyItemsTableView.frame.size.height)];
    }
    _storyItemsTableView.tableFooterView.hidden = false;
    [_loadMoreFooterView showLoadingIndicatorView:true];
    [_loadMoreFooterView showNoMoreTextLabel:false];
    [self.homeViewModel fetchNextStoryItems];
}

#pragma mark - Action Methods
- (IBAction)searchBarButtonAction:(id)sender {
    
    _constraintSearchViewHeight.constant = 50;
    _searchItemsContainerView.hidden = false;
    _isSearchEnabled = true;
    _storyItemsTableView.tableFooterView.hidden = true;
}

- (IBAction)cancelSearchButtonAction:(id)sender {
    
    _searchItemsContainerView.hidden = true;
    _constraintSearchViewHeight.constant = 0;
    _isSearchEnabled = false;
    _searchTextField.text = @"";
    [self.homeViewModel endSearchingStoryItems];
    [self.storyItemsTableView reloadData];
    _storyItemsTableView.tableFooterView.hidden = false;
}


#pragma mark - Base class methods
- (void)tryAgainButtonAction {
    [self showDefaultErrorLayout:false];
    [self fetchInitialData];
}

- (NSString *)messageForDefaultErrorLayoutView {
    if ([SBAppManager isInternetConnectionAvailable]) {
        return @"Something went terribly wrong.";
    } else {
        return @"Not connected to internet.";
    }
}

#pragma mark - TableView Datasource Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.homeViewModel getTotalStoryItemsCount];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SBStoryDataTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SBStoryDataTableViewCell" forIndexPath:indexPath];
    cell.storyDataTableViewCellDelegate = self;
    [cell updateCellWithStory:[self.homeViewModel storyAtIndex:indexPath.row]];
    return cell;
}

#pragma mark - TableView Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.homeViewModel updateReadStatusOfStoryAtIndex:indexPath.row];
    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
    
    SBStoryDetailsViewController *detailsViewController = [SBStoryDetailsViewController getStoryDetailsViewController];
    detailsViewController.currentURLString = [_homeViewModel storyAtIndex:indexPath.row].url;

    [self.navigationController pushViewController:detailsViewController animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    // Check conditions to load more data
    CGFloat currentOffset = _storyItemsTableView.contentOffset.y;
    CGFloat maximumOffset = _storyItemsTableView.contentSize.height - _storyItemsTableView.frame.size.height;
    
    if ( !_isSearchEnabled && !_isLoadingMoreItems && maximumOffset - currentOffset <= 10.0) {
        _isLoadingMoreItems = true;
        [self fetchMoreData];
    }
}

#pragma mark - SBStoryDataTableViewCell Delegate Methods
- (void)moreButtonPressedWithStoryDataCell:(SBStoryDataTableViewCell *)storyDataTableViewCell {
    [self showAlertViewWithMessage:kTryingHardAlertMessage];
}

#pragma mark - SBHomeViewModel Delegate Methods
- (void)successfullyFetchedStoryItemsWithHomeViewModel:(SBHomeViewModel *)homeViewModel {
    
    if (_isLoadingMoreItems) {
        _isLoadingMoreItems = false;
        _storyItemsTableView.tableFooterView.hidden = true;
        [_loadMoreFooterView showLoadingIndicatorView:false];
    } else if (_isRefreshingStories) {
        _isRefreshingStories = false;
        [_refreshControl endRefreshing];
    } else {
        [self showIndicatorView:false];
        _storyItemsTableView.hidden = false;
    }
    
    if ([self.homeViewModel getTotalStoryItemsCount] == 0) {
        [self showZeroView];
    } else {
        [self.storyItemsTableView reloadData];
    }
}

- (void)homeViewModel:(SBHomeViewModel *)homeViewModel failedToFetchStoryItemsWithWebServiceError:(NSError *)error {
    
    if (_isLoadingMoreItems) {
        _isLoadingMoreItems = false;
        _storyItemsTableView.tableFooterView.hidden = true;
        [_loadMoreFooterView showLoadingIndicatorView:false];
    } else {
        [self showIndicatorView:false];
        [self showDefaultErrorLayout:true];
    }
}

- (void)noMoreItemsToLoadWithHomeViewModel:(SBHomeViewModel *)homeViewModel {
    
    if (_isLoadingMoreItems) {
        _isLoadingMoreItems = false;
    }
    
    _storyItemsTableView.tableFooterView.hidden = false;
    [_loadMoreFooterView showLoadingIndicatorView:false];
    [_loadMoreFooterView showNoMoreTextLabel:true];
}

#pragma mark - UITextFieldDelegateMethods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [self.homeViewModel searchProjectsWithString:textField.text];
    [textField resignFirstResponder];
    [self.storyItemsTableView reloadData];
    return true;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

@end
