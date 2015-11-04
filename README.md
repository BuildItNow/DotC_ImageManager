# DotC_ImageManager
DotCImageManager是一个高性能的图片缓存库<br/>
1. 采用游戏开发中的资源管理策略：一份资源只存在一份内存实例，在适当的时候进行自动资源回收 <br/>
2. 支持内存缓存，提供最大内存限制，自动内存回收机制 <br/>
3. 支持磁盘缓存，使用SQLite提供磁盘持久化 <br/>
4. 参考尺寸匹配机制，有效减少服务器请求 <br/>
5. 提供DotCImageView，方便集成和使用 <br/>

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
DotC_ImageManager中主要包含DotCImanageManager,DotCImageView,DotCIntegrateAdapter;DotCDelegatorManager,DotCDelegator,DotCDelegatorArguments;Delegator部分也是一个可独立使用的库，提供DotCImageManager获取图片的异步回调策略。

## DotCImanageManager 
图片缓存核心类，提供对外的请求接口和对缓存的操作接口。通过DOTC_IMAGE_MANAGER获取本类的Singleton实例。<br/>
<br/>
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
<br/>
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
   
# DotCIntegrateAdapter
集成适配器，DotCImageManager需要主体项目提供一些必要功能才能正常工作<br/>
<br/>

``` objectc
- (void) request:(NSString*)image width:(int)w height:(int)h info:(void*)info;
```
   DotCImageManager需要请求图片时会调用该接口。<br/>
   image : 图片ID<br/>
   w     : 参考尺寸宽度<br/>
   h     : 参考尺寸高度<br/>
   info  : 请求额外信息，在调用onRequest:info中需要
``` objectc
- (UIImage*)  getPlaceHolder:(NSString*)name;
```
   DotCImageView在使用placeHolder时会调用该接口获取图片。<br/>
``` objectc
- (NSString*) getDatabasePath;
```
   DotCImageManager使用的数据库路径。<br/>

``` objectc
- (int) getMaxMemoryCacheSize;
```
   DotCImageManager使用的最大内存缓存大小。<br/>
``` objectc
- (void) onRequest:(NSData*)imageData info:(void*)info;
```
   当request:width:height:info请求图片成功后者失败后，必须通过调用该接口回调通知DotCImageManager。<br/>
   
# DotCDelegatorManager
从DotCImageManager获取图片是异步方式，因此需要一个回调Delegator机制。<br/>
<br/>
``` objectc
- (DotCDelegatorID) addDelegator:(id) subject selector:(SEL) selector;
```
   注册Delegator，返回唯一的DelegatorID。<br/>
   注意：selector只能有DotCDelegatorArguments类型的唯一参数；可以有返回值<br/>
``` objectc
- (DotCDelegatorID) addDelegator:(id) subject selector:(SEL) selector weakUserData:(id)userData;
```
   注册Delegator，返回唯一的DelegatorID。Delegator将携带userData，在arguments里通过DELEGATOR_ARGUMENT_USERDATA获取userData。<br/>
   注意：Delegator对userData是弱引用。也就是Delegator不会对userData进行retain。<br/>
``` objectc
- (DotCDelegatorID) addDelegator:(id) subject selector:(SEL) selector strongUserData:(id)userData;
```
   注册Delegator，返回唯一的DelegatorID。Delegator将携带userData。<br/>
   注意：Delegator对userData是强引用。也就是Delegator会对userData进行retain，在Delegator释放时候对userData进行release。<br/>
``` objectc
- (void) removeDelegators:(id) subject;
```
   移除subject上包含的所有delegator。
``` objectc
- (void) removeDelegator:(DotCDelegatorID) delegatorID;
```
   移除delegatorID对应的delegator。
``` objectc
- (id) performDelegator:(DotCDelegatorID) delegatorID arguments:(DotCDelegatorArguments*) arguments;
```
   以arguments为参数调用delegatorID对应的delegator，返回该delegator执行的结果。
``` objectc
+ (instancetype) globalDelegatorManager;
```
   获取全局的DelegatorManager，全局DelegatorManager作为Singleton存在，可通过DOTC_GLOBAL_DELEGATOR_MANAGER宏获取。<br/>
   
   针对DelegatorManager会保存subject对象指针，当subject释放后，必须清理DelegatorManager里面所有对应的Delegators，否则将可能因为野指针而Crash。为此，提供了几个宏来自动进行这个过程。
``` objectc
#define DOTC_GLOBAL_DELEGATOR_MANAGER [DotCDelegatorManager globalDelegatorManager]

// Support auto remove delegators for class want to use global delegator manager
#define DOTC_DECL_DELEGATOR_FEATURE_CLASS(clsName, superClsName)\
@interface clsName : superClsName\
- (DotCDelegatorID) genDelegatorID:(SEL)selector;\
- (DotCDelegatorID) genDelegatorID:(SEL)selector weakData:(id)data;\
- (DotCDelegatorID) genDelegatorID:(SEL)selector strongData:(id)data;\
@end

#define DOTC_IMPL_DELEGATOR_FEATURE_CLASS(clsName, superClsName)\
@implementation clsName\
- (void) dealloc\
{\
[DOTC_GLOBAL_DELEGATOR_MANAGER removeDelegators:self];\
[super dealloc];\
}\
\
- (DotCDelegatorID) genDelegatorID:(SEL)selector\
{\
return [DOTC_GLOBAL_DELEGATOR_MANAGER addDelegator:self selector:selector];\
}\
\
- (DotCDelegatorID) genDelegatorID:(SEL)selector weakData:(id)data\
{\
return [DOTC_GLOBAL_DELEGATOR_MANAGER addDelegator:self selector:selector weakUserData:data];\
}\
\
- (DotCDelegatorID) genDelegatorID:(SEL)selector strongData:(id)data\
{\
return [DOTC_GLOBAL_DELEGATOR_MANAGER addDelegator:self selector:selector strongUserData:data];\
}\
@end
```
   针对subject类做类似编码，这样保证在subject的dealloc里面remove所有相关的delegators:
``` objectc
// .h
DOTC_DECL_DELEGATOR_FEATURE_CLASS(__DotCImageView, UIImageView)
@interface DotCImageView : __DotCImageView
...

// .m
DOTC_IMPL_DELEGATOR_FEATURE_CLASS(__DotCImageView, UIImageView)
...
```

# DotCDelegatorArguments
Delegator回调参数。<br/>
<br/>
``` objectc
- (void) setArgument:(id) argument for:(NSString*) name;
```
   添加name对应的参数argument。
``` objectc
- (void) cleanArgument:(NSString*) name;
```
   清除name对应的参数。
``` objectc
- (id)   getArgument:(NSString*) name;
```   
   获取name对应的参数。
   
# 示例
## DotCImageManager
### 使用DotCImageView
1. xib里，对应的UIImageView修改为DotCImageView。<br/>
2. 对DotCImageView实例调用load方法。

### 使用DOTC_IMAGE_MANAGER
``` objectc
...
// Retrieve image from manager
[DOTC_IMAGE_MANAGER retrieveImage:image delegatorID:[self genDelegatorID:@selector(onReceivedImageData:)]];
...

// The defination of delegator
- (void) onReceivedImageData:(DotCDelegatorArguments*)arguments
{
    // Get the image name
    NSString* key  = [arguments getArgument:IMAGE_ARGUMENT_KEY];
    // Get the image
    Image* image = [arguments getArgument:IMAGE_ARGUMENT_IMAGE];
    // Get the error
    id     error = [arguments getArgument:IMAGE_ARGUMENT_ERROR];
    ...
}
```

## DotCDelegatorManager
### 直接使用DOTC_GLOBAL_DELEGATOR_MANAGER
注册
``` objectc
[DOTC_GLOBAL_DELEGATOR_MANAGER addDelegator:self selector:selector];
```
回调
``` objectc
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

```
### 使用DOTC_DECL_DELEGATOR_FEATURE_CLASS，DOTC_IMPL_DELEGATOR_FEATURE_CLASS
定义具有Delegator Feature的类
``` objectc
// .h
DOTC_DECL_DELEGATOR_FEATURE_CLASS(__DotCImageView, UIImageView)
@interface DotCImageView : __DotCImageView
...

// .m
DOTC_IMPL_DELEGATOR_FEATURE_CLASS(__DotCImageView, UIImageView)
...
```
注册
``` objectc
[self genDelegatorID:@selector(onReceivedImageData:)
```
回调<br/>
与直接使用类似
