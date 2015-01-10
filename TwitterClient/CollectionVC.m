//
//  CollectionVC.m
//  TwitterClient
//
//  Created by Ekaterina on 1/9/15.
//  Copyright (c) 2015 Ekaterina. All rights reserved.
//

#import "CollectionVC.h"

#define AVATAR_SIZE 50
#define COMMON_OFFSET 8
#define DEFAULT_HEIGHT 150
#define TWEET_TOP_OFFSET 34
#define PIC_DEFAULT_H 96

@interface CollectionVC () <UICollectionViewDelegateFlowLayout>
@end

@implementation CollectionVC

static NSString *const reuseIdentifier = @"cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.collectionView registerNib:[UINib nibWithNibName:@"CollectionViewCell" bundle:nil] forCellWithReuseIdentifier:reuseIdentifier];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.data.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    NSDictionary *item = [self.data objectAtIndex:indexPath.row];
    NSDictionary *media = [[item objectForKey:@"entities"] objectForKey:@"media"];
//    if (!media) {
//        cell.picHeight.constant = 0;
//        cell.tweetBottom.constant = COMMON_OFFSET;
//    } else {
//        cell.picHeight.constant = PIC_DEFAULT_H;
//        cell.tweetBottom.constant = COMMON_OFFSET*2 + PIC_DEFAULT_H;
//    }
//    [cell.contentView setNeedsUpdateConstraints];

    NSString *userName = [[item objectForKey:@"user"] objectForKey:@"name"];
    NSString *tweet = [item objectForKey:@"text"];
    NSString *date = [item objectForKey:@"created_at"];
    NSString *avatar = [[item objectForKey:@"user"] objectForKey:@"profile_image_url"];
    
    cell.nameLabel.text = userName;
    CGRect tweetRect = [self tweetDefaultRect];
    cell.tweetLabel.frame = (CGRect){cell.tweetLabel.frame.origin, tweetRect.size};
    cell.tweetLabel.text = tweet;
    [cell.tweetLabel sizeToFit];
    
    return cell;
}

- (CGRect)tweetDefaultRect
{
    CGRect frame = self.view.frame;
    CGRect labelRect = CGRectMake(2*COMMON_OFFSET + AVATAR_SIZE,
                                  TWEET_TOP_OFFSET,
                                  frame.size.width - 3*COMMON_OFFSET - AVATAR_SIZE,
                                  DEFAULT_HEIGHT);
    return labelRect;
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
    NSDictionary *media = [[item objectForKey:@"entities"] objectForKey:@"media"];
    
    CGSize tweetSize = [self sizeForTweetWithContent:[item objectForKey:@"text"]];
    
    float width = AVATAR_SIZE + 3*COMMON_OFFSET + tweetSize.width;
    float height = TWEET_TOP_OFFSET + COMMON_OFFSET + tweetSize.height;
//    if (media) {
//        height += 450;
//    }
    CGSize size = CGSizeMake(width, height);
    NSLog(@"indexpath %ld size TOTAL %@", (long)indexPath.item, NSStringFromCGSize(size));
    return size;
}

- (CGSize)sizeForTweetWithContent:(NSString*)content
{
    NSLog(@"content: %@", content);
    UILabel *tweetLabel = [[UILabel alloc] initWithFrame:[self tweetDefaultRect]];
    tweetLabel.numberOfLines = 0;
    tweetLabel.font = [UIFont fontWithName:@"HelveticaNeue-Regular" size:17.0];
    tweetLabel.text = content;
    [tweetLabel sizeToFit];
    NSLog(@"Size: %@", NSStringFromCGSize(tweetLabel.frame.size));
    return tweetLabel.frame.size;
}



@end

@implementation CollectionViewCell

@end
