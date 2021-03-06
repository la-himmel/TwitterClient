//
//  BaseVC.h
//  TwitterClient
//
//  Created by Ekaterina on 1/20/15.
//  Copyright (c) 2015 Ekaterina. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BaseVCParent <NSObject>
@required
- (void)openImageWithDictionary:(NSDictionary*)mediaInfo;
- (void)setDataChangedForTable;
- (void)setDataChangedForCollection;

@end

@interface BaseVC : UIViewController
@property (nonatomic, strong) NSMutableArray *data;
@property (nonatomic, assign) BOOL refreshing;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, weak) id<BaseVCParent> baseParent;
@property (nonatomic, assign) BOOL dataChanged;

- (void)loadMoreWithSuccess:(void (^)(NSArray *data))success
                    failure:(void (^)(NSError *error))failure;
- (void)pullToRefreshWithSuccess:(void (^)())success;
- (void)configureImageView:(UIImageView*)imageView withUrl:(NSString*)url;
- (float)configureNameLabel:(UILabel*)nameLabel item:(NSDictionary*)item;
- (void)toggleKey:(NSString*)key forItemAtIndex:(NSInteger)index;
@end
