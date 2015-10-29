//
//  ImageDatabase.h
//  dotc-imagemanager
//
//  Created by Yang G on 15-10-10.
//  Copyright (c) 2015年 .C . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DotCImageDatabase : NSObject

- (NSData*) imageData:(NSString*)key;
- (NSData*) imageData:(NSString*)key other:(NSData**)other;
- (int) save:(NSString*)key imageData:(NSData*)data;
- (int) save:(NSString*)key imageData:(NSData*)data other:(NSData*)other;

- (void) clear:(float)daysAgo;
- (int)  getDatabaseSize;
@end
