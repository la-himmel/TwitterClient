//
//  TableVC.h
//  TwitterClient
//
//  Created by Ekaterina on 1/9/15.
//  Copyright (c) 2015 Ekaterina. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TableVC : UITableViewController
@property (nonatomic, strong) NSArray *data;

- (void)reload;

@end

@interface BaseTableViewCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UIImageView *avatar;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;
@property (nonatomic, weak) IBOutlet UILabel *tweetLabel;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *nameWidth;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *dateWidth;
@end

@interface TableViewImageCell : BaseTableViewCell
@property (nonatomic, weak) IBOutlet UIImageView *pic;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *picWidth;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *picHeight;
@end

@interface TableViewCell : BaseTableViewCell
@end
