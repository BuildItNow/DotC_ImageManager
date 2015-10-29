//
//  Delegator.h
//  dotc-imagemanager
//
//  Created by Yang G on 15-10-10.
//  Copyright (c) 2015年 .C . All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NSString*   DotCDelegatorID;

extern DotCDelegatorID INVALID_DELEGATOR;
extern NSString*   DELEGATOR_ARGUMENT_USERDATA;

@interface DotCDelegatorArguments : NSObject

- (void) dealloc;

- (void) setArgument:(id) argument for:(NSString*) name;
- (void) cleanArgument:(NSString*) name;
- (id)   getArgument:(NSString*) name;

+(instancetype) argumentsFrom:(NSString*) name arg:(id)arg;
+(instancetype) argumentsFrom:(NSString*) name0 arg0:(id)arg0 name1:name1 arg1:arg1;
+(instancetype) argumentsFrom:(NSString*) name0 arg0:(id)arg0 name1:name1 arg1:arg1 name2:name2 arg2:arg2;
+(instancetype) argumentsFrom:(NSString*) name0 arg0:(id)arg0 name1:name1 arg1:arg1 name2:name2 arg2:arg2 name3:name3 arg3:arg3;

@end

@interface DotCDelegator : NSObject

- (instancetype) init;
- (void) dealloc;
- (id) subject;
- (SEL) selector;
- (void) setSubject:(id) subject selector:(SEL) selector;
- (void) setSubject:(id) subject selector:(SEL) selector weakUserData:(id)userData;
- (void) setSubject:(id) subject selector:(SEL) selector strongUserData:(id)userData;
- (id) perform:(DotCDelegatorArguments*) arguments;
- (DotCDelegatorID) delegatorID;

+ (DotCDelegatorID) generateDelegatorID:(id) subject selector:(SEL) selector;
+ (DotCDelegatorID) generateDelegatorID:(id) subject selector:(SEL) selector userData:(id)userData;
@end


