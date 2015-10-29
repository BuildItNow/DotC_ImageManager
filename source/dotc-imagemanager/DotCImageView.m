//
//  DotCImageView.m
//  dotc-imagemanager
//
//  Created by Yang G on 15-10-10.
//  Copyright (c) 2015年 .C . All rights reserved.
//

#import "Defines.h"

#import "DotCImageView.h"
#import "DotCImageManager.h"
#import "DotCDelegatorManager.h"
#import "DotCIntegrateAdapter.h"

enum
{
    ID_PLACE_HOLDER_VIEW = -50000,
    ID_DATA_WRAPER_VIEW
};

DOTC_IMPL_DELEGATOR_FEATURE_CLASS(__DotCImageView, UIImageView)

@interface DotCImageView()
{
    NSString*       _placeHolderName;
    NSString*       _imageName;
    CGSize          _imageSize;
}

@end

@implementation DotCImageView

- (instancetype) initWithFrame:(CGRect)frame
{
    if(!(self = [super initWithFrame:frame]))
    {
        return nil;
    }
    
    [self addPlaceHolder:nil];
    
    return self;
}

- (instancetype) initWithCoder:(NSCoder *)aDecoder
{
    if(!(self = [super initWithCoder:aDecoder]))
    {
        return nil;
    }
    
    [self addPlaceHolder:nil];
    
    return self;
}

- (void) dealloc
{
    [_placeHolderName release];
    _placeHolderName = nil;
    
    [_imageName release];
    _imageName = nil;
    
    [super dealloc];
}

- (void) setPlaceHolderName:(NSString*)placeHolder
{
    [_placeHolderName release];
    _placeHolderName = [placeHolder copy];
}

- (NSString*)placeHolderName
{
    return _placeHolderName;
}

- (void) setImageName:(NSString*)image
{
    [_imageName release];
    _imageName = [image copy];
}

- (void) onReceivedImageData:(DotCDelegatorArguments*)arguments
{
    NSString* key  = [arguments getArgument:IMAGE_ARGUMENT_KEY];
    
    if(![key isEqualToString:_imageName])
    {
        return ;
    }
    
    UIImage* image = [arguments getArgument:IMAGE_ARGUMENT_IMAGE];
    
    if([arguments getArgument:IMAGE_ARGUMENT_ERROR])
    {
        
    }
    else if(image)
    {
        [self removePlaceHolder];
        
        self.image = image;
    }

}

- (void) removePlaceHolder
{
    UIImageView* phView = (UIImageView*)[self viewWithTag:ID_PLACE_HOLDER_VIEW];
    phView.hidden = TRUE;
}

- (CGSize) getPlaceHolderSize
{
    if(_placeHolderName)
    {
        NSArray* components = [_placeHolderName componentsSeparatedByString:@"_"];
        if(components.count >= 2)
        {
            NSString* ssize = components[1];
            if(ssize.length == 1 && [ssize characterAtIndex:0] == '*')
            {
                return self.frame.size;
            }
            else
            {
                NSArray* wXh = [ssize componentsSeparatedByString:@"x"];
                NSString* sw = wXh[0];
                NSString* sh = wXh[1];
                
                CGSize size = self.frame.size;
                if([sw characterAtIndex:0] != '*')
                {
                    size.width = sw.floatValue;
                }
                
                if([sh characterAtIndex:0] != '*')
                {
                    size.height = sh.floatValue;
                }
                
                return size;
            }
        }
    }
    
    CGSize size = self.frame.size;
    int w = MIN(size.width, size.height);
    w = MIN(256, w);
    
    return CGSizeMake(w, w);
}

- (void) addPlaceHolder:(NSString*) placeHolder
{
    if(!placeHolder || placeHolder.length == 0)
    {
        placeHolder = nil;
    }
    
    self.placeHolderName = placeHolder;
    
    self.image = nil;                              // Clean old data
    self.backgroundColor = [UIColor colorWithRed:246.0f/255.0f green:246.0f/255.0f blue:246.0f/255.0f alpha:255.0f/255.0f];   // Setup back color
    
    UIImageView* phView = (UIImageView*)[self viewWithTag:ID_PLACE_HOLDER_VIEW];
    if(!phView)
    {
        CGSize size = self.frame.size;
        CGSize phSize = [self getPlaceHolderSize];
        phView = WEAK_OBJECT(UIImageView, initWithFrame:CGRectMake(0, 0, phSize.width, phSize.height));
        phView.userInteractionEnabled = FALSE;
        phView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
        phView.tag    = ID_PLACE_HOLDER_VIEW;
        phView.center = CGPointMake(size.width*0.5f, size.height*0.5f);
        [self addSubview:phView];
    }
    
    phView.hidden = FALSE;
    phView.image  = [[DotCImageManager integrateAdapter] getPlaceHolder:placeHolder];
}

- (void) retreive:(NSString*)image placeHolder:(NSString*)placeHolder
{
    if([image isEqualToString:_imageName] && _imageSize.height <= 0)
    {
        return ;
    }
    
    self.imageName = image;
    _imageSize.width = _imageSize.height = -1.0f;
    
    [self addPlaceHolder:placeHolder];
    
    if(image.length < 1)
    {
        return ;
    }
    
    [DOTC_IMAGE_MANAGER retrieveImage:image delegatorID:[self genDelegatorID:@selector(onReceivedImageData:)]];
}

- (void) retrieve:(NSString*)image placeHolder:(NSString*)placeHolder width:(float)w height:(float)h
{
    if([image isEqualToString:_imageName] && h <= _imageSize.height && w <= _imageSize.width)
    {
        return ;
    }
    
    self.imageName = image;
    _imageSize.width = w;
    _imageSize.height = h;
    
    [self addPlaceHolder:placeHolder];
    
    if(image.length < 1)
    {
        return ;
    }
    
    [DOTC_IMAGE_MANAGER retrieveImage:image delegatorID:[self genDelegatorID:@selector(onReceivedImageData:)] width:w height:h];
}

-(void)loadOriginal:(NSString*)image
{
    [self retreive:image placeHolder:nil];
}

-(void)loadOriginal:(NSString*)image placeHolder:(NSString*)placeHolder
{
    [self retreive:image placeHolder:placeHolder];
}

-(void)load:(NSString*)image
{
    [self load:image placeHolder:nil];
}

-(void)load:(NSString*)image placeHolder:(NSString*)placeHolder
{
    float w = self.frame.size.width*[UIScreen mainScreen].scale;
    float h = self.frame.size.height*[UIScreen mainScreen].scale;
    
    [self retrieve:image placeHolder:placeHolder width:w height:h];
}

-(void)load:(NSString *)image width:(float) w height:(float)h;
{
    [self load:image width:w height:h placeHolder:nil];
}

-(void)load:(NSString *)image width:(float) w height:(float)h placeHolder:(NSString *)placeHolder
{
    [self retrieve:image placeHolder:placeHolder width:w height:h];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    UIView* phView = [self viewWithTag:ID_PLACE_HOLDER_VIEW];
    if(phView)
    {
        CGSize size = self.frame.size;
        CGSize phSize = [self getPlaceHolderSize];
        phView.frame = CGRectMake(0, 0, phSize.width, phSize.height);
        phView.center = CGPointMake(size.width*0.5f, size.height*0.5f);
    }
}

@end