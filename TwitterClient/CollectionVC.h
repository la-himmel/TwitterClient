//
//  CollectionVC.h
//  TwitterClient
//
//  Created by Ekaterina on 1/9/15.
//  Copyright (c) 2015 Ekaterina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseVC.h"

@interface CollectionVC : BaseVC
@property (nonatomic, strong) NSMutableArray *data;

- (void)reload;

@end

@interface BaseCollectionViewCell : UICollectionViewCell
@property (nonatomic, weak) IBOutlet UIImageView *avatar;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UITextView *tweet;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *nameWidth;
@end

@interface CollectionViewImageCell : BaseCollectionViewCell
@property (nonatomic, weak) IBOutlet UIImageView *pic;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *picHeight;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *picWidth;
@end

@interface CollectionViewCell : BaseCollectionViewCell
@end
