//
//  NSDictionary+twitterFields.m
//  TwitterClient
//
//  Created by Ekaterina on 1/10/15.
//  Copyright (c) 2015 Ekaterina. All rights reserved.
//

#import "NSDictionary+twitterFields.h"

#define KEY_ENTITY @"entity"
#define KEY_RETWEETED @"retweeted_status"

@implementation NSDictionary (twitterFields)

- (NSString*)author
{
    return [[self objectForKey:KEY_USER] objectForKey:KEY_NAME];
}

- (NSString*)authorUsername
{
    NSString *name = [[self objectForKey:KEY_USER] objectForKey:KEY_NAME];
    NSString *nick = [[self objectForKey:KEY_USER] objectForKey:KEY_NICKNAME];
    return [NSString stringWithFormat:@"%@ (@%@)", name, nick];
}

- (NSString*)tweet
{
    if ([self objectForKey:KEY_RETWEETED]) {
        return [[self objectForKey:KEY_RETWEETED] objectForKey:KEY_TEXT];
    }
    return [self objectForKey:KEY_TEXT];
}

- (NSString*)avatarURL
{
    return [[self objectForKey:KEY_USER] objectForKey:KEY_AVATAR];
}

- (NSString*)date
{
    //simplified date formatting. it should be more complicated, using
    //date formatters and determining if the tweet was today, etc.
    NSString *rawDate = [self objectForKey:KEY_CREATED];
    NSArray *components = [rawDate componentsSeparatedByString:@" "];
    return [NSString stringWithFormat:@"- %@ %@", components[1], components[2]];
}


@end
