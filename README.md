# DotC_ImageManager
DotCImageManager是一个高性能的图片缓存库，采用游戏开发中的资源管理策略：一份资源只存在一份内存实例，在适当的时候进行自动资源回收；提供参考尺寸匹配机制，有效减少服务器请求；使用SQLite存储图片，方便图片持久化管理；提供DotCImageView，方便集成和使用。

# 集成
* 从DotCIntegrateAdapter继承，添加类
* 重写下面接口：<br/>
** - (void) request:(NSString*)image width:(int)w height:(int)h info:(void*)info <br/>
   请求图片数据，image为图片ID，w和h为参考尺寸。当请求完图片或者失败后，需要调用onRequest:(NSData*)imageData info:(void*)info，其中info为请求时提供的info参数。<br/>
** - (UIImage*) getPlaceHolder:(NSString*)name <br/>
   获取占位图片，使用DotCImageView时使用。<br/>
** - (NSString*) getDatabasePath <br/>
   获取数据库路径，该接口为可选。<br/>   
** - (int) getMaxMemoryCacheSize <br/>
   获取内存缓存的最大限制，该接口为可选。默认为10M。<br/>

# 文档

