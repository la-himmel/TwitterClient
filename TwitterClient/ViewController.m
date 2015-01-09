//
//  ViewController.m
//  TwitterClient
//
//  Created by Ekaterina on 1/8/15.
//  Copyright (c) 2015 Ekaterina. All rights reserved.
//

#import "ViewController.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>

#define API_URL @"http://api.twitter.com/1.1/statuses/user_timeline.json"
#define API_KEY @"nRpsj7pkldHieAbjQrHOdZCpb"
#define CONSUMER_SECRET @"h3Ldr7GAVgsfnh9p15uwDMjRMSAfCB1OloU9quy8CyGeiQHnH9"

@interface ViewController () <NSURLSessionDelegate>
@property (nonatomic, strong) NSArray *data;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self twitterConnection];
    [self getAccounts];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getAccounts
{
    ACAccountStore *account = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [account accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    __weak ViewController *weakSelf = self;
    [account requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
        if (granted) {
            NSLog(@"granted");
            
            NSArray *accounts = [account accountsWithAccountType:accountType];
            if ([accounts count]) {
                ACAccount *twitterAccount = [accounts firstObject];
                NSURL *apiUrl = [NSURL URLWithString:API_URL];
                NSMutableDictionary *parameters = [NSMutableDictionary new];
                [parameters setObject:@"100" forKey:@"count"];
                [parameters setObject:@"1" forKey:@"include_entities"];
                
                SLRequest *posts = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                      requestMethod:SLRequestMethodGET
                                                                URL:apiUrl
                                                         parameters:parameters];
                posts.account = twitterAccount;
                
                [posts performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                    weakSelf.data = [NSJSONSerialization JSONObjectWithData:responseData
                                                                    options:NSJSONReadingMutableLeaves
                                                                      error:&error];
                    if (weakSelf.data.count) {
                        NSLog(@"Succeed, count %lu", (unsigned long)weakSelf.data.count);
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            NSLog(@"reload the table");
                            
                        });
                    } else {
                        NSLog(@"Nothing");
                    }
                }];
                
            } else {
                NSLog(@"Error: no accounts");
            }
            
        } else {
            NSLog(@"Error: %@", [error description]);
        }
    }];
    
}

- (void)twitterConnection
{
    //1. URL encode the consumer key and the consumer secret according to RFC 1738.
    NSString *encodedApiKey = [API_KEY stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *encodedSecret = [CONSUMER_SECRET stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    //2. Concatenate the encoded consumer key, a colon character “:”, and the encoded consumer secret into a single string.
    NSString *bearer = [NSString stringWithFormat:@"%@:%@", encodedApiKey, encodedSecret];
    
    //3. Base64 encode the string from the previous step.
    NSString *base64EncodedString = [[bearer dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];
    
    NSLog(@"%@", base64EncodedString);
    
    //send request
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    
    NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/oauth2/token"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    NSString *auth = [NSString stringWithFormat:@"Basic %@", base64EncodedString];
    [request addValue:auth forHTTPHeaderField:@"Authorization"];
    [request addValue:@"application/x-www-form-urlencoded;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    NSData *postData = [@"grant_type=client_credentials" dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:postData];

    
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request
                                                    completionHandler:^(NSData *data,
                                                                        NSURLResponse *response,
                                                                        NSError *error)
    {
        if (error) {
            NSLog(@"Error: %@", [error description]);
        }
        if (data) {
            NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data
                                                                       options:NSJSONReadingMutableLeaves error:&error];
            NSString *access_token = [dictionary objectForKey:@"access_token"];
            NSLog(@"access_token %@", access_token);
        }
    }];
    
    [postDataTask resume];
    
    
}

@end
