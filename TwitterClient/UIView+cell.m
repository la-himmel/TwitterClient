//
//  UIView+cell.m
//  TwitterClient
//
//  Created by Ekaterina on 1/24/15.
//  Copyright (c) 2015 Ekaterina. All rights reserved.
//

#import "UIView+cell.h"

@implementation UIView (cell)

- (UIView *)findSuperViewWithClass:(Class)superViewClass
{
    UIView *superView = self.superview;
    UIView *foundSuperView = nil;
    
    while (nil != superView && nil == foundSuperView) {
        if ([superView isKindOfClass:superViewClass]) {
            foundSuperView = superView;
        } else {
            superView = superView.superview;
        }
    }
    return foundSuperView;
}

- (UITableViewCell *)tableCell
{
    UITableViewCell *cell = (UITableViewCell*)[self findSuperViewWithClass:[UITableViewCell class]];
    return cell;
}

- (UICollectionViewCell *)collectionCell
{
    UICollectionViewCell *cell = (UICollectionViewCell*)[self findSuperViewWithClass:[UICollectionViewCell class]];
    return cell;
}

@end
