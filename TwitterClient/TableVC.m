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
    [self.tableView registerNib:[UINib nibWithNibName:@"TableViewCell" bundle:nil] forCellReuseIdentifier:reuseIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"TableViewImageCell" bundle:nil] forCellReuseIdentifier:reuseImageIdentifier];
    
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
    cell.tweetLabel.text = [item tweet];
    cell.tweetLabel.font = [Helper fontForTweet];
    
    //Username and date
    NSString *userName = [item authorUsername];
    NSString *date = [item date];
    float nameDateWidth = [Geometry widthForName:userName date:date view:self.view];
    if (self.view.frame.size.width < nameDateWidth + [Geometry baseWidth]) {
        userName = [item username];
    }
    cell.nameLabel.text = [NSString stringWithFormat:@"%@ %@", userName, date];
    cell.nameLabel.font = [Helper fontForUserAndTime];
    cell.nameLabel.textColor = [UIColor darkGrayColor];
    
    //Avatar
    NSString *avatarUrl = [item avatarURL];
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
