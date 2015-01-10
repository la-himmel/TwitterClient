//
//  TableVC.m
//  TwitterClient
//
//  Created by Ekaterina on 1/9/15.
//  Copyright (c) 2015 Ekaterina. All rights reserved.
//

#import "TableVC.h"

@interface TableVC ()

@end

@implementation TableVC

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"1");
    [self.tableView registerClass:[TableViewCell class] forCellReuseIdentifier:@"tablecell"];
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
    UITableViewCell *cell1 = [tableView dequeueReusableCellWithIdentifier:@"tablecell" forIndexPath:indexPath];

    TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tablecell" forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[TableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"tablecell"];
    }
    
    NSDictionary *item = [self.data objectAtIndex:indexPath.row];
    
    NSString *userName = [[item objectForKey:@"user"] objectForKey:@"name"];
    NSString *tweet = [item objectForKey:@"text"];
    NSString *date = [item objectForKey:@"created_at"];
    NSString *avatar = [[item objectForKey:@"user"] objectForKey:@"profile_image_url"];

    cell.nameLabel.text = userName;
    cell.tweetLabel.text = tweet;
    
    NSLog(@"name: %@ / %@ \n %@ \n %@", userName, date, tweet, avatar);
    
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
