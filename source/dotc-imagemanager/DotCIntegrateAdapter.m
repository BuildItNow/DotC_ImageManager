//
//  IntegrateAdapter.m
//  dotc-imagemanager
//
//  Created by Yang G on 15-10-10.
//  Copyright (c) 2015年 .C . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DotCIntegrateAdapter.h"
#import "DotCImageManager.h"

@implementation DotCIntegrateAdapter

- (void) onRequest:(NSData *)imageData info:(void *)info
{
    [DOTC_IMAGE_MANAGER onReceivedImageData:imageData info:info];
}

- (NSString*) getDatabasePath
{
    NSArray*  paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString* path = [paths[0] stringByAppendingPathComponent:@"dotc"];
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:TRUE attributes:nil  error:nil];
    }
    
    return path;
}

- (int) getMaxMemoryCacheSize
{
    return 10*1024*1024;
}

@end

