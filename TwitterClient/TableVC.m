//
//  TableVC.m
//  TwitterClient
//
//  Created by Ekaterina on 1/9/15.
//  Copyright (c) 2015 Ekaterina. All rights reserved.
//

#import "TableVC.h"
#import "NSDictionary+twitterFields.h"
#import "GeometryAndConstants.h"

@interface TableVC ()
@end

static NSString *const reuseIdentifier = @"tablecell";
static NSString *const reuseImageIdentifier = @"tableImageCell";

@implementation TableVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:@"TableViewCell" bundle:nil] forCellReuseIdentifier:reuseIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"TableViewImageCell" bundle:nil] forCellReuseIdentifier:reuseImageIdentifier];
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
        mcell.picHeight.constant = [[mediaInfo objectForKey:MEDIA_H] intValue];
        mcell.picWidth.constant = [[mediaInfo objectForKey:MEDIA_W] intValue];
        UIImage *placeholder = [Geometry imageWithColor:[UIColor clearColor]];
        mcell.pic.image = placeholder;
        NSString *mediaUrl = [mediaInfo objectForKey:MEDIA_URL];
        [mcell.contentView setNeedsUpdateConstraints];
        [mcell layoutIfNeeded];
        
        __weak TableViewImageCell *wcell = mcell;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:mediaUrl]];
            if (imageData) {
                UIImage *image = [UIImage imageWithData:imageData];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (wcell)
                        [wcell.pic setImage:image];
                });
            }
        });
    } else {
        TableViewCell *mcell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
        cell = mcell;
    }
    
    UIColor *backgroundColor = indexPath.row %2 ? UIColorFromRGB(0xEFFEFF) : UIColorFromRGB(0xDBFDFD);
    cell.contentView.backgroundColor = backgroundColor;
    
    NSString *userName = [item authorUsername];
    NSString *tweet = [item tweet];
    NSString *date = [item date];
    NSString *avatarUrl = [item avatarURL];
    
    [cell.contentView setNeedsUpdateConstraints];
    
    //    +cache
    __weak BaseTableViewCell *wcell = cell;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:avatarUrl]];
        if (imageData) {
            UIImage *image = [UIImage imageWithData:imageData];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (wcell)
                    [wcell.avatar setImage:image];
            });
        }
    });

    cell.tweetLabel.text = tweet;
    
    cell.nameLabel.frame = (CGRect){cell.nameLabel.frame.origin,
        [Geometry defaultLabelSizeForView:self.view]};
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *item = [self.data objectAtIndex:indexPath.item];
    NSDictionary *mediaInfo = [item mediaURLAndSize];
    CGSize tweetSize = [Geometry sizeForTweetWithContent:[item tweet] view:self.view];
    float height = [Geometry baseHeight] + tweetSize.height;
    if (mediaInfo) {
        height += [[mediaInfo objectForKey:MEDIA_H] intValue] + COMMON_OFFSET;
    }
    return height;
}

- (void)reload
{
    [self.tableView reloadData];
}

@end

@implementation BaseTableViewCell
@end

@implementation TableViewCell
@end

@implementation TableViewImageCell
@end
