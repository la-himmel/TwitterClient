//
//  NSDictionary+twitterFields.h
//  TwitterClient
//
//  Created by Ekaterina on 1/10/15.
//  Copyright (c) 2015 Ekaterina. All rights reserved.
//

#import <Foundation/Foundation.h>

#define KEY_USER @"user"
#define KEY_CREATED @"created_at"
#define KEY_TEXT @"text"
#define KEY_NAME @"name"
#define KEY_MEDIA @"media"
#define KEY_AVATAR @"profile_image_url"
#define KEY_NICKNAME @"screen_name"

#define MEDIA_URL @"url"
#define MEDIA_H @"h"
#define MEDIA_W @"w"

@interface NSDictionary (twitterFields)

- (NSString*)author;
- (NSString*)authorUsername;
- (NSString*)tweet;
- (NSString*)avatarURL;
- (NSString*)date;
- (NSDictionary*)mediaURLAndSize;
- (NSString*)username;
- (NSString*)idStr;

@end
