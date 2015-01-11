//
//  ImageLoader.m
//  TwitterClient
//
//  Created by Ekaterina on 1/11/15.
//  Copyright (c) 2015 Ekaterina. All rights reserved.
//

#import "ImageLoader.h"

@implementation ImageLoader

+ (NSString*)path
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@"/Images"];
    
    NSError *error;
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])
        [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error];
    return dataPath;
}

+ (NSString*)nameFromUrl:(NSString*)url
{
    NSArray *parts = [url componentsSeparatedByString:@"/"];
    NSString *name = [parts lastObject];
    return name;
}

+ (void)getImageUrl:(NSString*)url
            success:(void (^)(NSData *imageData))success
            failure:(void (^)(NSError *error))failure
{
    NSString *name = [ImageLoader nameFromUrl:url];
    NSString *path = [NSString stringWithFormat:@"%@/%@", [ImageLoader path], name];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSData *imageData = [fileManager contentsAtPath:path];
        if (success && imageData)
            success(imageData);
    } else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
            if (data) {
                NSFileManager *fileManager = [NSFileManager defaultManager];
                if(![fileManager fileExistsAtPath:path])
                {
                    [data writeToFile:path atomically:YES];
                } else {
                    NSFileHandle *myHandle = [NSFileHandle fileHandleForWritingAtPath:path];
                    [myHandle seekToEndOfFile];
                    [myHandle writeData:data];
                }
                success(data);
            }
        });
    }
}

+ (void)cleanCache
{
    NSString *path = [ImageLoader path];
    NSArray *filesArray = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:path error:nil];
    NSEnumerator *filesEnumerator = [filesArray objectEnumerator];
    NSString *fileName;
    
    while (fileName = [filesEnumerator nextObject]) {
        NSError *error;
        [[NSFileManager defaultManager] removeItemAtPath:[path stringByAppendingPathComponent:fileName] error:&error];
        if (error)
            NSLog(@"error removing file: %@", error.description);
    }
}

@end
