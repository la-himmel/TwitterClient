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

@interface TableViewCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UIImageView *avatar;
@property (nonatomic, weak) IBOutlet UIImageView *pic;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;
@property (nonatomic, weak) IBOutlet UILabel *tweetLabel;
@end
