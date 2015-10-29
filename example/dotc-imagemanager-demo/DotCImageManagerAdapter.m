//
//  DotCImageManagerAdapter.m
//  dotc-imagemanager-demo
//
//  Created by Yang G on 15/10/10.
//  Copyright © 2015年 .C . All rights reserved.
//

#import "DotCImageManagerAdapter.h"

@interface DotCImageManagerAdapter ()
{
    NSOperationQueue*       _connQueue;
    int                     _maxCacheSize;
    UIImage*                _placeHolder;
    UIImage*                _test;
}

@end

@implementation DotCImageManagerAdapter


- (instancetype) init
{
    if(!(self = [super init]))
    {
        return nil;
    }
    
    _connQueue = [NSOperationQueue mainQueue];
    [_connQueue retain];
    
    _maxCacheSize = 5*1024*1024;
    
    _placeHolder = [[UIImage imageNamed:@"placeHolder"] retain];
    _test        = [[UIImage imageNamed:@"wave.jpg"] retain];
    
    return self;
}

- (void) dealloc
{
    [_test release];
    _test = nil;
    [_placeHolder release];
    _placeHolder = nil;
    [_connQueue release];
    _connQueue = nil;
    
    [super dealloc];
}

- (void)onRequestDone:(NSHTTPURLResponse*)resp data:(NSData*)data error:(NSError*)error info:(void*)info
{
    if(error)
    {
        [self onRequest:nil info:info];
    
        return ;
    }
    
    if(resp.statusCode != 200 && resp.statusCode != 304)
    {
        [self onRequest:nil info:info];
        
        return ;
    }
    
    [self onRequest:data info:info];
}

- (void) request:(NSString*)image width:(int)w height:(int)h info:(void*)info
{
    if([image isEqual:@"test"])
    {
        __block DotCImageManagerAdapter* weakSelf = self;
        dispatch_async(dispatch_get_main_queue(),
        ^{
            UIGraphicsBeginImageContext(CGSizeMake(w, h));
            [_test drawInRect:CGRectMake(0, 0, w, h)];
            UIImage* img = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            [weakSelf onRequest:UIImageJPEGRepresentation(img, 1.0) info:info];
        });
        
        return ;
    }
    
    NSArray* urls =
    @[
        @"http://www.bit-now.com/BINImages/d0.jpg",
        @"http://www.bit-now.com/BINImages/d1.jpg",
        @"http://www.bit-now.com/BINImages/d2.jpg",
        @"http://www.bit-now.com/BINImages/t0.jpg",
        @"http://www.bit-now.com/BINImages/t1.jpg",
        @"http://www.bit-now.com/BINImages/t2.jpg",
        @"http://www.bit-now.com/BINImages/t3.jpg"
    ];
    
    
    NSString* url = [NSString stringWithFormat:@"http://www.bit-now.com/BINImages/%@", image];//urls[rand()%urls.count];
    NSURL* nsUrl = [NSURL URLWithString:url];
    NSURLRequest * request = [NSURLRequest requestWithURL:nsUrl cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:30.0f]; //maximal timeout is 30s
 
    __block DotCImageManagerAdapter* weakSelf = self;
    
    [NSURLConnection sendAsynchronousRequest:request queue:_connQueue completionHandler: ^(NSURLResponse *resp, NSData * data, NSError * error)
    {
        dispatch_async(dispatch_get_main_queue(),
        ^{
            [weakSelf onRequestDone:(NSHTTPURLResponse*)resp data:data error:error info:info];
        });
    }];
}

- (UIImage*)  getPlaceHolder:(NSString*)name
{
    return _placeHolder;
}

- (int)  getMaxMemoryCacheSize
{
    return _maxCacheSize;
}

- (void) setMaxMemoryCacheSize:(int)size
{
    _maxCacheSize = size;
}

+ (instancetype) instance
{
    static DotCImageManagerAdapter* s_instance = nil;
    if(!s_instance)
    {
        s_instance = [[DotCImageManagerAdapter alloc] init];
    }
    
    return s_instance;
}

@end
