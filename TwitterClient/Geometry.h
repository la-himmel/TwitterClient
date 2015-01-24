//
//  GeometryAndConstants.h
//  TwitterClient
//
//  Created by Ekaterina on 1/10/15.
//  Copyright (c) 2015 Ekaterina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define NO_ACCOUNTS @"No accounts presented on device. Please go to Settings and add an account."

#define AVATAR_SIZE 50
#define COMMON_OFFSET 8
#define DEFAULT_HEIGHT 150
#define TWEET_TOP_OFFSET 30
#define TWEET_LEFT_OFFSET 66
#define PIC_DEFAULT_H 96
#define LABEL_HEIGHT 21
#define DATE_DEFAULT_W 140
#define BUTTONS_HEIGHT 30

#define COLOR_LIGHT_BLUE 0xDBFDFD
#define COLOR_LIGHTER_BLUE 0xEFFEFF

@interface Geometry : NSObject

+ (CGSize)defaultLabelSizeForView:(UIView*)view;
+ (CGRect)tweetDefaultRectForView:(UIView*)view;
+ (float)baseWidth;
+ (float)baseHeight;
+ (CGSize)sizeForTweetWithContent:(NSString*)content view:(UIView*)view;
+ (float)widthForName:(NSString*)name date:(NSString*)date view:(UIView*)view;
+ (float)widthForName:(NSString*)name view:(UIView*)view;
+ (float)widthForDate:(NSString*)date view:(UIView*)view;
+ (CGSize)sizeForImageWithSize:(CGSize)oldSize view:(UIView*)view;

@end
