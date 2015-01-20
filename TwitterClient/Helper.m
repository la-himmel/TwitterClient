//
//  Helper.m
//  TwitterClient
//
//  Created by Ekaterina on 1/20/15.
//  Copyright (c) 2015 Ekaterina. All rights reserved.
//

#import "Helper.h"
#import <UIKit/UIKit.h>

@implementation Helper

+ (UIAlertView*)alertWithMessage:(NSString*)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    
    return alert;
}

+ (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIFont*)fontForTweet
{
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17.0];
    return font;
}

+ (UIFont*)fontForUserAndTime
{
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17.0];
    return font;    
}

@end
