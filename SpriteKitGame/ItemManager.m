//
//  ItemManager.m
//  SpriteKitGame
//
//  Created by Skyler Lauren on 1/7/15.
//  Copyright (c) 2015 Sky Mist Development. All rights reserved.
//

#import "ItemManager.h"

@interface ItemManager ()

@property (nonatomic, strong)NSDictionary *items;

@end



@implementation ItemManager

+ (ItemManager *)sharedManager {
    static ItemManager *sharedItemManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedItemManager = [[self alloc] init];
    });
    return sharedItemManager;
}

-(Item *)getItem:(NSString *)itemName
{
    if (!self.items)
    {
        NSLog(@"firing up SQL");
        [self getSQLiteData];
    }
    
    Item *storedItem = self.items[itemName];
    
    Item *item = [[Item alloc]init];
    item.itemName = storedItem.itemName;
    item.itemType = storedItem.itemType;
    item.maxStack = storedItem.maxStack;
    item.impassable = storedItem.impassable;
    item.canPickUp = storedItem.canPickUp;
    item.quantity = 1;

    return item;
}

-(NSString *)getDatabasePath
{
    return [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"items.sqlite3"];
}

- (NSDictionary *)items
{
    if (!_items)
    {
        NSLog(@"firing up SQL");

        _items = [self getSQLiteData];
        
        NSLog(@"done");
        
    }
    
    
    return _items;
}

-(NSDictionary *)getSQLiteData
{
    NSMutableDictionary *items = [[NSMutableDictionary alloc]init];
    
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSString *dbPath = [[[NSBundle mainBundle] resourcePath ]stringByAppendingPathComponent:@"items.sqlite3"];
    BOOL success = [fileMgr fileExistsAtPath:dbPath];
   
    if(!success)
    {
        NSLog(@"Cannot locate database file '%@'.", dbPath);
    }
    
    sqlite3 *database;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        const char *sql = "SELECT * FROM items;";
        sqlite3_stmt *selectStatement;
        if(sqlite3_prepare_v2(database, sql, -1, &selectStatement, NULL) == SQLITE_OK) {
            while(sqlite3_step(selectStatement) == SQLITE_ROW) {
                Item *item = [[Item alloc]init];
                item.itemName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(selectStatement, 0)];
                item.itemType = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(selectStatement, 1)] integerValue];
                item.maxStack = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(selectStatement, 2)] integerValue];
                item.impassable = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(selectStatement, 3)] boolValue];
                item.canPickUp = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(selectStatement, 4)] boolValue];
                
                item.quantity = 1;
                [items setObject:item forKey:item.itemName];
            }
        }
        else
        {
            NSLog(@"error: %s", sqlite3_errmsg(database));
        }
    }
    else
    {
        NSLog(@"error: %s", sqlite3_errmsg(database));

        NSLog(@"did not open");
    }
    sqlite3_close(database);
    
    return items;
}

@end
