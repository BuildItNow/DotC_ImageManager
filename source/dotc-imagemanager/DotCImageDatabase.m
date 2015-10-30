//
//  ImageDatabase.m
//  dotc-imagemanager
//
//  Created by Yang G on 15-10-10.
//  Copyright (c) 2015年 .C . All rights reserved.
//

#import <Foundation/NSDate.h>

#import "Defines.h"
#import "DotCImageDatabase.h"
#import "FMDatabase.h"
#import "DotCImageManager.h"
#import "DotCIntegrateAdapter.h"

static NSString* IMAGE_DATABASE_NAME = @"images.db";
static NSString* TABLE_IMAGES  = @"images";
static NSString* TABLE_VERSION = @"version";

#define IMAGE_DATABASE_VERSION 2

@interface DotCImageDatabase()
{
    FMDatabase*     _db;
}

@end

@implementation DotCImageDatabase

- (instancetype) init
{
    if(!(self = [super init]))
    {
        return self;
    }
    
    if(![self initDatabase])
    {
        //[self autorelease];
        
        return nil;
    }
   
    return self;
}

- (void) dealloc
{
    [self releaseDatabase];
    
    [super dealloc];
}

- (BOOL) initDatabase
{
    NSString* path = [[DotCImageManager integrateAdapter] getDatabasePath];
    if(![[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:TRUE attributes:nil  error:nil];
    }
    
    path = [path stringByAppendingPathComponent:IMAGE_DATABASE_NAME];
    FMDatabase* db = [FMDatabase databaseWithPath:path];
    
    if(!db)
    {
        NSLog(@"Create ImageDatabase Fail");
        
        goto OPERATION_FAIL;
    }
    
    if (![db open])
    {
        NSLog(@"Open ImageDatabase Fail");
        
        goto OPERATION_FAIL;
    }
    
    _db = [db retain];
    
    [_db setShouldCacheStatements:YES];
    
    // Check database version
    {
        [_db executeUpdate:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (id TEXT PRIMARY KEY, version INTEGER)", TABLE_VERSION]];
        
        int oldVersion = -1;
        
        FMResultSet* result = [_db executeQuery:[NSString stringWithFormat:@"SELECT version FROM %@ WHERE id=\'version\'", TABLE_VERSION]];
        if(result.next)
        {
            oldVersion = [result intForColumn:@"version"];
        }
        [result close];
        
        if(oldVersion != IMAGE_DATABASE_VERSION)    // Clean all the datas
        {
            NSString* insert = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ (id, version) VALUES (\'version\', %d)",
                                TABLE_VERSION,
                                IMAGE_DATABASE_VERSION];
            [_db executeUpdate:insert];
            
            [_db executeUpdate:[NSString stringWithFormat:@"DROP TABLE %@", TABLE_IMAGES]];
            
            NSLog(@"IMAGE_DATABASE_VERSION is incorrect, clean all old datas");
        }
    }
    
    [_db executeUpdate:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (id TEXT PRIMARY KEY, data BLOB, dataSize INTEGER, lastUpdateTime INTEGER, other BLOB NULL)", TABLE_IMAGES]];
    
    if ([_db hadError])
    {
        NSLog(@"Create Table Error %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
        
        goto OPERATION_FAIL;
    }

    return TRUE;
    
OPERATION_FAIL:
    [self releaseDatabase];
    
    return FALSE;
}

- (void) releaseDatabase
{
    if(_db)
    {
        [_db close];
        [_db release];
        _db = nil;
    }
}

- (NSData*) imageData:(NSString*)key
{
    return [self imageData:key other:NULL];
}

- (NSData*) imageData:(NSString*)key other:(NSData**)other
{
    NSData* ret = nil;
    key = [key lowercaseString];
    
    NSString* select = [NSString stringWithFormat:@"SELECT data, other FROM %@ WHERE id = \'%@\'", TABLE_IMAGES, key];
    FMResultSet* result = [_db executeQuery:select];
    
    if(result.next)
    {
        ret = [result dataForColumn:@"data"];
        if(other)
        {
            *other = [result dataForColumn:@"other"];
        }
        
        // Update lastUpdateTime
        unsigned long lastUpdateTime = [[NSDate date] timeIntervalSince1970];
        NSString* update = [NSString stringWithFormat:@"UPDATE %@ SET lastUpdateTime = %lu WHERE id = \'%@\'",
                                                TABLE_IMAGES,
                                                lastUpdateTime,
                                                key
                            ];
        
        if(![_db executeUpdate:update])
        {
            NSLog(@"\nFMDatabase Fail %d\nDesc %@", _db.lastErrorCode, _db.lastErrorMessage);
        }
    }
    else
    {
        ret = nil;
        if(other)
        {
            *other = nil;
        }
    }
    
    [result close];
    
    return ret;
}

- (int) save:(NSString*)key imageData:(NSData*)data
{
    return [self save:key imageData:data other:nil];
}

- (int) save:(NSString*)key imageData:(NSData*)data other:(NSData*)other
{
    key = key.lowercaseString;
    unsigned long lastUpdateTime = [[NSDate date] timeIntervalSince1970];
    unsigned long dataSize       = (unsigned long)data.length;
    
    NSString* insert = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ (id, data, dataSize, lastUpdateTime, other) VALUES (\'%@\', ?, %lu, %lu, %@)",
                        TABLE_IMAGES,
                        key,
                        dataSize,
                        lastUpdateTime,
                        (other ? @"?" : @"NULL")];
    
    BOOL ret = FALSE;
    ret = other ? [_db executeUpdate:insert, data, other] : [_db executeUpdate:insert, data];
    if(!ret)
    {
        NSLog(@"\nFMDatabase Fail %d\nDesc %@", _db.lastErrorCode, _db.lastErrorMessage);
    }
    
    return ret ? 0 : -1;
}

- (void) clear:(float)daysAgo
{
    int time = [[NSDate date] timeIntervalSince1970] - daysAgo*24*60*60;
    NSString* del = [NSString stringWithFormat:@"DELETE FROM %@ WHERE lastUpdateTime<=%d", TABLE_IMAGES, time];
    
    NSLog(@"Clear ImageDataBase Before %.2f days", daysAgo);
    
    [_db executeUpdate:del];
}

- (int)  getDatabaseSize
{
    int ret = 0;
    NSString* select = [NSString stringWithFormat:@"SELECT sum(dataSize) AS databaseSize FROM %@;", TABLE_IMAGES];
    FMResultSet* result = [_db executeQuery:select];
    if(result.next)
    {
        ret = (int)[result longForColumn:@"databaseSize"];
    }
    
    [result close];
    
    return ret;
}

@end
