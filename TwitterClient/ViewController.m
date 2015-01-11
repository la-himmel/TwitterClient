//
//  ViewController.m
//  TwitterClient
//
//  Created by Ekaterina on 1/8/15.
//  Copyright (c) 2015 Ekaterina. All rights reserved.
//

#import "ViewController.h"
#import "TableVC.h"
#import "CollectionVC.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import "ImageLoader.h"

#define API_URL @"https://api.twitter.com/1.1/statuses/"
#define TIMELINE @"user_timeline.json"
#define HOME @"home_timeline.json"
#define API_KEY @"nRpsj7pkldHieAbjQrHOdZCpb"
#define CONSUMER_SECRET @"h3Ldr7GAVgsfnh9p15uwDMjRMSAfCB1OloU9quy8CyGeiQHnH9"

#define NO_ACCOUNTS @"No accounts presented on device. Please go to Settings and add an account."

@interface ViewController () <NSURLSessionDelegate, UIAlertViewDelegate>
@property (nonatomic, strong) NSArray *data;
@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, weak) TableVC *tableVC;
@property (nonatomic, weak) CollectionVC *collectionVC;
@property (nonatomic, weak) IBOutlet UIView *viewForTable;
@property (nonatomic, weak) IBOutlet UIView *viewForCollection;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self getAccounts];
    self.viewForTable.hidden = NO;
    self.viewForCollection.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)didChangeSegmentedControl:(id)sender
{
    UISegmentedControl *segmented = (UISegmentedControl*)sender;
    BOOL tableShown = (segmented.selectedSegmentIndex == 0);
    self.viewForTable.hidden = !tableShown;
    self.viewForCollection.hidden = tableShown;
}

- (void)getAccounts
{
    ACAccountStore *account = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [account accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    __weak ViewController *weakSelf = self;
    [account requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
        if (granted) {
            NSArray *accounts = [account accountsWithAccountType:accountType];
            if ([accounts count]) {
                ACAccount *twitterAccount = [accounts firstObject];
                NSString *username = twitterAccount.username;
                
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                NSString *user = [defaults objectForKey:@"user"];
                if (!user) {
                    [defaults setObject:username forKey:@"user"];
                    [defaults synchronize];
                } else {
                    if (![user isEqualToString:username]) {
                        NSLog(@"User changed. Clean cache");
                        [ImageLoader cleanCache];
                        [defaults setObject:username forKey:@"user"];
                        [defaults synchronize];
                    }
                }
                
                NSURL *apiUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", API_URL, HOME]];
                NSMutableDictionary *parameters = [NSMutableDictionary new];
                [parameters setObject:@"100" forKey:@"count"];
                [parameters setObject:@"1" forKey:@"include_entities"];
                
                SLRequest *posts = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                      requestMethod:SLRequestMethodGET
                                                                URL:apiUrl
                                                         parameters:parameters];
                posts.account = twitterAccount;
                
                [posts performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error)
                {
                    weakSelf.data = [NSJSONSerialization JSONObjectWithData:responseData
                                                                    options:NSJSONReadingMutableLeaves
                                                                      error:&error];
                    if (weakSelf.data.count) {
//                        NSString *json = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            weakSelf.tableVC.data = weakSelf.data;
                            [weakSelf.tableVC reload];
                            weakSelf.collectionVC.data = weakSelf.data;
                            [weakSelf.collectionVC reload];
                            
                        });
                    } else if (error) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self showMessage:[error description]];
                        });
                    }
                }];
                
            } else {
                NSLog(@"Error: no accounts");
                NSString *showVersion = @"8.0";
                NSString *version = [[UIDevice currentDevice] systemVersion];
                if ([version compare:showVersion options:NSNumericSearch] != NSOrderedAscending) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self showSettingsDialog];
                    });
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self showMessage:NO_ACCOUNTS];
                    });
                }
            }
            
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showMessage:[error description]];
            });
            NSLog(@"Error: %@", [error description]);
        }
    }];
}

- (void)showMessage:(NSString*)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                      message:message
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
    
    [alert show];
}

- (void)showSettingsDialog
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                      message:NO_ACCOUNTS
                                                     delegate:self
                                            cancelButtonTitle:@"Cancel"
                                            otherButtonTitles:@"Open settings", nil];
    [alert show];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"embed_table"]) {
        self.tableVC = segue.destinationViewController;
    }
    
    if ([segue.identifier isEqualToString:@"embed_collection"]) {
        self.collectionVC = segue.destinationViewController;
    }
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
            self.accessToken = [dictionary objectForKey:@"access_token"];
            NSLog(@"access_token %@", self.accessToken);
        }
    }];
    
    [postDataTask resume];
}

#pragma mark - UIAlertView

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (!buttonIndex)
        return;
    BOOL canOpenSettings = (&UIApplicationOpenSettingsURLString != NULL);
    if (canOpenSettings) {
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:url];
    }
}

@end
