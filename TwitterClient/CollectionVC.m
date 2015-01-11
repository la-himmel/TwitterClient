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

@interface CollectionVC () <UICollectionViewDelegateFlowLayout>
@end

@implementation CollectionVC

static NSString *const reuseIdentifier = @"cell";
static NSString *const reuseImageIdentifier = @"imagecell";

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.collectionView registerNib:[UINib nibWithNibName:@"CollectionViewCell" bundle:nil] forCellWithReuseIdentifier:reuseIdentifier];
    [self.collectionView registerNib:[UINib nibWithNibName:@"CollectionViewImageCell" bundle:nil] forCellWithReuseIdentifier:reuseImageIdentifier];
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
        mcell.picHeight.constant = [[mediaInfo objectForKey:MEDIA_H] intValue];
        mcell.picWidth.constant = [[mediaInfo objectForKey:MEDIA_W] intValue];
        UIImage *placeholder = [Geometry imageWithColor:[UIColor clearColor]];
        mcell.pic.image = placeholder;
        NSString *mediaUrl = [mediaInfo objectForKey:MEDIA_URL];
        [mcell.contentView setNeedsUpdateConstraints];
        [mcell layoutIfNeeded];
        
        __weak CollectionViewImageCell *wcell = mcell;
        [ImageLoader getImageUrl:mediaUrl success:^(NSData *imageData) {
            if (imageData) {
                UIImage *image = [UIImage imageWithData:imageData];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (wcell)
                        [wcell.pic setImage:image];
                });
            }
        } failure:^(NSError *error) {
            NSLog(@"Error: %@", [error description]);
        }];
        
    } else {
        CollectionViewCell *mcell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
        cell = mcell;
    }
    
    UIColor *backgroundColor = UIColorFromRGB(0xDBFDFD);
    cell.backgroundColor = backgroundColor;
    
    NSString *userName = [item authorUsername];
    NSString *tweet = [item tweet];
    NSString *date = [item date];
    NSString *avatarUrl = [item avatarURL];
    
    __weak BaseCollectionViewCell *wcell = cell;
    [ImageLoader getImageUrl:avatarUrl success:^(NSData *imageData) {
        if (imageData) {
            UIImage *image = [UIImage imageWithData:imageData];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (wcell)
                    [wcell.avatar setImage:image];
            });
        }
    } failure:^(NSError *error) {
        NSLog(@"Error: %@", [error description]);
    }];

    cell.tweetLabel.text = tweet;
    cell.nameLabel.frame = (CGRect){cell.nameLabel.frame.origin, [Geometry defaultLabelSizeForView:self.view]};
    cell.nameLabel.text = userName;
    [cell.nameLabel sizeToFit];
    cell.nameWidth.constant = cell.nameLabel.frame.size.width;

    cell.dateLabel.frame = (CGRect){cell.dateLabel.frame.origin,
        CGSizeMake(DATE_DEFAULT_W, LABEL_HEIGHT)};
    cell.dateLabel.text = date;
    [cell.dateLabel sizeToFit];
    cell.dateWidth.constant = [Geometry widthForDate:date view:self.view];
    
    [cell.contentView setNeedsUpdateConstraints];
    [cell.contentView layoutIfNeeded];
    return cell;
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
    float textContentWidth = MAX(tweetSize.width, nameDateWidth);
    float picWidth = 0;
    if (mediaInfo) {
        picWidth = [[mediaInfo objectForKey:MEDIA_W] floatValue];
    }
    
    float contentWidth = MAX(textContentWidth, picWidth);
    float width = [Geometry baseWidth] + contentWidth;
    float height = [Geometry baseHeight] + tweetSize.height;
    
    if (mediaInfo) {
        height += [[mediaInfo objectForKey:MEDIA_H] floatValue] + COMMON_OFFSET;
    }
    
    CGSize size = CGSizeMake(width, height);
    return size;
}

@end

@implementation BaseCollectionViewCell
@end

@implementation CollectionViewCell
@end

@implementation CollectionViewImageCell
@end
