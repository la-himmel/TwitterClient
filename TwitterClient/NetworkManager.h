//
//  NetworkManager.h
//  TwitterClient
//
//  Created by Ekaterina on 1/20/15.
//  Copyright (c) 2015 Ekaterina. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ACAccount;

@interface NetworkManager : NSObject

- (void)getAccountsWithSuccess:(void (^)(NSArray *accounts))success
                       failure:(void (^)(NSError *error))failure;
- (void)getDataForAccount:(ACAccount*)twitterAccount
                  success:(void (^)(NSArray *data))success
                  failure:(void (^)(NSError *error))failure;
- (void)getDataForCurrentAccountSuccess:(void (^)(NSArray *data))success
                                failure:(void (^)(NSError *error))failure;
+ (NetworkManager*)sharedInstance;

@end
