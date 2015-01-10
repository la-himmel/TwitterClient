//
//  TableVC.m
//  TwitterClient
//
//  Created by Ekaterina on 1/9/15.
//  Copyright (c) 2015 Ekaterina. All rights reserved.
//

#import "TableVC.h"
#import "NSDictionary+twitterFields.h"

@interface TableVC ()

@end

static NSString *const reuseIdentifier = @"tablecell";

@implementation TableVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:@"TableViewCell" bundle:nil] forCellReuseIdentifier:reuseIdentifier];
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
    TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
//    if (cell == nil) {
//        cell = [[TableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
//                                      reuseIdentifier:@"tablecell"];
//    }
    
    NSDictionary *item = [self.data objectAtIndex:indexPath.row];
    
    NSString *userName = [item author];
    NSString *tweet = [item tweet];
    NSString *date = [item date];
    NSString *avatar = [item avatarURL];

    cell.nameLabel.text = userName;
    cell.tweetLabel.text = tweet;
    
//    NSLog(@"name: %@ / %@ \n %@ \n %@", userName, date, tweet, avatar);
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 134.0;
}

- (void)reload
{
    [self.tableView reloadData];
}

@end

@implementation TableViewCell

@end
