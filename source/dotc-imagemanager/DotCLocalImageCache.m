//
//  LocalImageCache.m
//  dotc-imagemanager
//
//  Created by Yang G on 15-10-10.
//  Copyright (c) 2015年 .C . All rights reserved.
//

#import "Defines.h"
#import "DotCImageManager.h"
#import "DotCIntegrateAdapter.h"
#import "DotCLocalImageCache.h"
#import "DotCUtil.h"

@interface DotCImageCacheItem()
{
    NSString*           _key;
    UIImage*            _image;
    CGSize              _hsize;
    uint32_t            _crc;
    uint32_t            _flags;
    uint32_t            _lastUpdateTime;
    DotCDBLinkNode*         _node;
}

@end

@implementation DotCImageCacheItem

- (instancetype) initWith:(NSString*)key image:(UIImage*)image flags:(uint32_t)flags
{
    if(!(self = [super init]))
    {
        return self;
    }
    
    _key   = [key copy];
    _image = [image retain];
    _crc   = 0;
    _flags = flags;
    
    _hsize.width = _hsize.height = 0.0f;
    
    return self;
}

- (void) dealloc
{
    [_image release];
    [_key release];
    [_node unLink];
    [_node release];
    
    [super dealloc];
}

- (UIImage*) image
{
    return _image;
}

- (CGSize) imageSize
{
    return _image.size;
}

- (CGSize) hintSize
{
    return _hsize;
}

- (void) setHintSize:(CGSize)size
{
    _hsize = size;
}

- (int) imageLength
{
    CGSize size = [self imageSize];
    return size.width*size.height*4;    // Not a accurate value
}

- (uint32_t) crc
{
    if(_crc == 0)
    {
        NSData* data = UIImageJPEGRepresentation(_image, 1.0f);
        if(data)
        {
            _crc = [DotCUtil crc32:data];
        }
        else
        {
            _crc = rand();  // Arbitrary value, avoid calculate crc many times, but it's an error state
        }
    }
    return _crc;
}

- (NSString*)key
{
    return _key;
}

- (uint32_t) flags
{
    return _flags;
}

- (void) updateTime
{
    _lastUpdateTime = (uint32_t)[[NSDate date] timeIntervalSince1970];
}

- (DotCDBLinkNode*) node
{
    if(!_node)
    {
        _node = [DotCDBLinkNode nodeFrom:self];
        [_node retain];
    }
    
    return _node;
}

+ (instancetype) itemFrom:(NSString*)key image:(UIImage*)image flags:(uint32_t)flags
{
    DotCImageCacheItem* ret = WEAK_OBJECT(self, initWith:key image:image flags:flags);
    
    return ret;
}

+ (instancetype) itemFrom:(NSString*)key image:(UIImage*)image flags:(uint32_t)flags crc:(uint32_t)crc
{
    DotCImageCacheItem* ret = WEAK_OBJECT(self, initWith:key image:image flags:flags);
    
    ret->_crc = crc;
    
    return ret;
}

@end

@interface DotCLocalImageCache()
{
    NSMutableDictionary*        _cacheItems;
    int                         _cacheLength;
    DotCDBLinkNode*                 _cacheItemList;
    bool                        _tryCollecting;
}

@end


@implementation DotCLocalImageCache

- (instancetype) init
{
    if(!(self = [super init]))
    {
        return self;
    }
    
    _cacheItems  = STRONG_OBJECT(NSMutableDictionary, init);
    _cacheLength = 0;
    _cacheItemList = [[DotCDBLinkNode nodeFrom:nil] retain];
    [_cacheItemList linkAfter:_cacheItemList];
    
    _tryCollecting = false;
    
    return self;
}

- (void) dealloc
{
    [_cacheItems release];
    _cacheLength = 0;
    
    [_cacheItemList release];
    
    [super dealloc];
}

- (int) cacheLength
{
    return _cacheLength;
}

- (DotCDBLinkNode*) cacheItemList
{
    return _cacheItemList;
}

- (DotCImageCacheItem*) cacheItem:(NSString*)key
{
    return [_cacheItems objectForKey:key];
}

- (int) removeCacheItem:(DotCImageCacheItem*)item
{
    [item.node unLink];
    
    _cacheLength -= item.imageLength;
    
    [_cacheItems removeObjectForKey:item.key];
    
    return _cacheLength;
}

- (int) addOrReplaceCacheItem:(DotCImageCacheItem*)item
{
    DotCImageCacheItem* oldItem = [_cacheItems objectForKey:item.key];
    if(oldItem)
    {
        [self removeCacheItem:oldItem];
    }
    
    return [self addCacheItem:item];
}

- (int) addCacheItem:(DotCImageCacheItem*)item
{
    [_cacheItems setObject:item forKey:item.key];
    _cacheLength += item.imageLength;
    
    [item updateTime];
    [item.node linkAfter:_cacheItemList];
    
    NSLog(@"[%@] Memory Cost : %dK", LIB_TAG, (int)(_cacheLength/1024.0f));
    
    [self tryCollectMemory];
    
    return _cacheLength;
}

- (void) tryCollectMemory
{
    const int MAX_CACHE_LENGTH = [[DotCImageManager integrateAdapter] getMaxMemoryCacheSize];
    const int HALF_MAX_CACHE_LENGTH = MAX_CACHE_LENGTH/2;
    if(_cacheLength >= MAX_CACHE_LENGTH && !_tryCollecting)
    {
        _tryCollecting = true;
        dispatch_async(dispatch_get_main_queue(), ^
                       {
                           if(self.cacheLength < MAX_CACHE_LENGTH)
                           {
                               return ;
                           }
                           
                           int oldMemory = self.cacheLength;
                           
                           DotCDBLinkNode* node = self.cacheItemList.prev;
                           DotCDBLinkNode* prev = nil;
                           while(node && node!=self.cacheItemList)
                           {
                               prev = node.prev;
                               
                               if([self removeCacheItem:node.value] < HALF_MAX_CACHE_LENGTH)
                               {
                                   break;
                               }
                               
                               node = prev;
                           }
                           
                           self->_tryCollecting = false;
                           
                           NSLog(@"[%@] Collect Memory %.3fK", LIB_TAG, (oldMemory-self.cacheLength)/1024.0f);
                       }
                       );
    }
}

- (void) clear
{
    int oldMemory = self.cacheLength;
    
    DotCDBLinkNode* node = self.cacheItemList.prev;
    DotCDBLinkNode* prev = nil;
    while(node && node!=self.cacheItemList)
    {
        prev = node.prev;
        
        [self removeCacheItem:node.value];
        
        node = prev;
    }

    NSLog(@"[%@] Clean memory cache %.3fK", LIB_TAG, (oldMemory-self.cacheLength)/1024.0f);
}

@end
