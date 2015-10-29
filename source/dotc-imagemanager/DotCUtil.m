//
//  Util.m
//  dotc-imagemanager
//
//  Created by Yang G on 15-10-10.
//  Copyright (c) 2015年 .C . All rights reserved.
//

#import "DotCUtil.h"

#import <CommonCrypto/CommonDigest.h>

static uint32_t s_table[256] = {0};
const uint32_t DEFAULT_SEED       = 0xFFFFFFFFL;
const uint32_t DEFAULT_POLYNOMIAL = 0xEDB88320L;

static void generateCRC32Table(uint32_t *pTable, uint32_t poly)
{
    for (uint32_t i = 0; i <= 255; i++)
    {
        uint32_t crc = i;
        
        for (uint32_t j = 8; j > 0; j--)
        {
            if ((crc & 1) == 1)
                crc = (crc >> 1) ^ poly;
            else
                crc >>= 1;
        }
        pTable[i] = crc;
    }
}

static uint32_t crc32WithSeed(uint8_t* pBytes, uint32_t length, uint32_t seed)
{
    
    static dispatch_once_t  _;
    dispatch_once(&_, ^
                  {
                      generateCRC32Table(s_table, DEFAULT_POLYNOMIAL);
                  });
    
    uint32_t crc = seed;
    while (length--)
    {
        crc = (crc>>8) ^ s_table[(crc & 0xFF) ^ *pBytes++];
    }
    
    return crc ^ 0xFFFFFFFFL;
}


@implementation DotCUtil

+ (uint32_t) crc32:(NSData *)data
{
    return crc32WithSeed((uint8_t*)data.bytes, (uint32_t)data.length, DEFAULT_SEED);
}

@end
