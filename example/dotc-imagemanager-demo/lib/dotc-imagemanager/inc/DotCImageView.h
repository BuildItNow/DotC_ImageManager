//
//  DotCImageView.h
//  dotc-imagemanager
//
//  Created by Yang G on 15-10-10.
//  Copyright (c) 2015年 .C . All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "DotCDelegatorManager.h"

DOTC_DECL_DELEGATOR_FEATURE_CLASS(__DotCImageView, UIImageView)

@interface DotCImageView : __DotCImageView

-(void)load:(NSString *)image;
-(void)load:(NSString *)image placeHolder:(NSString *)placeHolder;

-(void)load:(NSString *)image width:(float) w height:(float)h;
-(void)load:(NSString *)image width:(float) w height:(float)h placeHolder:(NSString *)placeHolder;


-(void)loadOriginal:(NSString *)image;
-(void)loadOriginal:(NSString *)image placeHolder:(NSString *)placeHolder;

@end
