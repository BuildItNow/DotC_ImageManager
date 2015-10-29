//
//  DelegatorManager.h
//  dotc-imagemanager
//
//  Created by Yang G on 15-10-10.
//  Copyright (c) 2015年 .C . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DotCDelegator.h"

@interface DotCDelegatorManager : NSObject

// The selector must be
// 1: id methodName:(DelegatorArguments*)arguments;
// 2: void methodName:(DelegatorArguments*)arguments;
- (DotCDelegatorID) addDelegator:(id) subject selector:(SEL) selector;
- (DotCDelegatorID) addDelegator:(id) subject selector:(SEL) selector weakUserData:(id)userData;
- (DotCDelegatorID) addDelegator:(id) subject selector:(SEL) selector strongUserData:(id)userData;
- (void) removeDelegators:(id) subject;
- (void) removeDelegator:(DotCDelegatorID) delegatorID;
- (id) performDelegator:(DotCDelegatorID) delegatorID arguments:(DotCDelegatorArguments*) arguments;

+ (instancetype) globalDelegatorManager;
@end

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