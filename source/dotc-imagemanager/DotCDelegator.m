//
//  Delegator.m
//  dotc-imagemanager
//
//  Created by Yang G on 15-10-10.
//  Copyright (c) 2015年 .C . All rights reserved.
//

#import "Defines.h"
#import "DotCDelegator.h"


DotCDelegatorID INVALID_DELEGATOR = @"invalid";
NSString*   DELEGATOR_ARGUMENT_USERDATA = @"delegatorArgumentUserData";

static NSString* objectToString(id subject)
{
    if(!subject)
    {
        return @"null";
    }
    
    return [NSString stringWithFormat:@"%p#%s", (void*)subject, object_getClassName(subject)];
}

#define delegatorIDToString(delegatorID) delegatorID
//static NSString* delegatorIDToString(DelegatorID delegatorID)
//{
//    return delegatorID;
//}

@interface DotCDelegatorArguments()
{
    NSMutableDictionary*    _arguments;
}

@end

@implementation DotCDelegatorArguments

- (void) dealloc
{
    [_arguments release];
    
    [super dealloc];
}

- (void) setArgument:(id) argument for:(NSString*) name
{
    if(!_arguments)
    {
        _arguments = STRONG_OBJECT(NSMutableDictionary, init);
    }
    
    [_arguments setObject:argument forKey:name];
}

- (id) getArgument:(NSString*) name
{
    return _arguments ? [_arguments objectForKey:name] : nil;
}

- (void) cleanArgument:(NSString*) name
{
    if(_arguments)
    {
        [_arguments removeObjectForKey:name];
    }
}

+(instancetype) argumentsFrom:(NSString*) name arg:(id)arg
{
    DotCDelegatorArguments* ret = WEAK_OBJECT(DotCDelegatorArguments, init);
    
    [ret setArgument:arg for:name];
    
    return ret;
}

+(instancetype) argumentsFrom:(NSString*) name0 arg0:(id)arg0 name1:name1 arg1:arg1
{
    DotCDelegatorArguments* ret = [DotCDelegatorArguments argumentsFrom:name0 arg:arg0];
    
    [ret setArgument:arg1 for:name1];
    
    return ret;
}

+(instancetype) argumentsFrom:(NSString*) name0 arg0:(id)arg0 name1:name1 arg1:arg1 name2:name2 arg2:arg2
{
    DotCDelegatorArguments* ret = [DotCDelegatorArguments argumentsFrom:name0 arg0:arg0 name1:name1 arg1:arg1];
    
    [ret setArgument:arg2 for:name2];
    
    return ret;
}

+(instancetype) argumentsFrom:(NSString*) name0 arg0:(id)arg0 name1:name1 arg1:arg1 name2:name2 arg2:arg2 name3:name3 arg3:arg3;
{
    DotCDelegatorArguments* ret = [DotCDelegatorArguments argumentsFrom:name0 arg0:arg0 name1:name1 arg1:arg1 name2:name2 arg2:arg2];
    
    [ret setArgument:arg3 for:name3];
    
    return ret;
}

@end

@interface DotCDelegator()
{
    DotCDelegatorID _delegatorID;
    id          _subject;
    SEL         _selector;
    id          _userData;
    bool        _userDataIsStrong;
}

@end


@implementation DotCDelegator

- (instancetype) init
{
    self = [super self];
    
    if(!self)
    {
        return self;
    }
    
    _delegatorID = nil;
    
    return self;
}

- (void) dealloc
{
    [_delegatorID release]; // OK when _delegatorID == nl
    if(_userDataIsStrong)
    {
        [_userData release];
    }
    [super dealloc];
}

- (id) subject
{
    return _subject;
}

- (SEL) selector
{
    return _selector;
}

- (void) setSubject:(id) subject selector:(SEL) selector
{
    assert(!_subject);
    assert(!_selector);
    
    _subject  = subject;
    _selector = selector;
    
    _delegatorID = nil;
}

- (void) setSubject:(id) subject selector:(SEL) selector strongUserData:(id)userData
{
    assert(!_subject);
    assert(!_selector);
    
    _subject  = subject;
    _selector = selector;
    
    assert(userData);
    if(_userDataIsStrong)
    {
        [_userData release];
    }
    _userData = userData;
    [_userData retain];
    _userDataIsStrong = TRUE;
    
    _delegatorID = nil;
}

- (void) setSubject:(id) subject selector:(SEL) selector weakUserData:(id)userData
{
    assert(!_subject);
    assert(!_selector);
    
    _subject  = subject;
    _selector = selector;
    
    assert(userData);
    if(_userDataIsStrong)
    {
        [_userData release];
    }
    _userData = userData;
    _userDataIsStrong = FALSE;
    
    _delegatorID = nil;
}

- (id) perform:(DotCDelegatorArguments*) arguments
{
    if(![DotCDelegator checkDelegatorValidity:_subject selector:_selector])
    {
        NSLog(@"[%@] Delegator %@ selector signature is error. See DelegatorManager description.", LIB_TAG, [self delegatorID]);
        
        return nil;
    }
    
    id ret = nil;
    
    NSMethodSignature* signature = [[_subject class] instanceMethodSignatureForSelector:_selector];
    
    NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation setTarget:_subject];
    [invocation setSelector:_selector];
    [invocation setArgument:&arguments atIndex:2];
    
    [invocation retainArguments];
    
    if(_userData)
    {
        [arguments setArgument:_userData for:DELEGATOR_ARGUMENT_USERDATA];
    }
    [invocation invoke];
    if(_userData)
    {
        [arguments cleanArgument:DELEGATOR_ARGUMENT_USERDATA];
    }
    
    if(strcmp(signature.methodReturnType, @encode(id)) == 0)    // Only care id type
    {
        [invocation getReturnValue:&ret];
    }
    
    return ret;
}

+ (DotCDelegatorID) generateDelegatorID:(id) subject selector:(SEL) selector
{
    return [NSString stringWithFormat:@"%@#%@", objectToString(subject), NSStringFromSelector(selector)];
}

+ (DotCDelegatorID) generateDelegatorID:(id) subject selector:(SEL) selector userData:(id)userData
{
    return [NSString stringWithFormat:@"%@#%@#%@", objectToString(subject), NSStringFromSelector(selector), objectToString(userData)];
}

+ (BOOL) checkDelegatorValidity:(id) subject selector:(SEL) selector
{
    return TRUE;
    /*NSMethodSignature* signature = [[subject class] instanceMethodSignatureForSelector:selector];
     
     const char* srcArgType = [signature getArgumentTypeAtIndex:2];
     const char* dstArgType = @encode(DelegatorArguments);
     return strcmp(srcArgType, dstArgType) == 0;  // argument type must be DelegatorArguments*/
}

- (DotCDelegatorID) delegatorID
{
    if (_subject == nil || _selector == nil)
    {
        return INVALID_DELEGATOR;
    }
    
    if (!_delegatorID)
    {
        _delegatorID = _userData ? [DotCDelegator generateDelegatorID:_subject selector:_selector] : [DotCDelegator generateDelegatorID:_subject selector:_selector userData:_userData];
        [_delegatorID retain];
    }
    
    return _delegatorID;
}
@end
