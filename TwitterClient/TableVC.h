//
//  TableVC.h
//  TwitterClient
//
//  Created by Ekaterina on 1/9/15.
//  Copyright (c) 2015 Ekaterina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseVC.h"

@interface TableVC : BaseVC

- (void)reload;
- (void)addItems:(NSArray*)newItems;
@end

@interface BaseTableViewCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UIImageView *avatar;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UITextView *tweet;
@end

@interface TableViewImageCell : BaseTableViewCell
@property (nonatomic, weak) IBOutlet UIImageView *pic;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *picWidth;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *picHeight;
@end

@interface TableViewCell : BaseTableViewCell
@end
