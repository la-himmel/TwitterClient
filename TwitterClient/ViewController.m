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
#import "ImageLoader.h"
#import "NetworkManager.h"
#import "Geometry.h"
#import <Accounts/Accounts.h>
#import "Helper.h"
#import <Social/Social.h>

#define DURATION 0.4

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
    self.viewForTable.alpha = 1.0;
    self.viewForCollection.alpha = 0.0;
    [self updateData];
}

- (void)updateData
{
    NetworkManager *networkManager = [NetworkManager sharedInstance];
    __weak ViewController *wself = self;
    [networkManager getAccountsWithSuccess:^(NSArray *accounts) {
        //show popup to choose
        
        ACAccount *firstAcc = [accounts firstObject];
        [networkManager getDataForAccount:firstAcc success:^(NSArray *data) {
            dispatch_async(dispatch_get_main_queue(), ^{
                wself.tableVC.data = [NSMutableArray arrayWithArray:data];
                [wself.tableVC reload];
                wself.collectionVC.data = [NSMutableArray arrayWithArray:data];
                [wself.collectionVC reload];
            });
        } failure:^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[Helper alertWithMessage:[error localizedDescription]] show];
            });
        }];
        
    } failure:^(NSError *error) {
        if (error) { //explainable error
            [[Helper alertWithMessage:[error localizedDescription]] show];
        } else { //no accounts
            NSString *showVersion = @"8.0";
            NSString *version = [[UIDevice currentDevice] systemVersion];
            if ([version compare:showVersion options:NSNumericSearch] != NSOrderedAscending) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self showSettingsDialog];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[Helper alertWithMessage:NO_ACCOUNTS] show];
                });
            }
        }
    }];
}

- (void)setUserAccount:(ACAccount*)account
{
    NSString *username = account.username;
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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)didChangeSegmentedControl:(id)sender
{
    UISegmentedControl *segmented = (UISegmentedControl*)sender;
    BOOL tableShown = (segmented.selectedSegmentIndex == 0);
    [UIView animateWithDuration:DURATION animations:^{
        self.viewForTable.alpha = !tableShown ? 0.0 : 1.0;
        self.viewForCollection.alpha = tableShown ? 0.0 : 1.0;
    }];
}

- (IBAction)composeTweet:(id)sender
{
    SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    [controller addImage:[UIImage imageNamed:@"socialsharing-facebook-image.jpg"]];
    controller.completionHandler = ^(SLComposeViewControllerResult result) {
        BOOL needsReload = NO;
        switch(result) {
            case SLComposeViewControllerResultCancelled:
                break;
            case SLComposeViewControllerResultDone: {
                needsReload = YES;
            }
                break;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self dismissViewControllerAnimated:NO completion:^{
                NSLog(@"Tweet Sheet has been dismissed.");
                if (needsReload) {
                    [self updateData];
                }
            }];
        });
    };
    [self presentViewController:controller animated:NO completion:nil];
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

- (void)showSettingsDialog
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:NO_ACCOUNTS
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Open settings", nil];
    [alert show];
}

@end
