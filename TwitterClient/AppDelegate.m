//
//  AppDelegate.m
//  TwitterClient
//
//  Created by Ekaterina on 1/8/15.
//  Copyright (c) 2015 Ekaterina. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

#define MINS_TO_RELOAD 5

@interface AppDelegate ()
@property (nonatomic, assign) BOOL shouldRefreshOnForeground;
@property (nonatomic, strong) NSDate *dateClosed;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.shouldRefreshOnForeground = NO;
    self.dateClosed = nil;
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    self.shouldRefreshOnForeground = YES;
    self.dateClosed = [NSDate date];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    if (self.shouldRefreshOnForeground) {
        NSDate *now = [NSDate date];
        NSTimeInterval secondsBetween = [now timeIntervalSinceDate:self.dateClosed];
        int minutes = secondsBetween / 60;
        
        if (self.dateClosed && minutes > MINS_TO_RELOAD) {
            ViewController *vc = (ViewController*)self.window.rootViewController;
            self.shouldRefreshOnForeground = NO;
            [vc updateData];
        }
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
