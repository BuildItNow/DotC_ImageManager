//
//  IntegrateAdapter.h
//  dotc-imagemanager
//
//  Created by Yang G on 15-10-10.
//  Copyright (c) 2015年 .C . All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DotCIntegrateAdapter : NSObject

- (void) request:(NSString*)image width:(int)w height:(int)h info:(void*)info;
- (void) onRequest:(NSData*)imageData info:(void*)info;
- (UIImage*)  getPlaceHolder:(NSString*)name;
- (NSString*) getDatabasePath;
- (int) getMaxMemoryCacheSize;

@end