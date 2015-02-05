//
//  DialogManager.m
//  SpriteKitGame
//
//  Created by Skyler Lauren on 2/25/15.
//  Copyright (c) 2015 Sky Mist Development. All rights reserved.
//

#import "DialogManager.h"
#import <sqlite3.h>

@implementation DialogManager

+ (NSString *)getDatabasePath
{
    return [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"items.sqlite3"];
}

+(Dialog *)getDialogWithDialogName:(DialogName)dialogName
{
    Dialog *dialog = [[Dialog alloc]init];
    
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSString *dbPath = [[[NSBundle mainBundle] resourcePath ]stringByAppendingPathComponent:@"items.sqlite3"];
    BOOL success = [fileMgr fileExistsAtPath:dbPath];
    
    if(!success)
    {
        NSLog(@"Cannot locate database file '%@'.", dbPath);
    }
    
    sqlite3 *database;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        
        NSString *query = [NSString stringWithFormat:@"SELECT * FROM dialog WHERE dialog_id = %@;", @(dialogName)];
        
        const char *sql =  [query UTF8String]; // "SELECT * FROM dialog WHERE dialog_id = ;";
        sqlite3_stmt *selectStatement;
        if(sqlite3_prepare_v2(database, sql, -1, &selectStatement, NULL) == SQLITE_OK) {
            while(sqlite3_step(selectStatement) == SQLITE_ROW) {
                
                dialog.dialogName = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(selectStatement, 0)] integerValue];
                dialog.text = [NSString stringWithUTF8String:(char *)sqlite3_column_text(selectStatement, 1)];
                dialog.responseType = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(selectStatement, 2)] integerValue];
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
    
    return dialog;
}


@end
