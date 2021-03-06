//
//  CollectionVC.m
//  TwitterClient
//
//  Created by Ekaterina on 1/9/15.
//  Copyright (c) 2015 Ekaterina. All rights reserved.
//

#import "CollectionVC.h"
#import "NSDictionary+twitterFields.h"
#import "Geometry.h"
#import "ImageLoader.h"
#import "NetworkManager.h"
#import "Helper.h"
#import "UIView+cell.h"

#define CELL_MIN_H 66

@interface CollectionVC () <UICollectionViewDelegateFlowLayout, UIScrollViewDelegate,
UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@end

@implementation CollectionVC

static NSString *const reuseIdentifier = @"cell";
static NSString *const reuseImageIdentifier = @"imagecell";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(pullToRefresh)
                  forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:self.refreshControl];
}

- (void)pullToRefresh
{
    [self pullToRefreshWithSuccess:^{
        [self reload];
    }];
}

- (void)loadMore
{
    __weak CollectionVC *wself = self;
    [self loadMoreWithSuccess:^(NSArray *data) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSInteger totalBeforeUpdate = [wself.data count];
            [wself.data addObjectsFromArray:data];
            NSMutableArray *indexPaths = [NSMutableArray new];
            for (NSInteger i = totalBeforeUpdate; i < [wself.data count]; i++) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
                [indexPaths addObject:indexPath];
            }
            [wself.collectionView insertItemsAtIndexPaths:indexPaths];
        });
    } failure:nil];
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
    
    //Tweet
    cell.tweet.contentInset = UIEdgeInsetsZero;
    cell.tweet.textContainer.lineFragmentPadding = 0;
    cell.tweet.text = [item tweet];
    cell.tweet.font = [Helper fontForTweet];
    
    [self configureNameLabel:cell.nameLabel item:item];
    
    [cell setFavorited:[item favorited]];
    [cell setRetweeted:[item retweeted]];

    [self configureImageView:cell.avatar withUrl:[item avatarURL]];
    
    UIColor *backgroundColor = [UIColor whiteColor];
    cell.backgroundColor = backgroundColor;
    cell.layer.cornerRadius = 5.0;
    cell.layer.masksToBounds = YES;
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

- (IBAction)retweet:(id)sender
{
    UIButton *button = sender;
    BaseCollectionViewCell *cell = (BaseCollectionViewCell*)[button collectionCell];
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    NSDictionary *item = [self.data objectAtIndex:indexPath.item];
    
    if ([item retweeted]) {
        if (![item retweetedId]) {
            NSLog(@"Error: no retweeted id");
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [cell setRetweeted:NO];
            [cell setNeedsDisplay];
        });
        [[NetworkManager sharedInstance] unretweetTweetId:[item retweetedId] success:^(NSArray *data) {
            [self toggleKey:KEY_RETWEETED_BY_ME forItemAtIndex:indexPath.item];
            [self.baseParent setDataChangedForTable];

        } failure:^(NSError *error) {
            NSLog(@"Unretweet failed, %@", [error localizedDescription]);
        }];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [cell setRetweeted:YES];
            [cell setNeedsDisplay];
        });
        [[NetworkManager sharedInstance] retweetTweetId:[item idStr] success:^(NSArray *data) {
            [self toggleKey:KEY_RETWEETED_BY_ME forItemAtIndex:indexPath.item];
            [self.baseParent setDataChangedForTable];

        } failure:^(NSError *error) {
            NSLog(@"Retweet failed, %@", [error localizedDescription]);
        }];
    }}

- (IBAction)favorite:(id)sender
{
    UIButton *button = sender;
    BaseCollectionViewCell *cell = (BaseCollectionViewCell*)[button collectionCell];
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    NSDictionary *item = [self.data objectAtIndex:indexPath.item];
    if ([item favorited]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [cell setFavorited:NO];
            [cell setNeedsDisplay];
        });
        [[NetworkManager sharedInstance] unfavouriteTweetId:[item idStr] success:^(NSArray *data) {
            [self toggleKey:KEY_FAVORITE forItemAtIndex:indexPath.row];
            [self.baseParent setDataChangedForTable];

        } failure:^(NSError *error) {
            NSLog(@"Unfav failed, %@", [error localizedDescription]);
        }];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [cell setFavorited:YES];
            [cell setNeedsDisplay];
        });
        [[NetworkManager sharedInstance] favouriteTweetId:[item idStr] success:^(NSArray *data) {
            [self toggleKey:KEY_FAVORITE forItemAtIndex:indexPath.row];
            [self.baseParent setDataChangedForTable];

        } failure:^(NSError *error) {
            NSLog(@"Fav failed, %@", [error localizedDescription]);
        }];
    }
}

- (IBAction)openImage:(id)sender
{
    UIButton *button = sender;
    BaseCollectionViewCell *cell = (BaseCollectionViewCell*)[button collectionCell];
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    NSMutableDictionary *item = [self.data objectAtIndex:indexPath.row];
    NSDictionary *mediaInfo = [item mediaURLAndSize];
    [self.baseParent openImageWithDictionary:mediaInfo];
}

- (void)addItems:(NSArray*)newItems
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSRange range = NSMakeRange(0, [newItems count]);
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
        [self.data insertObjects:newItems atIndexes:indexSet];
        NSMutableArray *indexPaths = [NSMutableArray new];
        for (NSInteger i = 0; i < [newItems count]; i++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
            [indexPaths addObject:indexPath];
        }
        [self.collectionView insertItemsAtIndexPaths:indexPaths];
    });
    
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
        [self loadMore];
    }
}

@end

@implementation BaseCollectionViewCell

- (void)setFavorited:(BOOL)favorited
{
    [self configureIcon:self.favorite on:favorited];
}

- (void)setRetweeted:(BOOL)retweeted
{
    [self configureIcon:self.retweet on:retweeted];
}

- (void)configureIcon:(UIImageView*)icon on:(BOOL)on
{
    icon.alpha = on ? 0.5 : 0.15;
}

@end

@implementation CollectionViewCell
@end

@implementation CollectionViewImageCell
@end
