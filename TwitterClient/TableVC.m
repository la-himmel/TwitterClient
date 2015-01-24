//
//  TableVC.m
//  TwitterClient
//
//  Created by Ekaterina on 1/9/15.
//  Copyright (c) 2015 Ekaterina. All rights reserved.
//

#import "TableVC.h"
#import "NSDictionary+twitterFields.h"
#import "Geometry.h"
#import "ImageLoader.h"
#import "NetworkManager.h"
#import "Helper.h"

@interface TableVC ()<UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *loadMoreRefreshControl;
@property (nonatomic, weak) IBOutlet UIView *bottomView;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@end

static NSString *const reuseIdentifier = @"tablecell";
static NSString *const reuseImageIdentifier = @"tableImageCell";

@implementation TableVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.refreshing = NO;
    self.tableView.separatorColor = [UIColor whiteColor];
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 10, 0, 10);
    self.tableView.tableFooterView = self.bottomView;
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(pullToRefresh) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    self.loadMoreRefreshControl.hidden = YES;
}

- (void)pullToRefresh
{
    [self pullToRefreshWithSuccess:^{
        [self reload];
    }];
}

- (void)loadMore
{
    __weak TableVC *wself = self;
    [self loadMoreWithSuccess:^(NSArray *data) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSInteger totalBeforeUpdate = [wself.data count];
            [wself.data addObjectsFromArray:data];
            NSMutableArray *indexPaths = [NSMutableArray new];
            for (NSInteger i = totalBeforeUpdate; i < [wself.data count]; i++) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                [indexPaths addObject:indexPath];
            }
            [wself.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
            [wself stopControl];
        });
    } failure:^(NSError *error) {
        [wself stopControl]; //main thread
    }];
}

- (void)stopControl
{
    self.loadMoreRefreshControl.hidden = YES;
    [self.loadMoreRefreshControl stopAnimating];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *item = [self.data objectAtIndex:indexPath.row];
    NSDictionary *mediaInfo = [item mediaURLAndSize];
    
    BaseTableViewCell *cell = nil;
    if (mediaInfo) {
        TableViewImageCell *mcell = [tableView dequeueReusableCellWithIdentifier:reuseImageIdentifier forIndexPath:indexPath];
        cell = mcell;
        [self configureMediaCell:mcell withMedia:mediaInfo];        
    } else {
        TableViewCell *mcell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
        cell = mcell;
    }
    
    //Tweet
    cell.tweet.contentInset = UIEdgeInsetsZero;
    cell.tweet.textContainer.lineFragmentPadding = 0;
    cell.tweet.text = [item tweet];
    cell.tweet.font = [Helper fontForTweet];
    
    [self configureNameLabel:cell.nameLabel item:item];
    [self configureImageView:cell.avatar withUrl:[item avatarURL]];

    UIColor *backgroundColor = indexPath.row %2 ? [UIColor whiteColor] : UIColorFromRGB(0xF9FEFF);
    cell.contentView.backgroundColor = backgroundColor;
    [cell.contentView setNeedsUpdateConstraints];
    [cell.contentView layoutIfNeeded];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *item = [self.data objectAtIndex:indexPath.item];
    NSDictionary *mediaInfo = [item mediaURLAndSize];
    
    CGSize tweetSize = [Geometry sizeForTweetWithContent:[item tweet] view:self.view];

    float height = [Geometry baseHeight] + tweetSize.height;
    if (mediaInfo) {
        CGSize oldSize = CGSizeMake([[mediaInfo objectForKey:MEDIA_W] intValue], [[mediaInfo objectForKey:MEDIA_H] intValue]);
        CGSize fittedSize = [Geometry sizeForImageWithSize:oldSize view:self.view];
        height += fittedSize.height + COMMON_OFFSET;
    }
    return height;
}

- (void)reload
{
    [self.tableView reloadData];
}

- (void)addItems:(NSArray*)newItems
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSRange range = NSMakeRange(0, [newItems count]);
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
        [self.data insertObjects:newItems atIndexes:indexSet];
        NSMutableArray *indexPaths = [NSMutableArray new];
        for (NSInteger i = 0; i < [newItems count]; i++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            [indexPaths addObject:indexPath];
        }
        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    });
}

- (void)configureMediaCell:(TableViewImageCell*)mcell withMedia:(NSDictionary*)mediaInfo
{
    CGSize oldSize = CGSizeMake([[mediaInfo objectForKey:MEDIA_W] intValue],
                                [[mediaInfo objectForKey:MEDIA_H] intValue]);
    CGSize size = [Geometry sizeForImageWithSize:oldSize view:self.view];
    mcell.picHeight.constant = size.height;
    mcell.picWidth.constant = size.width;
    
    [mcell.contentView setNeedsUpdateConstraints];
    [mcell layoutIfNeeded];
    
    [self configureImageView:mcell.pic withUrl:[mediaInfo objectForKey:MEDIA_URL]];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    int currentOffset = scrollView.contentOffset.y;
    int maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
    int deltaOffset = maximumOffset - currentOffset;
        
    if (deltaOffset <= 0 && !self.refreshing) {
        self.loadMoreRefreshControl.hidden = NO;
        [self.loadMoreRefreshControl startAnimating];
        [self loadMore];
    }
}

@end

@implementation BaseTableViewCell
@end

@implementation TableViewCell
@end

@implementation TableViewImageCell
@end
