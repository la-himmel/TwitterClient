//
//  TableVC.m
//  TwitterClient
//
//  Created by Ekaterina on 1/9/15.
//  Copyright (c) 2015 Ekaterina. All rights reserved.
//

#import "TableVC.h"
#import "NSDictionary+twitterFields.h"
#import "GeometryAndConstants.h"
#import "ImageLoader.h"
#import "NetworkManager.h"
#import "Helper.h"

@interface TableVC ()<UIScrollViewDelegate>
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *loadMoreRefreshControl;
@property (nonatomic, weak) IBOutlet UIView *bottomView;
@property (nonatomic, assign) BOOL refreshing;
@end

static NSString *const reuseIdentifier = @"tablecell";
static NSString *const reuseImageIdentifier = @"tableImageCell";

@implementation TableVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.refreshing = NO;
    [self.tableView registerNib:[UINib nibWithNibName:@"TableViewCell" bundle:nil] forCellReuseIdentifier:reuseIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"TableViewImageCell" bundle:nil] forCellReuseIdentifier:reuseImageIdentifier];
    
    self.tableView.separatorColor = [UIColor whiteColor];
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 10, 0, 10);
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(pullToRefresh) forControlEvents:UIControlEventValueChanged];
    self.loadMoreRefreshControl.hidden = YES;
    self.tableView.tableFooterView = self.bottomView;
}

- (void)loadMore
{
    self.refreshing = YES;
    NSDictionary *lastTweet = [self.data lastObject];
    NSInteger lastId = [[lastTweet objectForKey:@"id"] integerValue];
    NSString *lastIdPrev = [NSString stringWithFormat:@"%ld", lastId -1]; //Twitter API instruction
    
    NetworkManager *manager = [NetworkManager sharedInstance];
    __weak TableVC *wself = self;
    [manager getNextPageDataMaxId:lastIdPrev success:^(NSArray *data) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [wself.data addObjectsFromArray:data];
            [wself reload];
            [wself stopControl];
        });
    } failure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [wself stopControl];
            [[Helper alertWithMessage:[error description]] show];
        });
    }];
}

- (void)stopControl
{
    self.refreshing = NO;
    self.loadMoreRefreshControl.hidden = YES;
    [self.loadMoreRefreshControl stopAnimating];
}

- (void)pullToRefresh
{
    NetworkManager *manager = [NetworkManager sharedInstance];
    __weak TableVC *wself = self;
    [manager getDataForCurrentAccountSuccess:^(NSArray *data) {
        dispatch_async(dispatch_get_main_queue(), ^{
            wself.data = [NSMutableArray arrayWithArray:data];
            [wself reload];
            [wself.refreshControl endRefreshing];
        });
    } failure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[Helper alertWithMessage:[error description]] show];
        });
    }];
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
    
    UIColor *backgroundColor = indexPath.row %2 ? UIColorFromRGB(0xEFFEFF) : UIColorFromRGB(0xDBFDFD);
    cell.contentView.backgroundColor = backgroundColor;
    
    NSString *userName = [item authorUsername];
    NSString *tweet = [item tweet];
    NSString *date = [item date];
    NSString *avatarUrl = [item avatarURL];
    
    float nameDateWidth = [Geometry widthForName:userName date:date view:self.view];
    if (self.view.frame.size.width < nameDateWidth + [Geometry baseWidth]) {
        //show nickname only if we have small space
        userName = [item username];
    }
    cell.avatar.layer.cornerRadius = 3.0;
    cell.avatar.layer.masksToBounds = YES;
    
    __weak BaseTableViewCell *wcell = cell;
    [ImageLoader getImageUrl:avatarUrl success:^(NSData *imageData) {
        UIImage *image = [UIImage imageWithData:imageData];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (wcell)
                [wcell.avatar setImage:image];
        });
        
    } failure:^(NSError *error) {
        NSLog(@"Error: %@", [error description]);
    }];

    cell.tweetLabel.text = tweet;
    cell.nameLabel.text = [NSString stringWithFormat:@"%@ %@", userName, date];
    
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
        CGSize size = [Geometry sizeForImageWithSize:oldSize view:self.view];   
        height += size.height + COMMON_OFFSET;
    }
    return height;
}

- (void)reload
{
    [self.tableView reloadData];
}

- (void)configureMediaCell:(TableViewImageCell*)mcell withMedia:(NSDictionary*)mediaInfo
{
    CGSize oldSize = CGSizeMake([[mediaInfo objectForKey:MEDIA_W] intValue],
                                [[mediaInfo objectForKey:MEDIA_H] intValue]);
    CGSize size = [Geometry sizeForImageWithSize:oldSize view:self.view];
    mcell.picHeight.constant = size.height;
    mcell.picWidth.constant = size.width;
    
    UIImage *placeholder = [Helper imageWithColor:[UIColor clearColor]];
    mcell.pic.image = placeholder;
    NSString *mediaUrl = [mediaInfo objectForKey:MEDIA_URL];
    [mcell.contentView setNeedsUpdateConstraints];
    [mcell layoutIfNeeded];
    
    __weak TableViewImageCell *wcell = mcell;
    [ImageLoader getImageUrl:mediaUrl success:^(NSData *imageData) {
        UIImage *image = [UIImage imageWithData:imageData];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (wcell)
                [wcell.pic setImage:image];
        });
    } failure:^(NSError *error) {
        NSLog(@"Error: %@", [error description]);
    }];
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
