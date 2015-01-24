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
#import "ImageLoader.h"
#import "NSDictionary+twitterFields.h"
#import "Geometry.h"

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
            [[Helper alertWithMessage:[error localizedDescription]] show];
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
            [[Helper alertWithMessage:[error localizedDescription]] show];
        });
    }];
}

- (float)configureNameLabel:(UILabel*)nameLabel item:(NSDictionary*)item
{
    NSString *userName = [item authorUsername];
    NSString *date = [item date];
    float nameDateWidth = [Geometry widthForName:userName date:date view:self.view];
    if (self.view.frame.size.width < nameDateWidth + [Geometry baseWidth]) {
        userName = [item username];
    }
    nameLabel.text = [NSString stringWithFormat:@"%@ %@", userName, date];
    nameLabel.font = [Helper fontForUserAndTime];
    nameLabel.textColor = [UIColor darkGrayColor];
    float width = [Geometry widthForName:userName view:self.view];
    return width;
}

- (void)configureImageView:(UIImageView*)imageView withUrl:(NSString*)url
{
    imageView.layer.cornerRadius = 3.0;
    imageView.layer.masksToBounds = YES;
    UIImage *placeholder = [Helper imageWithColor:[UIColor clearColor]];
    imageView.image = placeholder;
    
    __weak UIImageView *imageV = imageView;
    [ImageLoader getImageUrl:url success:^(NSData *imageData) {
        UIImage *image = [UIImage imageWithData:imageData];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (imageV)
                [imageV setImage:image];
        });
    } failure:^(NSError *error) {
        NSLog(@"Error: %@", [error description]);
    }];
}

@end
