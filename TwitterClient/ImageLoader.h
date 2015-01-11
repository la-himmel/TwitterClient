//
//  ImageLoader.h
//  TwitterClient
//
//  Created by Ekaterina on 1/11/15.
//  Copyright (c) 2015 Ekaterina. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageLoader : NSObject

+ (void)getImageUrl:(NSString*)url
            success:(void (^)(NSData *imageData))success
            failure:(void (^)(NSError *error))failure;

@end
