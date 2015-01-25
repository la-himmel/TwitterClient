//
//  NSDictionary+twitterFields.m
//  TwitterClient
//
//  Created by Ekaterina on 1/10/15.
//  Copyright (c) 2015 Ekaterina. All rights reserved.
//

#import "NSDictionary+twitterFields.h"

#define KEY_ENTITIES @"entities"
#define KEY_RETWEETED @"retweeted_status"
#define KEY_MEDIA_URL @"media_url"
#define KEY_ID_STRING @"id_str"
#define KEY_CURR_RETWEET @"current_user_retweet"


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

- (NSString*)username
{
    NSString *nick = [[self objectForKey:KEY_USER] objectForKey:KEY_NICKNAME];
    return [NSString stringWithFormat:@"@%@", nick];
}

- (NSString*)tweet
{
//    if ([self objectForKey:KEY_RETWEETED]) {
//        return [[self objectForKey:KEY_RETWEETED] objectForKey:KEY_TEXT];
//    }
    return [self objectForKey:KEY_TEXT];
}

- (NSString*)avatarURL
{
    return [[self objectForKey:KEY_USER] objectForKey:KEY_AVATAR];
}

- (NSDictionary*)mediaURLAndSize
{
    NSDictionary *result = nil;
    NSDictionary *entities = [self objectForKey:KEY_ENTITIES];
    NSArray *mediaArray = [entities objectForKey:KEY_MEDIA];
    if ([mediaArray count]) {
        NSDictionary *media = [mediaArray objectAtIndex:0];
        NSString *url = [media objectForKey:KEY_MEDIA_URL];
        NSDictionary *size = [[media objectForKey:@"sizes"] objectForKey:@"medium"];
        int width = [[size objectForKey:MEDIA_W] intValue];
        int height = [[size objectForKey:MEDIA_H] intValue];
        
        NSDictionary *largeSize = [[media objectForKey:@"sizes"] objectForKey:@"large"];
        int largeWidth = [[largeSize objectForKey:MEDIA_W] intValue];
        int largeHeight = [[largeSize objectForKey:MEDIA_H] intValue];
        
        if (url && width && height) {
            result = @{ MEDIA_URL : url,
                        MEDIA_W : [NSNumber numberWithInt:width],
                        MEDIA_H : [NSNumber numberWithInt:height],
                        MEDIA_W_LARGE : [NSNumber numberWithInt:largeWidth],
                        MEDIA_H_LARGE : [NSNumber numberWithInt:largeHeight]};
        }
        return result;
    }
    return result;
}

- (NSString*)date
{
    //simplified date formatting. it should be more complicated, using
    //date formatters and determining if the tweet was today, etc.
    NSString *rawDate = [self objectForKey:KEY_CREATED];
    NSArray *components = [rawDate componentsSeparatedByString:@" "];
    return [NSString stringWithFormat:@"- %@ %@", components[1], components[2]];
}

- (NSString*)idStr
{
    return [self objectForKey:KEY_ID_STRING];
}

- (BOOL)favorited
{
    return [[self objectForKey:KEY_FAVORITE] boolValue];
}

- (BOOL)retweeted
{
    return [[self objectForKey:KEY_RETWEETED_BY_ME] boolValue];
}

- (NSString*)retweetedId
{
    return [[self objectForKey:KEY_CURR_RETWEET] objectForKey:KEY_ID_STRING];
}

@end
