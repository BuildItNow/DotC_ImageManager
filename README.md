# DotC_ImageManager
DotCImageManager是一个高性能的图片缓存库，采用游戏开发中的资源管理策略：一份资源只存在一份内存实例，在适当的时候进行自动资源回收；提供参考尺寸匹配机制，有效减少服务器请求；使用SQLite存储图片，方便图片持久化管理；提供DotCImageView，方便集成和使用。

# 集成
* 从DotCIntegrateAdapter继承，添加YourIntegrateAdapterClass类
* 重写下面接口: <br/>
``` objectc 
- (void) request:(NSString*)image width:(int)w height:(int)h info:(void*)info 
```
   请求图片数据，image为图片ID，w和h为参考尺寸。当请求完图片或者失败后，需要调用onRequest:(NSData*)imageData info:(void*)info，其中info为请求时提供的info参数。<br/>
``` objectc
- (UIImage*) getPlaceHolder:(NSString*)name 
```
   获取占位图片，使用DotCImageView时使用。<br/>
``` objectc 
- (NSString*) getDatabasePath
```
   获取数据库路径，该接口为可选。<br/>   
``` objectc
- (int) getMaxMemoryCacheSize
```
   获取内存缓存的最大限制，该接口为可选。默认为10M。<br/>
* 初始化<br/>
   在工程的初始化代码地方添加：
``` objectc
   ...
   // Setup integrate adapter
   [DotCImageManager setIntegrateAdapter:[[[YourIntegrateAdapterClass alloc] init] auturelease]];
   // Initialize DotCImageManager, DotCImageManager is singleton instance
   DOTC_IMAGE_MANAGER;
   ...
```
* 使用DotCImageView加载图片，或者直接通过DOTC_IMAGE_MANAGER获取图片

# 文档
DotC_ImageManager中主要包含DotCImanageManager,DotCImageView,DotCIntegrateAdapter,DotCDelegatorManager,DotCDelegator;Delegator部分也是一个可独立使用的库，主要解决应用开发人员对IOS Observer模式结合内存管理时容易出现内存泄露问题。

## DotCImanageManager 
图片缓存核心类，提供对外的请求接口和对缓存的操作接口。通过DOTC_IMAGE_MANAGER获取本类的Singleton实例。<br/>
``` objectc
- (void) retrieveImage:(NSString*)key delegatorID:(NSString*)delegatorID;
```
   根据key获取原始图片，delegatorID为回调ID，当图片获取成功或者失败时Delegator被调用。
``` objectc
- (void) retrieveImage:(NSString*)key delegatorID:(NSString*)delegatorID width:(float)w height:(float)h;
```
   根据key和参考尺寸w*h获取图片，delegatorID为回调ID，当图片获取成功或者失败时Delegator被调用。
``` objectc
- (void) clearLocalCache;
```
   清除内存缓存。注意：只清理内存中的缓存。
``` objectc
- (void) clearCache:(float)daysAgo;
```
   清除指定时间前的图片，daysAgo单位为天，如果为0则清除所有图片。<br/>
   注意：<br/>
        1.当一个图片被使用时，会更新这个图片的最新时间，保证在清除缓存时总是清除的最不常用的图片。<br/>
        2.该接口只清除数据库中的缓存。<br/>
``` objectc
- (int)  getCacheSize;
```
   获取当前数据库中的缓存大小，以byte为单位。
``` objectc
- (int)  getLocalCacheSize;
```
   获取当前内存中的缓存大小，以byte为单位。
``` objectc
+ (void) setIntegrateAdapter:(DotCIntegrateAdapter*)adapter;
```
   设置集成适配器实例。
``` objectc
+ (DotCIntegrateAdapter*)integrateAdapter;
```
   获取集成适配器实例。

## DotCImageView
从UIImageView继承，提供针对DotCImageManager的UI类，方便加载图片，提供PlaceHolder功能。<br/>

``` objectc
-(void)load:(NSString *)image;
```
   以imageView自身尺寸*screenScale作为参考尺寸，加载image图片。在加载图片时使用默认的placeHolder。
``` objectc
-(void)load:(NSString *)image placeHolder:(NSString *)placeHolder;
```
   以imageView自身尺寸*screenScale作为参考尺寸，加载image图片。在加载图片时使用指定的placeHolder。
``` objectc
-(void)load:(NSString *)image width:(float) w height:(float)h;
```
   以w*h为参考尺寸加载image图片。使用默认的placeHolder。
``` objectc
-(void)load:(NSString *)image width:(float) w height:(float)h placeHolder:(NSString *)placeHolder;
```
   以w*h为参考尺寸加载image图片。使用指定的placeHolder。
``` objectc
-(void)loadOriginal:(NSString *)image;
```
   加载原始图片。使用默认的placeHolder。
``` objectc
-(void)loadOriginal:(NSString *)image placeHolder:(NSString *)placeHolder;
```
   加载原始图片。使用指定的placeHolder。
