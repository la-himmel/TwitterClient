//
//  BaseVC.m
//  TwitterClient
//
//  Created by Ekaterina on 1/20/15.
//  Copyright (c) 2015 Ekaterina. All rights reserved.
//

#import "BaseVC.h"
#import "NetworkManager.h"
#import "Helper.h"

@interface BaseVC ()
@end

@implementation BaseVC

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)loadMoreWithSuccess:(void (^)(NSArray *data))success
                    failure:(void (^)(NSError *error))failure
{
    self.refreshing = YES;
    NSDictionary *lastTweet = [self.data lastObject];
    NSInteger lastId = [[lastTweet objectForKey:@"id"] integerValue];
    NSString *lastIdPrev = [NSString stringWithFormat:@"%ld", lastId -1]; //Twitter API instruction
    
    __weak BaseVC *wself = self;
    NetworkManager *manager = [NetworkManager sharedInstance];
    [manager getNextPageDataMaxId:lastIdPrev success:^(NSArray *data) {
        wself.refreshing = NO;
        if (success)
            success(data);
    } failure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            wself.refreshing = NO;
            [[Helper alertWithMessage:[error description]] show];
            if (failure)
                failure(error);
        });
    }];
}

- (void)pullToRefreshWithSuccess:(void (^)())success
{
    NetworkManager *manager = [NetworkManager sharedInstance];
    __weak __typeof(&*self)wself = self;
    [manager getDataForCurrentAccountSuccess:^(NSArray *data) {
        dispatch_async(dispatch_get_main_queue(), ^{
            wself.data = [NSMutableArray arrayWithArray:data];
            [wself.refreshControl endRefreshing];
            if (success)
                success();
        });
    } failure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[Helper alertWithMessage:[error description]] show];
        });
    }];
}


@end
