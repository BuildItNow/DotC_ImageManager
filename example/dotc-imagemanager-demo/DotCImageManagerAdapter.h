//
//  DotCImageManagerAdapter.h
//  dotc-imagemanager-demo
//
//  Created by Yang G on 15/10/10.
//  Copyright © 2015年 .C . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DotCIntegrateAdapter.h"

@interface DotCImageManagerAdapter : DotCIntegrateAdapter

- (void) request:(NSString*)image width:(int)w height:(int)h info:(void*)info;
- (UIImage*)  getPlaceHolder:(NSString*)name;
- (int)  getMaxMemoryCacheSize;
- (void) setMaxMemoryCacheSize:(int)size;

+ (instancetype) instance;
@end
