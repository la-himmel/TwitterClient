//
//  GeometryAndConstants.m
//  TwitterClient
//
//  Created by Ekaterina on 1/10/15.
//  Copyright (c) 2015 Ekaterina. All rights reserved.
//

#import "Geometry.h"
#import "Helper.h"

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
    CGRect labelRect = CGRectMake(COMMON_OFFSET + TWEET_LEFT_OFFSET,
                                  TWEET_TOP_OFFSET,
                                  frame.size.width - [Geometry baseWidth],
                                  DEFAULT_HEIGHT);
    return labelRect;
}

+ (float)baseWidth
{
    return TWEET_LEFT_OFFSET + COMMON_OFFSET;
}

+ (float)baseHeight
{
    return TWEET_TOP_OFFSET + COMMON_OFFSET + BUTTONS_HEIGHT;
}

+ (CGSize)sizeForTweetWithContent:(NSString*)content view:(UIView*)view
{
    UITextView *tweet =
        [[UITextView alloc] initWithFrame:[Geometry tweetDefaultRectForView:view]];
    tweet.font = [Helper fontForTweet];
    tweet.contentInset = UIEdgeInsetsZero;
    tweet.textContainer.lineFragmentPadding = 0;
    tweet.text = content;
    CGSize size = [tweet sizeThatFits:tweet.frame.size];
    [tweet sizeToFit];
    return size;
}

+ (float)widthForName:(NSString*)name date:(NSString*)date view:(UIView*)view
{
    return [Geometry widthForName:name view:view] + COMMON_OFFSET + [Geometry widthForDate:date view:view];
}

+ (CGSize)sizeForImageWithSize:(CGSize)oldSize view:(UIView*)view
{
    float maxWidth = view.frame.size.width - [Geometry baseWidth];
    if (maxWidth < oldSize.width) {
        float newHeight = oldSize.height * maxWidth / oldSize.width;
        return CGSizeMake(maxWidth, newHeight);
    }
    return oldSize;
}

+ (CGSize)fullsizeForImageWithSize:(CGSize)oldSize view:(UIView*)view
{
    float maxWidth = view.frame.size.width;
    float maxHeight = view.frame.size.height;

    if (maxWidth < oldSize.width) {
        float newHeight = oldSize.height * maxWidth / oldSize.width;
        return CGSizeMake(maxWidth, newHeight);
    } else if (maxHeight < oldSize.height) {
        float newWidth = oldSize.width * maxHeight / oldSize.height;
        return CGSizeMake(newWidth, maxHeight);
    }
    return oldSize;
//        if (maxHeight < oldSize.height) {
//            float newWidth = oldSize.width * maxHeight / oldSize.height;
//            return CGSizeMake(newWidth, maxHeight);
//        } else if (maxWidth < oldSize.width) {
//            float newHeight = oldSize.height * maxWidth / oldSize.width;
//            return CGSizeMake(maxWidth, newHeight);
//        }
//        return oldSize;
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
    dateLabel.font = [UIFont fontWithName:@"HelveticaNeue-Regular" size:17.0];
    dateLabel.text = date;
    [dateLabel sizeToFit];
    return dateLabel.frame.size.width;
}

@end
