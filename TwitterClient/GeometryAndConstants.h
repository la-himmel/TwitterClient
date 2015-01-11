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

#define AVATAR_SIZE 50
#define COMMON_OFFSET 8
#define DEFAULT_HEIGHT 150
#define TWEET_TOP_OFFSET 34
#define PIC_DEFAULT_H 96
#define LABEL_HEIGHT 21
#define DATE_DEFAULT_W 140

@interface Geometry : NSObject

+ (CGSize)defaultLabelSizeForView:(UIView*)view;
+ (CGRect)tweetDefaultRectForView:(UIView*)view;
+ (float)baseWidth;
+ (float)baseHeight;
+ (CGSize)sizeForTweetWithContent:(NSString*)content view:(UIView*)view;
+ (float)widthForName:(NSString*)name date:(NSString*)date view:(UIView*)view;
+ (float)widthForName:(NSString*)name view:(UIView*)view;
+ (float)widthForDate:(NSString*)date view:(UIView*)view;
+ (UIImage *)imageWithColor:(UIColor *)color;
+ (CGSize)sizeForImageWithSize:(CGSize)oldSize view:(UIView*)view;

@end
