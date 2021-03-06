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

+ (NetworkManager*)sharedInstance;

- (void)getAccountsWithSuccess:(void (^)(NSArray *accounts))success
                       failure:(void (^)(NSError *error))failure;
- (void)getDataForAccount:(ACAccount*)twitterAccount
                  success:(void (^)(NSArray *data))success
                  failure:(void (^)(NSError *error))failure;
- (void)getDataForCurrentAccountSuccess:(void (^)(NSArray *data))success
                                failure:(void (^)(NSError *error))failure;
- (void)getNextPageDataMaxId:(NSString*)maxId
                     success:(void (^)(NSArray *data))success
                     failure:(void (^)(NSError *error))failure;

- (NSArray*)accounts;
- (ACAccount*)currentAccount;

- (void)retweetTweetId:(NSString*)tweetId
               success:(void (^)(NSArray *data))success
               failure:(void (^)(NSError *error))failure;
- (void)unretweetTweetId:(NSString*)tweetId
                 success:(void (^)(NSArray *data))success
                 failure:(void (^)(NSError *error))failure;
- (void)favouriteTweetId:(NSString*)tweetId
                 success:(void (^)(NSArray *data))success
                 failure:(void (^)(NSError *error))failure;
- (void)unfavouriteTweetId:(NSString*)tweetId
                   success:(void (^)(NSArray *data))success
                   failure:(void (^)(NSError *error))failure;

@end
