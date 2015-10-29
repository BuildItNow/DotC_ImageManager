//
//  DelegatorManager.m
//  dotc-imagemanager
//
//  Created by Yang G on 15-10-10.
//  Copyright (c) 2015年 .C . All rights reserved.
//

#import "Defines.h"
#import "DotCDelegatorManager.h"

static NSString* subjectToString(id subject)
{
    return [NSString stringWithFormat:@"%p#%s", (void*)subject, object_getClassName(subject)];
}

@interface DotCDelegatorManager()
{
    NSMutableDictionary*    _subject2Delegators;
    NSMutableDictionary*    _id2Delegators;
}

@end

@implementation DotCDelegatorManager

- (instancetype) init
{
    if(!(self = [super init]))
    {
        return self;
    }
    
    _subject2Delegators = STRONG_OBJECT(NSMutableDictionary, init);
    _id2Delegators      = STRONG_OBJECT(NSMutableDictionary, init);
    
    return self;
    
}

- (void) dealloc
{
    [_subject2Delegators release];
    [_id2Delegators release];
    
    [super dealloc];
}

- (NSMutableDictionary*) subjectDelegators:(id) subject create:(BOOL) create
{
    NSString* key = subjectToString(subject);
    
    NSMutableDictionary* ret = [_subject2Delegators objectForKey:key];
    if(!ret && create)
    {
        ret = WEAK_OBJECT(NSMutableDictionary, init);
        
        [_subject2Delegators setObject:ret forKey:key];
    }
    
    return ret;
}

- (DotCDelegatorID) addDelegator:(id) subject selector:(SEL) selector
{
    DotCDelegatorID delegatorID = [DotCDelegator generateDelegatorID:subject selector:selector];
    
    if([_id2Delegators objectForKey:delegatorID])
    {
        return delegatorID;
    }
    
    DotCDelegator* delegator = WEAK_OBJECT(DotCDelegator, init);
    [delegator setSubject:subject selector:selector];
    
    // add to _subject2Delegators
    NSMutableDictionary* delegators = [self subjectDelegators:subject create:TRUE];
    [delegators setObject:delegator forKey:delegatorID];
    
    // add to _id2Delegators
    [_id2Delegators setObject:delegator forKey:delegatorID];
    
    return delegatorID;
}

- (DotCDelegatorID) addDelegator:(id) subject selector:(SEL) selector weakUserData:(id)userData
{
    DotCDelegatorID delegatorID = [DotCDelegator generateDelegatorID:subject selector:selector userData:userData];
    
    if([_id2Delegators objectForKey:delegatorID])
    {
        return delegatorID;
    }
    
    DotCDelegator* delegator = WEAK_OBJECT(DotCDelegator, init);
    [delegator setSubject:subject selector:selector weakUserData:userData];
    
    // add to _subject2Delegators
    NSMutableDictionary* delegators = [self subjectDelegators:subject create:TRUE];
    [delegators setObject:delegator forKey:delegatorID];
    
    // add to _id2Delegators
    [_id2Delegators setObject:delegator forKey:delegatorID];
    
    return delegatorID;
}

- (DotCDelegatorID) addDelegator:(id) subject selector:(SEL) selector strongUserData:(id)userData
{
    DotCDelegatorID delegatorID = [DotCDelegator generateDelegatorID:subject selector:selector userData:userData];
    
    if([_id2Delegators objectForKey:delegatorID])
    {
        return delegatorID;
    }
    
    DotCDelegator* delegator = WEAK_OBJECT(DotCDelegator, init);
    [delegator setSubject:subject selector:selector strongUserData:userData];
    
    // add to _subject2Delegators
    NSMutableDictionary* delegators = [self subjectDelegators:subject create:TRUE];
    [delegators setObject:delegator forKey:delegatorID];
    
    // add to _id2Delegators
    [_id2Delegators setObject:delegator forKey:delegatorID];
    
    return delegatorID;
}

- (void) removeDelegators:(id) subject
{
    NSMutableDictionary* delegators = [self subjectDelegators:subject create:FALSE];
    
    if(!delegators)
    {
        return ;
    }
    
    [_id2Delegators removeObjectsForKeys:[delegators allKeys]];
   
    [_subject2Delegators removeObjectForKey:subjectToString(subject)];
}

- (void) removeDelegator:(DotCDelegatorID) delegatorID
{
    DotCDelegator* delegator = [_id2Delegators objectForKey:delegatorID];
    if(!delegator)
    {
        return ;
    }
    
    [_id2Delegators removeObjectForKey:delegatorID];
    
    id subject  = delegator.subject;
    NSMutableDictionary* delegators = [self subjectDelegators:subject create:FALSE];
    assert(delegators);
    [delegators removeObjectForKey:delegatorID];
    
    if([delegators count] == 0)
    {
        [_subject2Delegators removeObjectForKey:subjectToString(subject)];
    }
}

- (id) performDelegator:(DotCDelegatorID) delegatorID arguments:(DotCDelegatorArguments*) arguments
{
    DotCDelegator* delegator = [_id2Delegators objectForKey:delegatorID];
    if(!delegator)
    {
        return nil;
    }
    
    return [delegator perform:arguments];
}

+ (instancetype) globalDelegatorManager
{
    static DotCDelegatorManager* s_instance = nil;
    if (s_instance == nil){
        
        s_instance = STRONG_OBJECT(DotCDelegatorManager, init);
    }
    
    return s_instance;
}

@end
