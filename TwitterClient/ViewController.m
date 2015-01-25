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
#import "NSDictionary+twitterFields.h"

#define DURATION 0.4
#define DURATION_IMAGE 0.2
#define POST_REFRESH_DELAY 1
#define SHEET_TEXT @"What account do you want to use?"

@interface ViewController () <NSURLSessionDelegate, UIAlertViewDelegate, UIActionSheetDelegate, BaseVCParent>
@property (nonatomic, strong) NSArray *data;
@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, weak) TableVC *tableVC;
@property (nonatomic, weak) CollectionVC *collectionVC;
@property (nonatomic, weak) IBOutlet UIView *viewForTable;
@property (nonatomic, weak) IBOutlet UIView *viewForCollection;
@property (nonatomic, weak) IBOutlet UIButton *postButton;
@property (nonatomic, weak) IBOutlet UIView *imageBgView;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *imageWidth;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *imageHeight;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.viewForTable.alpha = 1.0;
    self.viewForCollection.alpha = 0.0;
    self.postButton.layer.cornerRadius = 3.0;
    self.postButton.layer.masksToBounds = YES;
    self.imageBgView.alpha = 0.0;
    UITapGestureRecognizer *rec = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeImage)];
    [self.imageBgView addGestureRecognizer:rec];
    [self updateData];
}

- (void)closeImage
{
    [UIView animateWithDuration:DURATION_IMAGE animations:^{
        self.imageBgView.alpha = 0.0;
    }];  
}

- (void)updateData
{
    NetworkManager *networkManager = [NetworkManager sharedInstance];
    __weak ViewController *wself = self;
    [networkManager getAccountsWithSuccess:^(NSArray *accounts) {
        //show popup to choose
        
        ACAccount *firstAcc = [accounts firstObject];
        if ([accounts count] == 1) {
            [wself processAccount:firstAcc];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [wself showActionSheetWithAccounts:accounts];
            });
        }
        
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

- (void)refresh
{
    NetworkManager *manager = [NetworkManager sharedInstance];
    __weak __typeof(&*self)wself = self;
    [manager getDataForCurrentAccountSuccess:^(NSArray *data) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *topTweet = [wself.tableVC.data firstObject];
            NSMutableArray *newItems = [NSMutableArray new];
            for (NSDictionary *item in data) {
                if (![[topTweet idStr] isEqualToString:[item idStr]])
                    [newItems addObject:item];
                else
                    break;
                
            }
            if ([newItems count]) {
                [wself.tableVC addItems:newItems];
                [wself.collectionVC addItems:newItems];
            }
        });
    } failure:^(NSError *error) {
    }];
}

- (void)processAccount:(ACAccount*)account
{
    [self setUserAccount:account];
    __weak ViewController *wself = self;
    NetworkManager *networkManager = [NetworkManager sharedInstance];
    [networkManager getDataForAccount:account success:^(NSArray *data) {
        dispatch_async(dispatch_get_main_queue(), ^{
            wself.tableVC.data = [NSMutableArray arrayWithArray:data];
            wself.tableVC.baseParent = wself;
            [wself.tableVC reload];
            wself.collectionVC.baseParent = wself;
            wself.collectionVC.data = [NSMutableArray arrayWithArray:data];
            [wself.collectionVC reload];
        });
    } failure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[Helper alertWithMessage:[error localizedDescription]] show];
        });
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
        
    } completion:^(BOOL finished) {
        if (self.tableVC.dataChanged && tableShown) {
            self.tableVC.dataChanged = NO;
            [self.tableVC pullToRefresh];
        }
        if (self.collectionVC.dataChanged && !tableShown) {
            self.collectionVC.dataChanged = NO;
            [self.collectionVC pullToRefresh];
        }
    }];
}

- (IBAction)composeTweet:(id)sender
{
    SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
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
        [self performSelector:@selector(refresh) withObject:nil afterDelay:POST_REFRESH_DELAY];
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

#pragma mark - action sheet


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSArray *accounts = [[NetworkManager sharedInstance] accounts];
    if ([accounts count] > buttonIndex) {
        ACAccount *account = [accounts objectAtIndex:buttonIndex];
        [self processAccount:account];
    }
}

- (void)showActionSheetWithAccounts:(NSArray*)accounts
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:SHEET_TEXT
                                                             delegate:self
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:nil];
    
    for (ACAccount *account in accounts) {
        NSString *name = account.username;
        [actionSheet addButtonWithTitle:name];
    }
    
    actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:@"Cancel"];
    [actionSheet showInView:self.view];
}

#pragma mark - BaseVCParent

- (void)openImageWithDictionary:(NSDictionary*)mediaInfo
{
    [UIView animateWithDuration:DURATION_IMAGE animations:^{
        self.imageBgView.alpha = 1.0;
    }];
    UIImage *placeholder = [Helper imageWithColor:[UIColor clearColor]];
    self.imageView.image = placeholder;
    CGSize oldSize = CGSizeMake([[mediaInfo objectForKey:MEDIA_W_LARGE] intValue],
                                [[mediaInfo objectForKey:MEDIA_H_LARGE] intValue]);
    CGSize size = [Geometry fullsizeForImageWithSize:oldSize view:self.view];
    self.imageHeight.constant = size.height;
    self.imageWidth.constant = size.width;
    
    [self.view setNeedsUpdateConstraints];
    [self.view layoutIfNeeded];

    __weak UIImageView *imageV = self.imageView;
    [ImageLoader getImageUrl:[mediaInfo objectForKey:MEDIA_URL] success:^(NSData *imageData) {
        UIImage *image = [UIImage imageWithData:imageData];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (imageV)
                [imageV setImage:image];
        });
    } failure:^(NSError *error) {
        NSLog(@"Error: %@", [error description]);
    }];
}

- (void)setDataChangedForTable
{
    self.tableVC.dataChanged = YES;
}

- (void)setDataChangedForCollection
{
    self.collectionVC.dataChanged = YES;
}

@end
