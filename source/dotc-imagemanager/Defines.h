//
//  Defines.h
//  dotc-imagemanager
//
//  Created by Yang G on 15-10-10.
//  Copyright (c) 2015年 .C . All rights reserved.
//

// Create a weak object, that means you don't own the object resource, no need to release or autorelease.
#define WEAK_OBJECT(class, initor)\
[[[class alloc] initor] autorelease]

// Create a strong object, that means you own the object resource, need release or autorelease.
#define STRONG_OBJECT(class, initor)\
[[class alloc] initor]

// Count the static c array
#define COUNT_OF(array) (sizeof(array)/sizeof(array[0]))

// Log tag
#define LIB_TAG @"DOTC_IMAGEMANAGER"

#define BIT(n) (1<<(n))
