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
    __block DotCImageManagerAdapter* weakSelf = self;
    if([image isEqual:@"test"])
    {
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
    
    NSDictionary* id2names =
    @{
        @"t0.jpg" : @"春-0.jpg",
        @"t1.jpg" : @"春-1.jpg",
        @"t2.jpg" : @"春-2.jpg",
        @"t3.jpg" : @"春-3.jpg",
        @"d0.jpg" : @"春-4.jpg",
        @"d1.jpg" : @"春-5.jpg",
        @"d2.jpg" : @"春-6.jpg",
    };
    
    image = [id2names objectForKey:image];
    if(!image)
    {
        dispatch_async(dispatch_get_main_queue(),
        ^{
            [weakSelf onRequest:nil info:info];
        });
        
        return ;
    }
    
    NSString* url = [NSString stringWithFormat:@"http://101.200.215.114/res/img/%@", image];
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:30.0f];
 
    
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
