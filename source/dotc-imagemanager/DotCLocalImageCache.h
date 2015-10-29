//
//  LocalImageCache.h
//  dotc-imagemanager
//
//  Created by Yang G on 15-10-10.
//  Copyright (c) 2015年 .C . All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DotCDBLinkNode.h"

@interface DotCImageCacheItem : NSObject

- (UIImage*) image;
- (uint32_t) crc;
- (NSString*)key;
- (CGSize) imageSize;
- (CGSize) hintSize;
- (void)   setHintSize:(CGSize)size;
- (uint32_t) flags;
- (int) imageLength;
- (void) updateTime;
- (DotCDBLinkNode*) node;

+ (instancetype) itemFrom:(NSString*)key image:(UIImage*)image flags:(uint32_t)flags;
+ (instancetype) itemFrom:(NSString*)key image:(UIImage*)image flags:(uint32_t)flags crc:(uint32_t)crc;

@end

@interface DotCLocalImageCache : NSObject

- (int) cacheLength;
- (DotCDBLinkNode*) cacheItemList;
- (DotCImageCacheItem*) cacheItem:(NSString*)key;
- (int) removeCacheItem:(DotCImageCacheItem*)item;
- (int) addCacheItem:(DotCImageCacheItem*)item;
- (void) clear;

@end
