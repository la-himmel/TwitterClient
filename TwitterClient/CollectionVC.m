//
//  CollectionVC.m
//  TwitterClient
//
//  Created by Ekaterina on 1/9/15.
//  Copyright (c) 2015 Ekaterina. All rights reserved.
//

#import "CollectionVC.h"

@interface CollectionVC ()

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
    
    NSString *userName = [[item objectForKey:@"user"] objectForKey:@"name"];
    NSString *tweet = [item objectForKey:@"text"];
    NSString *date = [item objectForKey:@"created_at"];
    NSString *avatar = [[item objectForKey:@"user"] objectForKey:@"profile_image_url"];
    
    cell.nameLabel.text = userName;
    cell.tweetLabel.text = tweet;
    
    return cell;
}

- (void)reload
{
    [self.collectionView reloadData];
}

@end

@implementation CollectionViewCell

@end
