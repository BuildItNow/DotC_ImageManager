//
//  ImageManager.h
//  dotc-imagemanager
//
//  Created by Yang G on 15-10-10.
//  Copyright (c) 2015年 .C . All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString* IMAGE_ARGUMENT_IMAGE;
extern NSString* IMAGE_ARGUMENT_KEY;
extern NSString* IMAGE_ARGUMENT_ERROR;

@class DotCIntegrateAdapter;

@interface DotCImageManager : NSObject

- (void) retrieveImage:(NSString*)key delegatorID:(NSString*)delegatorID;
- (void) retrieveImage:(NSString*)key delegatorID:(NSString*)delegatorID width:(float)w height:(float)h;
- (void) clearLocalCache;
- (void) clearCache:(float)daysAgo;
- (int)  getCacheSize;
- (int)  getLocalCacheSize;

+ (instancetype) instance;
+ (void) setIntegrateAdapter:(DotCIntegrateAdapter*)adapter;
+ (DotCIntegrateAdapter*)integrateAdapter;

@end

#define DOTC_IMAGE_MANAGER [DotCImageManager instance]