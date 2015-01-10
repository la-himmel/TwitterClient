//
//  GeometryAndConstants.m
//  TwitterClient
//
//  Created by Ekaterina on 1/10/15.
//  Copyright (c) 2015 Ekaterina. All rights reserved.
//

#import "GeometryAndConstants.h"

@implementation Geometry

+ (CGSize)defaultLabelSizeForView:(UIView*)view
{
    CGRect frame = view.frame;
    CGSize size = CGSizeMake(frame.size.width - 3*COMMON_OFFSET - AVATAR_SIZE,
                             LABEL_HEIGHT);
    return size;
}

+ (CGRect)tweetDefaultRectForView:(UIView*)view
{
    CGRect frame = view.frame;
    CGRect labelRect = CGRectMake(2*COMMON_OFFSET + AVATAR_SIZE,
                                  TWEET_TOP_OFFSET,
                                  frame.size.width - [Geometry baseWidth],
                                  DEFAULT_HEIGHT);
    return labelRect;
}

+ (float)baseWidth
{
    return AVATAR_SIZE + 3*COMMON_OFFSET;
}

+ (float)baseHeight
{
    return TWEET_TOP_OFFSET + COMMON_OFFSET;
}

+ (CGSize)sizeForTweetWithContent:(NSString*)content view:(UIView*)view
{
    UILabel *tweetLabel = [[UILabel alloc] initWithFrame:[Geometry tweetDefaultRectForView:view]];
    tweetLabel.numberOfLines = 0;
    tweetLabel.font = [UIFont fontWithName:@"HelveticaNeue-Regular" size:17.0];
    tweetLabel.text = content;
    [tweetLabel sizeToFit];
    return tweetLabel.frame.size;
}

+ (float)widthForName:(NSString*)name date:(NSString*)date view:(UIView*)view
{
    return [Geometry widthForName:name view:view] + COMMON_OFFSET + [Geometry widthForDate:date view:view];
}

+ (float)widthForName:(NSString*)name view:(UIView*)view
{
    CGRect labelRect = (CGRect){CGPointZero, [Geometry defaultLabelSizeForView:view]};
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:labelRect];
    nameLabel.numberOfLines = 1;
    nameLabel.font = [UIFont fontWithName:@"HelveticaNeue-Regular" size:17.0];
    nameLabel.text = name;
    [nameLabel sizeToFit];
    return nameLabel.frame.size.width;
}

+ (float)widthForDate:(NSString*)date view:(UIView*)view
{
    CGRect labelRect = (CGRect){CGPointZero, [Geometry defaultLabelSizeForView:view]};
    UILabel *dateLabel = [[UILabel alloc] initWithFrame:labelRect];
    dateLabel.numberOfLines = 1;
    dateLabel.font = [UIFont fontWithName:@"HelveticaNeue-Regular" size:15.0];
    dateLabel.text = date;
    [dateLabel sizeToFit];
    return dateLabel.frame.size.width;
}

@end
