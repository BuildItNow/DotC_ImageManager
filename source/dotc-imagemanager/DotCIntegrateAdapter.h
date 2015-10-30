//
//  IntegrateAdapter.h
//  dotc-imagemanager
//
//  Created by Yang G on 15-10-10.
//  Copyright (c) 2015年 .C . All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DotCIntegrateAdapter : NSObject

// NB. Must overwrite
// request the data of image named image with w and h; you must call onRequest:info: after get the image data.
- (void) request:(NSString*)image width:(int)w height:(int)h info:(void*)info;

// callback
- (void) onRequest:(NSData*)imageData info:(void*)info;

// NB. Must overwrite
// get the default place holder.
- (UIImage*)  getPlaceHolder:(NSString*)name;

// NB. Optional overwrite
// get the database path.
- (NSString*) getDatabasePath;

// NB. Optional overwrite
// the memory cache max size.s
- (int) getMaxMemoryCacheSize;

@end