//
//  CollectionVC.m
//  TwitterClient
//
//  Created by Ekaterina on 1/9/15.
//  Copyright (c) 2015 Ekaterina. All rights reserved.
//

#import "CollectionVC.h"
#import "NSDictionary+twitterFields.h"
#import "GeometryAndConstants.h"
#import "ImageLoader.h"
#import "NetworkManager.h"
#import "Helper.h"

#define CELL_MIN_H 66

@interface CollectionVC () <UICollectionViewDelegateFlowLayout, UIScrollViewDelegate>
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, assign) BOOL refreshing;
@end

@implementation CollectionVC

static NSString *const reuseIdentifier = @"cell";
static NSString *const reuseImageIdentifier = @"imagecell";

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.collectionView registerNib:[UINib nibWithNibName:@"CollectionViewCell" bundle:nil] forCellWithReuseIdentifier:reuseIdentifier];
    [self.collectionView registerNib:[UINib nibWithNibName:@"CollectionViewImageCell" bundle:nil] forCellWithReuseIdentifier:reuseImageIdentifier];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(pullToRefresh)
             forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:self.refreshControl];
}

- (void)pullToRefresh
{
    NetworkManager *manager = [NetworkManager sharedInstance];
    __weak CollectionVC *wself = self;
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

- (void)loadMore
{
    self.refreshing = YES;
    NSDictionary *lastTweet = [self.data lastObject];
    NSInteger lastId = [[lastTweet objectForKey:@"id"] integerValue];
    NSString *lastIdPrev = [NSString stringWithFormat:@"%ld", lastId -1]; //Twitter API instruction
    
    NetworkManager *manager = [NetworkManager sharedInstance];
    __weak CollectionVC *wself = self;
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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.data.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *item = [self.data objectAtIndex:indexPath.row];
    NSDictionary *mediaInfo = [item mediaURLAndSize];

    BaseCollectionViewCell *cell = nil;
    if (mediaInfo) {
        CollectionViewImageCell *mcell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseImageIdentifier forIndexPath:indexPath];
        cell = mcell;
        [self configureMediaCell:mcell withMedia:mediaInfo];
        
    } else {
        CollectionViewCell *mcell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
        cell = mcell;
    }
    
    UIColor *backgroundColor = UIColorFromRGB(0xDBFDFD);
    cell.backgroundColor = backgroundColor;
    
    cell.layer.cornerRadius = 5.0;
    cell.layer.masksToBounds = YES;
    
    NSString *userName = [item authorUsername];
    NSString *tweet = [item tweet];
    NSString *date = [item date];
    NSString *avatarUrl = [item avatarURL];
    
    cell.avatar.layer.cornerRadius = 3.0;
    cell.avatar.layer.masksToBounds = YES;
    
    __weak BaseCollectionViewCell *wcell = cell;
    [ImageLoader getImageUrl:avatarUrl success:^(NSData *imageData) {
        UIImage *image = [UIImage imageWithData:imageData];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (wcell)
                [wcell.avatar setImage:image];
        });
        
    } failure:^(NSError *error) {
        NSLog(@"Error: %@", [error description]);
    }];
    
    float nameDateWidth = [Geometry widthForName:userName date:date view:self.view];
    if (self.view.frame.size.width < nameDateWidth + [Geometry baseWidth]) {
        //small space, show only username
        userName = [item username];
    }

    cell.tweetLabel.text = tweet;
    cell.nameLabel.frame = (CGRect){cell.nameLabel.frame.origin, [Geometry defaultLabelSizeForView:self.view]};
    cell.nameLabel.text = [NSString stringWithFormat:@"%@ %@", userName, date];
    [cell.nameLabel sizeToFit];
    cell.nameWidth.constant = [Geometry widthForName:userName view:self.view];

    [cell setNeedsUpdateConstraints];
    [cell layoutIfNeeded];
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionFooter) {
        UICollectionReusableView *footerview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView" forIndexPath:indexPath];
        
        reusableview = footerview;
    }
    
    return reusableview;
}

- (void)reload
{
    [self.collectionView reloadData];
}

- (CGSize)collectionView:(UICollectionView*)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *item = [self.data objectAtIndex:indexPath.item];
    NSDictionary *mediaInfo = [item mediaURLAndSize];
    
    CGSize tweetSize = [Geometry sizeForTweetWithContent:[item tweet] view:self.view];
    float nameDateWidth = [Geometry widthForName:[item authorUsername]
                                            date:[item date]
                                            view:self.view];
    if (nameDateWidth + [Geometry baseWidth] > self.view.frame.size.width) {
        nameDateWidth = [Geometry widthForName:[item username]
                                          date:[item date]
                                          view:self.view];
    }
    float textContentWidth = MAX(tweetSize.width, nameDateWidth);
    float picWidth = 0;
    float height = [Geometry baseHeight] + tweetSize.height;
    
    if (mediaInfo) {
        CGSize oldSize = CGSizeMake([[mediaInfo objectForKey:MEDIA_W] intValue], [[mediaInfo objectForKey:MEDIA_H] intValue]);
        CGSize size = [Geometry sizeForImageWithSize:oldSize view:self.view];
        
        picWidth = size.width;
        height += size.height + COMMON_OFFSET;
    }
    
    float contentWidth = MAX(textContentWidth, picWidth);
    float width = [Geometry baseWidth] + contentWidth;
    if (height < CELL_MIN_H)
        height = CELL_MIN_H;
    CGSize size = CGSizeMake(width, height);
    return size;
}

- (void)configureMediaCell:(CollectionViewImageCell*)mcell withMedia:(NSDictionary*)mediaInfo
{
    CGSize oldSize = CGSizeMake([[mediaInfo objectForKey:MEDIA_W] intValue], [[mediaInfo objectForKey:MEDIA_H] intValue]);
    CGSize size = [Geometry sizeForImageWithSize:oldSize view:self.view];
    mcell.picHeight.constant = size.height;
    mcell.picWidth.constant = size.width;
    UIImage *placeholder = [Helper imageWithColor:[UIColor clearColor]];
    mcell.pic.image = placeholder;
    NSString *mediaUrl = [mediaInfo objectForKey:MEDIA_URL];
    [mcell.contentView setNeedsUpdateConstraints];
    [mcell layoutIfNeeded];
    
    __weak CollectionViewImageCell *wcell = mcell;
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
        [self loadMore];
    }
}

@end

@implementation BaseCollectionViewCell
@end

@implementation CollectionViewCell
@end

@implementation CollectionViewImageCell
@end
