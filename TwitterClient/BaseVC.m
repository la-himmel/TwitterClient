//
//  BaseVC.m
//  TwitterClient
//
//  Created by Ekaterina on 1/20/15.
//  Copyright (c) 2015 Ekaterina. All rights reserved.
//

#import "BaseVC.h"
#import "NetworkManager.h"

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
    
    NetworkManager *manager = [NetworkManager sharedInstance];
    [manager getNextPageDataMaxId:lastIdPrev success:^(NSArray *data) {
        if (success)
            success(data);
    } failure:^(NSError *error) {
        if (failure)
            failure(error);
    }];
}

@end
