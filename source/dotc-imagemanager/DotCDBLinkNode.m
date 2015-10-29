//
//  DBLinkNode.m
//  dotc-imagemanager
//
//  Created by Yang G on 15-10-10.
//  Copyright (c) 2015年 .C . All rights reserved.
//

#import "Defines.h"
#import "DotCDBLinkNode.h"

@interface DotCDBLinkNode()
{
    id              _value;
    
    DotCDBLinkNode*     _prev;
    DotCDBLinkNode*     _next;
}

@end

@implementation DotCDBLinkNode

- (id) value
{
    return _value;
}

- (void) setValue:(id)value
{
    _value = value;
}

- (DotCDBLinkNode*) prev
{
    return _prev;
}

- (DotCDBLinkNode*) next
{
    return _next;
}

- (void) linkBefore:(DotCDBLinkNode*)listNode   
{
    _next = listNode;
    _prev = listNode->_prev;
    
    if(_prev)
    {
        _prev->_next = self;
    }
    
    _next->_prev = self;
}

- (void) linkAfter:(DotCDBLinkNode*)listNode
{
    _prev = listNode;
    _next = listNode->_next;
    
    _prev->_next = self;
    if(_next)
    {
        _next->_prev = self;
    }
}

- (void) unLink
{
    if(_prev)
    {
        _prev->_next = _next;
    }
    
    if(_next)
    {
        _next->_prev = _prev;
    }
    
    _prev = nil;
    _next = nil;
}

+ (instancetype) nodeFrom:(id)value
{
    DotCDBLinkNode* ret = WEAK_OBJECT(self, init);
    
    ret.value = value;
    
    return ret;
}

@end
