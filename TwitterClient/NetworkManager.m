//
//  NetworkManager.m
//  TwitterClient
//
//  Created by Ekaterina on 1/20/15.
//  Copyright (c) 2015 Ekaterina. All rights reserved.
//

#import "NetworkManager.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>

#define API_URL @"https://api.twitter.com/1.1/statuses/"
#define TIMELINE @"user_timeline.json"
#define HOME @"home_timeline.json"
#define RETWEET_FORMAT @"https://api.twitter.com/1.1/statuses/retweet/%@.json"
#define UNFAV_FORMAT @"https://api.twitter.com/1.1/favorites/destroy.json"
#define FAV_FORMAT @"https://api.twitter.com/1.1/favorites/create.json"
#define UNRETW_FORMAT @"https://api.twitter.com/1.1/statuses/destroy/%@.json"
#define URL_SHOW @"https://api.twitter.com/1.1/statuses/show/%@.json?include_my_retweet=1"
#define KEY_COUNT @"count"
#define KEY_INCL_ENTITIES @"include_entities"
#define KEY_INCL_MY_RETW @"include_my_retweet"
#define KEY_MAX_ID @"max_id"
#define VALUE_COUNT @"20"
#define VALUE_ENT @"1"

@interface NetworkManager()
@property (nonatomic, strong) NSArray *accounts;
@property (nonatomic, strong) ACAccount *account;

@end

@implementation NetworkManager

static NetworkManager *instanceNetworkManager = nil;

+ (NetworkManager*)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instanceNetworkManager = [[NetworkManager alloc] init];
    });
    return instanceNetworkManager;
}

+ (id) allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (instanceNetworkManager == nil) {
            instanceNetworkManager = [super allocWithZone:zone];
            return instanceNetworkManager;
        }
    }
    return nil;
}

- (void)getAccountsWithSuccess:(void (^)(NSArray *accounts))success
                       failure:(void (^)(NSError *error))failure
{
    ACAccountStore *account = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [account accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [account requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
        if (granted) {
            self.accounts = [NSArray arrayWithArray:[account accountsWithAccountType:accountType]];
            if ([self.accounts count]) {
                if (success)
                    success(self.accounts);
            } else {
                NSLog(@"Error: no accounts");
                if (failure)
                    failure(nil);
            }            
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (failure)
                    failure(error);
            });
            NSLog(@"Error: %@", [error description]);
        }
    }];
}

- (void)getDataForCurrentAccountSuccess:(void (^)(NSArray *data))success
                                failure:(void (^)(NSError *error))failure
{
    [self getDataForAccount:self.account success:success failure:failure];
}

- (void)getDataForAccount:(ACAccount*)twitterAccount
                  success:(void (^)(NSArray *data))success
                  failure:(void (^)(NSError *error))failure
{
    if (!self.account)
        self.account = twitterAccount;
    NSURL *apiUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", API_URL, HOME]];
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    [parameters setObject:VALUE_COUNT forKey:KEY_COUNT];
    [parameters setObject:VALUE_ENT forKey:KEY_INCL_ENTITIES];
    [parameters setObject:VALUE_ENT forKey:KEY_INCL_MY_RETW];
    
    SLRequest *posts = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                          requestMethod:SLRequestMethodGET
                                                    URL:apiUrl
                                             parameters:parameters];
    posts.account = twitterAccount;
    [posts performRequestWithHandler:^(NSData *responseData,
                                       NSHTTPURLResponse *urlResponse,
                                       NSError *error) {
        if (error && failure)
            failure(error);
        else
            [self processData:responseData success:success failure:failure];
    }];
}

- (void)getNextPageDataMaxId:(NSString*)maxId
                     success:(void (^)(NSArray *data))success
                     failure:(void (^)(NSError *error))failure
{
    NSURL *apiUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", API_URL, HOME]];
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    [parameters setObject:VALUE_COUNT forKey:KEY_COUNT];
    [parameters setObject:VALUE_ENT forKey:KEY_INCL_ENTITIES];
    [parameters setObject:maxId forKey:KEY_MAX_ID];
    [parameters setObject:VALUE_ENT forKey:KEY_INCL_MY_RETW];
    
    SLRequest *posts = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                          requestMethod:SLRequestMethodGET
                                                    URL:apiUrl
                                             parameters:parameters];
    posts.account = self.account;
    
    [posts performRequestWithHandler:^(NSData *responseData,
                                       NSHTTPURLResponse *urlResponse,
                                       NSError *error) {
        if (error && failure)
            failure(error);
        else
            [self processData:responseData success:success failure:failure];
    }];
}

- (NSArray*)accounts
{
    return _accounts;
}

- (ACAccount*)currentAccount
{
    return _account;
}

#pragma mark - Retweets and favorites

- (void)retweetTweetId:(NSString*)tweetId
               success:(void (^)(NSArray *data))success
               failure:(void (^)(NSError *error))failure
{
    NSDictionary *parameters = [NSDictionary dictionaryWithObject:tweetId forKey:@"status"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:RETWEET_FORMAT, tweetId]];
    [self postRequestUrl:url success:success failure:failure parameters:parameters];}

- (void)unretweetTweetId:(NSString*)tweetId
               success:(void (^)(NSArray *data))success
               failure:(void (^)(NSError *error))failure
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:UNRETW_FORMAT, tweetId]];
    NSDictionary *parameters = @{@"id": tweetId};
    [self postRequestUrl:url success:success failure:failure parameters:parameters];
}

- (void)favouriteTweetId:(NSString*)tweetId
                 success:(void (^)(NSArray *data))success
                 failure:(void (^)(NSError *error))failure
{
    NSURL *url = [NSURL URLWithString:FAV_FORMAT];
    NSDictionary *parameters = @{@"id": tweetId};
    [self postRequestUrl:url success:success failure:failure parameters:parameters];
}

- (void)unfavouriteTweetId:(NSString*)tweetId
                 success:(void (^)(NSArray *data))success
                 failure:(void (^)(NSError *error))failure
{
    NSURL *url = [NSURL URLWithString:UNFAV_FORMAT];
    NSDictionary *parameters = @{@"id": tweetId};
    [self postRequestUrl:url success:success failure:failure parameters:parameters];
}

- (void)postRequestUrl:(NSURL*)url
               success:(void (^)(NSArray *data))success
               failure:(void (^)(NSError *error))failure
            parameters:(NSDictionary*)parameters
{
    SLRequest *twitterRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                   requestMethod:SLRequestMethodPOST
                                                             URL:url
                                                      parameters:parameters];
    twitterRequest.account = self.account;
    [twitterRequest performRequestWithHandler:^(NSData *responseData,
                                                NSHTTPURLResponse *urlResponse,
                                                NSError *error) {
        
//        NSString *json = [[NSString alloc] initWithData:responseData
//                                               encoding:NSUTF8StringEncoding];
//        NSLog(@"%@", json);
        if (error && failure)
            failure(error);
        else
            [self processSingleTweet:responseData success:success failure:failure];
    }];
}

#pragma mark - Data processing

- (void)processSingleTweet:(NSData*)responseData
            success:(void (^)(NSArray *data))success
            failure:(void (^)(NSError *error))failure
{
    NSError *error;
    NSDictionary *obj = [NSJSONSerialization JSONObjectWithData:responseData
                                                    options:NSJSONReadingMutableLeaves
                                                      error:&error];
    
    if ([obj objectForKey:@"id_str"]) {
        NSArray *data = [NSArray arrayWithObject:obj];
        if (success)
            success(data);
    } else if ([self objectIsServerError:obj]) {
        NSString *message = [self errorMessageFromObject:obj];
        NSMutableDictionary *details = [NSMutableDictionary new];
        [details setValue:message forKey:NSLocalizedDescriptionKey];
        NSError *error1 = [NSError errorWithDomain:@"TwitterClient"
                                              code:[self errorCodeFromObject:obj]
                                          userInfo:details];
        if (failure)
            failure(error1);
    } else if (error) {
        if (failure)
            failure(error);
    } else {
        NSLog(@"Unexpected error");
        NSString *json = [[NSString alloc] initWithData:responseData
                                               encoding:NSUTF8StringEncoding];
        NSLog(@"%@", json);
    }
}


- (void)processData:(NSData*)responseData
            success:(void (^)(NSArray *data))success
            failure:(void (^)(NSError *error))failure
{
    NSError *error;
    NSObject *obj = [NSJSONSerialization JSONObjectWithData:responseData
                                                    options:NSJSONReadingMutableLeaves
                                                      error:&error];
    if ([self objectIsValidData:obj]) {
        NSArray *data = (NSArray*)obj;
        if (success)
            success(data);
    } else if ([self objectIsServerError:obj]) {
        NSString *message = [self errorMessageFromObject:obj];        
        NSMutableDictionary *details = [NSMutableDictionary new];
        [details setValue:message forKey:NSLocalizedDescriptionKey];
        NSError *error1 = [NSError errorWithDomain:@"TwitterClient"
                                            code:[self errorCodeFromObject:obj]
                                        userInfo:details];
        if (failure)
            failure(error1);
    } else if (error) {
        if (failure)
            failure(error);
    } else {
        NSLog(@"Unexpected error");
        NSString *json = [[NSString alloc] initWithData:responseData
                                               encoding:NSUTF8StringEncoding];
        NSLog(@"%@", json);
    }
}

- (NSString*)errorMessageFromObject:(NSObject*)obj
{
    NSDictionary *data = (NSDictionary*)obj;
    NSDictionary *error = [[data objectForKey:@"errors"] firstObject];
    NSString *message = [error objectForKey:@"message"];
    return message;
}

- (NSInteger)errorCodeFromObject:(NSObject*)obj
{
    NSDictionary *data = (NSDictionary*)obj;
    NSDictionary *error = [[data objectForKey:@"errors"] firstObject];
    NSInteger code = [[error objectForKey:@"code"] integerValue];
    return code;
}

- (BOOL)objectIsValidData:(NSObject*)obj
{
    return [obj isKindOfClass:[NSArray class]];
}

- (BOOL)objectIsServerError:(NSObject*)obj
{
    NSDictionary *error = (NSDictionary*)obj;
    if ([error objectForKey:@"errors"] != nil)
        return YES;
    return NO;
}

@end
