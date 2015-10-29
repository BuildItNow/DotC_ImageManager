//
//  ImageManager.m
//  dotc-imagemanager
//
//  Created by Yang G on 15-10-10.
//  Copyright (c) 2015年 .C . All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Defines.h"
#import "DotCImageManager.h"

#import "DotCImageDatabase.h"
#import "DotCLocalImageCache.h"
#import "DotCDelegatorManager.h"
#import "DotCIntegrateAdapter.h"
#import "DotCImageView.h"

#import "DotCUtil.h"

NSString* IMAGE_ARGUMENT_IMAGE = @"IMAGE_ARGUMENT_IMAGE";
NSString* IMAGE_ARGUMENT_KEY   = @"IMAGE_ARGUMENT_KEY";
NSString* IMAGE_ARGUMENT_ERROR = @"IMAGE_ARGUMENT_ERROR";

enum
{
    CACHE_FLAG_ORIGINAL = BIT(0),
};

static CGSize ORIGINAL_SIZE = {5000.0f, 5000.0f};
#define IS_ORIGINAL_SIZE(size) (size.width > 4900.0f && size.height > 4900.0f)

#pragma pack(1)

enum
{
    OTHER_VERSION_1_0 = 1,
};

typedef struct
{
    uint8_t     version;
    uint16_t    width;          // Image size
    uint16_t    height;
    uint16_t    hwidth;         // Hint size, can be 0
    uint16_t    hheight;
    uint32_t    crc;
    uint32_t    flags;
}SImageCacheOther_1_0;

#pragma pack(0)

@interface RequestingImageItem : NSObject
{
    NSString*               _key;
    CGSize                  _psize;
    uint32_t                _pflags;
    CGSize                  _csize;
    uint32_t                _cflags;
    CGSize                  _hsize;
    NSMutableArray*         _delegatorIDs;
}

- (NSString*) key;
- (CGSize)    psize;
- (uint32_t)  pflags;
- (CGSize)    csize;
- (uint32_t)  cflags;
- (CGSize)    hsize;
- (void)      setCsize:(CGSize)size flags:(uint32_t)flags;
- (void)      setPsize:(CGSize)size flags:(uint32_t)flags;
- (void)      setHsize:(CGSize)size;
- (NSArray*)  delegatorIDs;

- (void) addDelegatorID:(NSString*)delegatorID;
@end

@implementation RequestingImageItem

- (instancetype) initWith:(NSString*)key
{
    if(!(self = [super init]))
    {
        return self;
    }
    
    _key  = [key copy];
    _psize.width = _psize.height = 0.0f;
    _pflags = 0;
    _csize.width = _csize.height = 0.0f;
    _cflags = 0;
    _hsize.width = _hsize.height = 0.0f;
    _delegatorIDs = STRONG_OBJECT(NSMutableArray, init);

    return self;
}

- (void) dealloc
{
    [_key release];
    [_delegatorIDs release];
    
    [super dealloc];
}

- (NSString*) key
{
    return _key;
}

- (CGSize) psize
{
    return _psize;
}

- (uint32_t) pflags
{
    return _pflags;
}

- (CGSize) csize
{
    return _csize;
}

- (uint32_t) cflags
{
    return _cflags;
}

- (CGSize)    hsize
{
    return _hsize;
}

- (void)      setCsize:(CGSize)size flags:(uint32_t)flags
{
    _csize  = size;
    _cflags = flags;
}

- (void)      setPsize:(CGSize)size flags:(uint32_t)flags
{
    _psize  = size;
    _pflags = flags;
}

- (void)      setHsize:(CGSize)size
{
    _hsize = size;
}

- (NSArray*)  delegatorIDs
{
    return _delegatorIDs;
}

- (void) addDelegatorID:(NSString*)delegatorID
{
    [_delegatorIDs addObject:delegatorID];
}

@end

@interface DotCImageManager()
{
    DotCLocalImageCache*        _localCache;
    DotCImageDatabase*          _database;
    
    NSMutableDictionary*    _requestingImages;      // key-array entry
}

@end

@implementation DotCImageManager

- (instancetype) init
{
    if(!(self = [super init]))
    {
        return self;
    }
    
    _database = STRONG_OBJECT(DotCImageDatabase, init);
    _localCache = STRONG_OBJECT(DotCLocalImageCache, init);
    _requestingImages = STRONG_OBJECT(NSMutableDictionary, init);
    
    // Force DotCImageView to export
    WEAK_OBJECT(DotCImageView, init);
    
    return self;
}

- (void) dealloc
{
    [_database release];
    [_localCache release];
    [_requestingImages release];
    
    [super dealloc];
}

- (BOOL) save:(NSString*)key image:(UIImage*)image
{
    return [self save:key image:image flags:CACHE_FLAG_ORIGINAL];
}

- (BOOL) save:(NSString*)key image:(UIImage*)image flags:(uint32_t)flags
{
    if(!image)
    {
        return FALSE;
    }
    
    key = key.lowercaseString;
    
    NSData* data = UIImagePNGRepresentation(image);
    if(!data)
    {
        return FALSE;
    }
    
    uint32_t crc = [DotCUtil crc32:data];

    // Save in local cache
    {
        DotCImageCacheItem* newItem   = nil;
        DotCImageCacheItem* oldItem   = [_localCache cacheItem:key];
        if(!oldItem || oldItem.crc != crc)
        {
            newItem = [DotCImageCacheItem itemFrom:key image:image flags:flags crc:crc];
            
            if(oldItem)
            {
                [_localCache removeCacheItem:oldItem];
                oldItem = nil;
            }
        }
        
        if(newItem)
        {
            [_localCache addCacheItem:newItem];
        }
        else
        {
            [oldItem.node unLink];  // Remove from old place
            [oldItem updateTime];   // Update last use time
            [oldItem.node linkAfter:_localCache.cacheItemList]; // Move to list front
        
            return TRUE;
        }
    }
    
    if(!_database)
    {
        return FALSE;
    }
    
    // Save in local disk
    {
        SImageCacheOther_1_0* other = malloc(sizeof(SImageCacheOther_1_0));
        other->version = OTHER_VERSION_1_0;
        other->flags   = flags;
        other->width   = (int)image.size.width;
        other->height  = (int)image.size.height;
        other->crc     = crc;
        
        if([_database save:key imageData:data other:[NSData dataWithBytesNoCopy:other length:sizeof(SImageCacheOther_1_0)]] != 0)
        {
            NSLog(@"Save Image %@ Fail", key);
            
            return FALSE;
        }
    }
    
    return  TRUE;
}

- (void) onImagePrepared:(NSString*)key image:(UIImage*)image delegatorID:(NSString*)delegatorID error:(NSError*)error
{
    dispatch_async(dispatch_get_main_queue(), ^
    {
        DotCDelegatorArguments* arguments = WEAK_OBJECT(DotCDelegatorArguments, init);
        
        if(image)
        {
            [arguments setArgument:image for:IMAGE_ARGUMENT_IMAGE];
        }
        
        [arguments setArgument:key for:IMAGE_ARGUMENT_KEY];
        
        if(error)
        {
            [arguments setArgument:error for:IMAGE_ARGUMENT_ERROR];
        }
        
        [DOTC_GLOBAL_DELEGATOR_MANAGER performDelegator:delegatorID arguments:arguments];
    });
}

- (void) onImagePrepared:(NSString*)key image:(UIImage*)image delegatorIDs:(NSArray*)delegatorIDs error:(NSError*)error
{
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       DotCDelegatorArguments* arguments = WEAK_OBJECT(DotCDelegatorArguments, init);
                       
                       if(image)
                       {
                           [arguments setArgument:image for:IMAGE_ARGUMENT_IMAGE];
                       }
                       
                       [arguments setArgument:key for:IMAGE_ARGUMENT_KEY];
                       
                       if(error)
                       {
                           [arguments setArgument:error for:IMAGE_ARGUMENT_ERROR];
                       }
                       
                       for(NSString* delegatorID in delegatorIDs)
                       {
                           [DOTC_GLOBAL_DELEGATOR_MANAGER performDelegator:delegatorID arguments:arguments];
                       }
                   });
}

- (void) retrieveImage:(NSString*)key delegatorID:(NSString*)delegatorID    // Want original picture
{
    CGSize size = ORIGINAL_SIZE;
    
    [self retrieveImage:key delegatorID:delegatorID preferedSize:size];
}

- (RequestingImageItem*) lastRequestingItem:(NSString*)key
{
    NSArray* items = [_requestingImages objectForKey:key];
    if(!items)
    {
        return nil;
    }
    
    return items.lastObject;
}

- (BOOL) does:(CGSize)src sflags:(uint32_t)sflags match:(CGSize)dst dflags:(uint32_t)dflags
{
    if(sflags&CACHE_FLAG_ORIGINAL)
    {
        return TRUE;
    }
    
    if(dflags&CACHE_FLAG_ORIGINAL)
    {
        return FALSE;
    }
    
    if(IS_ORIGINAL_SIZE(src))
    {
        return TRUE;
    }
    
    if(IS_ORIGINAL_SIZE(dst))
    {
        return FALSE;
    }
    
    if(src.width == 0.0f || src.height == 0.0f)
    {
        return FALSE;
    }
    
    float tolerence = 0.0f;
    if(dst.width >= 128.0f && dst.height >= 128.0f)
    {
        tolerence = 10.0f;
    }
    
    return MIN(src.width, src.height) - MIN(dst.width, dst.height) >= -tolerence;
}

- (BOOL) does:(CGSize)src sflags:(uint32_t)sflags betterThan:(CGSize)dst dflags:(uint32_t)dflags
{
    if(dflags&CACHE_FLAG_ORIGINAL)
    {
        return FALSE;
    }
    
    if(sflags&CACHE_FLAG_ORIGINAL)
    {
        return TRUE;
    }

    BOOL srcOriginal = IS_ORIGINAL_SIZE(src);
    BOOL dstOriginal = IS_ORIGINAL_SIZE(dst);
    
    if(dstOriginal)
    {
        return FALSE;
    }
    
    if(srcOriginal)
    {
        return TRUE;
    }
    
    return MIN(src.width, src.height) > MIN(dst.width, dst.height);
}

- (void) retrieveImage:(NSString *)key delegatorID:(NSString *)delegatorID width:(float)w height:(float)h
{
    [self retrieveImage:key delegatorID:delegatorID preferedSize:CGSizeMake(w, h)];
}

- (void) retrieveImage:(NSString*)key delegatorID:(NSString*)delegatorID preferedSize:(CGSize) psize
{
    key = key.lowercaseString;
    
    if(psize.width > 1024 || psize.height > 2048)
    {
        psize = ORIGINAL_SIZE;
    }
    
    uint32_t pflags = 0;
    if(IS_ORIGINAL_SIZE(psize))
    {
        pflags |= CACHE_FLAG_ORIGINAL;
    }
    
    // Check requesting item
    {
        RequestingImageItem* requesting = [self lastRequestingItem:key];
        do
        {
            if(!requesting)
            {
                break;
            }
            
            // Check if the cached match our requires
            if([self does:requesting.csize sflags:requesting.cflags match:psize dflags:pflags])
            {
                break;
            }
            
            // Check if the cached image's hint size match our requires
            if(requesting.hsize.width >= psize.width && requesting.hsize.height >= psize.height)
            {
                break;
            }
            
            // Check if the request match our requires
            if([self does:requesting.psize sflags:requesting.pflags match:psize dflags:pflags])
            {
                [requesting addDelegatorID:delegatorID];
                
                NSLog(@"\nImage %@ \nDelegator %@\nRequesting %d,%d,%x matchers %d,%d,%x \n",
                     key,
                     delegatorID,
                     (int)requesting.psize.width, (int)requesting.psize.height, requesting.pflags, (int)psize.width, (int)psize.height, pflags
                     );
                
                return ;
            }
            
            // requesting doesn't match our requires, so just request a better image from server
            [self requestFromServer:key delegatorID:delegatorID psize:psize pflags:pflags csize:requesting.csize cflags:requesting.cflags hsize:requesting.hsize];
            
            return ;
        }while(FALSE);
    }
    
    // Check on local memory cache
    uint32_t cflags = 0;
    CGSize   csize = {0, 0};
    CGSize   hsize = {0, 0};
    
    DotCImageCacheItem* dataFromCache = nil;
    NSData*         dataFromBase  = nil;
    NSData*         otherData     = nil;
    
    // Check cache
    {
        dataFromCache = [_localCache cacheItem:key];
        if(dataFromCache)
        {
            cflags = dataFromCache.flags;
            csize = dataFromCache.imageSize;
            hsize = dataFromCache.hintSize;
        }
    }

    // Check data base
    if(!dataFromCache && _database)
    {
        dataFromBase = [_database imageData:key other:&otherData];
        if(dataFromBase && otherData)
        {
            SImageCacheOther_1_0* other = (SImageCacheOther_1_0*)otherData.bytes;
            csize.width  = other->width;
            csize.height = other->height;
            hsize.width  = other->hwidth;
            hsize.height = other->hheight;
                    
            cflags = other->flags;
        }
    }
    
    if(!dataFromCache && !dataFromBase) // Has nothing to get, now request from server
    {
        [self requestFromServer:key delegatorID:delegatorID psize:psize pflags:pflags csize:csize cflags:cflags hsize:hsize];
        return ;
    }
    
    // Check whether the local image is good enough, if not, then request from server and replace the local copy
    {
        if([self does:csize sflags:cflags match:psize dflags:pflags] || (hsize.width>=psize.width && hsize.height>=psize.height))
        {
            UIImage* image = nil;
            if(dataFromBase)    // Need to do local cache
            {
                image = [UIImage imageWithData:dataFromBase];
                SImageCacheOther_1_0* other = (SImageCacheOther_1_0*)otherData.bytes;

                DotCImageCacheItem* item = [DotCImageCacheItem itemFrom:key image:image flags:cflags crc:other->crc];
                [item setHintSize:hsize];
                
                [_localCache addCacheItem:item];
            }
            else                // Update local cache
            {
                image = dataFromCache.image;
                [dataFromCache.node unLink];
                [dataFromCache updateTime];
                [dataFromCache.node linkAfter:_localCache.cacheItemList];
            }
            
            NSLog(@"\nImage %@ \nDelegator:%@\nCache %d,%d,%x matches %d,%d,%x \nUse:%@",
                 key,
                 delegatorID,
                 (int)csize.width, (int)csize.height, cflags, (int)psize.width, (int)psize.height, pflags,
                 (dataFromBase ? @"database" : @"localcache")
                 );
            
            [self onImagePrepared:key image:image delegatorID:delegatorID error:nil];
        }
        else // Request from server
        {
            [self requestFromServer:key delegatorID:delegatorID psize:psize pflags:pflags csize:csize cflags:cflags hsize:hsize];
        }
    }
}

- (void) requestFromServer:(NSString*)key delegatorID:(NSString*)delegatorID psize:(CGSize)psize pflags:(uint32_t)pflags csize:(CGSize)csize cflags:(uint32_t)cflags hsize:(CGSize)hsize
{
    // assert there is no match request in requesting items
    RequestingImageItem* item = WEAK_OBJECT(RequestingImageItem, initWith:key);
    [item setPsize:psize flags:pflags];
    [item setCsize:csize flags:cflags];
    [item setHsize:hsize];
    [item addDelegatorID:delegatorID];
    
    NSMutableArray* items = [_requestingImages objectForKey:key];
    if(!items)
    {
        items = WEAK_OBJECT(NSMutableArray, init);
        [_requestingImages setObject:items forKey:key];
    }
    
    [items addObject:item];
    [item retain];
    
    if(psize.width>0.0f&&psize.height>0.0f && !IS_ORIGINAL_SIZE(psize))
    {
        [[DotCImageManager integrateAdapter] request:key width:psize.width height:psize.height info:(void*)item];
    }
    else
    {
        [[DotCImageManager integrateAdapter] request:key width:-1 height:-1 info:(void*)item];
        
    }
    
    NSLog(@"\nImage %@\nRequest from server", key);
}
    
- (void) onReceivedImageData:(NSData*)imageData info:(void*)info
{
    RequestingImageItem* item = (RequestingImageItem*)info;
    [item autorelease];
    
    NSMutableArray* items = [_requestingImages objectForKey:item.key];
    if(!items || ![items containsObject:item])  // Has handled ?
    {
        return ;
    }
    
    [items removeObject:item];
    if(items.count == 0)
    {
        items = nil;
        [_requestingImages removeObjectForKey:item.key];
    }
    
    UIImage* image = imageData ? [UIImage imageWithData:imageData] : nil;
    if(!imageData || !image)
    {
        [self onImagePrepared:item.key image:nil delegatorIDs:item.delegatorIDs error:[NSError errorWithDomain:@"ImageManagerError" code:0 userInfo:nil]];
        
        return ;
    }
    
    CGSize      csize  = image.size;
    uint32_t    cflags = 0;
    CGSize      psize  = item.psize;
    uint32_t    pflags = item.pflags;
    CGSize      hsize  = psize;
    
    BOOL isOriginal =       (pflags&CACHE_FLAG_ORIGINAL) || IS_ORIGINAL_SIZE(psize)  // Request original image
                        ||  (csize.width<psize.width && csize.height<psize.height);       // Get a image who is small than request image
    cflags |= isOriginal ? CACHE_FLAG_ORIGINAL : 0;
    
    {
        uint32_t crc = [DotCUtil crc32:imageData];
        
        BOOL isBetter = FALSE;
        
        // Update local cache
        DotCImageCacheItem* cacheItem = [_localCache cacheItem:item.key];
        if(cacheItem)
        {
            if([self does:csize sflags:cflags betterThan:cacheItem.imageSize dflags:cacheItem.flags])
            {
                isBetter = TRUE;
                if(cacheItem.hintSize.width > hsize.width && cacheItem.hintSize.height > hsize.height)
                {
                    hsize = cacheItem.hintSize;
                }
                
                [_localCache removeCacheItem:cacheItem];
                cacheItem = nil;
            }
        }
        else
        {
            isBetter = TRUE;
        }
        
        if(isBetter)
        {
            // Update local cache
            DotCImageCacheItem* newItem = [DotCImageCacheItem itemFrom:item.key image:image flags:cflags crc:crc];
            [newItem setHintSize:hsize];
            
            [_localCache addCacheItem:newItem];
            
            // Update disk
            SImageCacheOther_1_0* other = malloc(sizeof(SImageCacheOther_1_0));
            other->version = OTHER_VERSION_1_0;
            other->flags   = cflags;
            other->width   = (int)csize.width;
            other->height  = (int)csize.height;
            other->hwidth  = (int)hsize.width;
            other->hheight = (int)hsize.height;
            other->crc     = crc;
            
            if([_database save:item.key imageData:imageData other:[NSData dataWithBytesNoCopy:other length:sizeof(SImageCacheOther_1_0)]] != 0)
            {
                NSLog(@"Save Image %@ Fail", item.key);
            }
            
            // Update old information
            if(items)
            {
                for(RequestingImageItem* requestingItem in items)
                {
                    [requestingItem setCsize:csize flags:cflags];
                    [requestingItem setHsize:hsize];
                }
            }
        }
    }
    
    // Dispatch for self
    [self onImagePrepared:item.key image:image delegatorIDs:item.delegatorIDs error:nil];
    
    // Dispatcher for others
    if(items)
    {
        NSMutableArray* existItems = WEAK_OBJECT(NSMutableArray, init);
        for(RequestingImageItem* requestingItem in items)
        {
            if(     [self does:csize sflags:cflags match:requestingItem.psize dflags:requestingItem.pflags]
               ||   (hsize.width>=requestingItem.psize.width && hsize.height>=requestingItem.psize.height)
              )
            {
                [self onImagePrepared:item.key image:image delegatorIDs:requestingItem.delegatorIDs error:nil];
            }
            else
            {
                [existItems addObject:requestingItem];
            }
        }
        
        [items removeAllObjects];
        [items addObjectsFromArray:existItems];
    
        if(items.count == 0)
        {
            items = nil;
            [_requestingImages removeObjectForKey:item.key];
        }
    }
}

- (void) clearLocalCache
{
    [_localCache clear];
}

- (void) clearCache:(float)daysAgo
{
    [self clearLocalCache];
    
    [_database clear:daysAgo];
}

- (int)  getCacheSize
{
    return [_database getDatabaseSize];
}

- (int) getLocalCacheSize
{
    return [_localCache cacheLength];
}

+ (instancetype) instance
{
    static DotCImageManager* s_instance = nil;
    if(!s_instance)
    {
        s_instance = STRONG_OBJECT(DotCImageManager, init);
    }
    
    return s_instance;
}

static DotCIntegrateAdapter* s_adapter;

+ (void) setIntegrateAdapter:(DotCIntegrateAdapter *)adapter
{
    if(s_adapter)
    {
        [s_adapter release];
    }
    
    s_adapter = adapter;
    [s_adapter retain];
}

+ (DotCIntegrateAdapter*)integrateAdapter
{
    return s_adapter;
}

@end


