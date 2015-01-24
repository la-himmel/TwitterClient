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

#define KEY_COUNT @"count"
#define KEY_INCL_ENTITIES @"include_entities"
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

- (void)getNextPageDataMaxId:(NSString*)maxId
                     success:(void (^)(NSArray *data))success
                     failure:(void (^)(NSError *error))failure
{
    NSURL *apiUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", API_URL, HOME]];
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    [parameters setObject:VALUE_COUNT forKey:KEY_COUNT];
    [parameters setObject:VALUE_ENT forKey:KEY_INCL_ENTITIES];
    [parameters setObject:maxId forKey:@"max_id"];
    
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
