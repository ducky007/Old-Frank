//
//  ItemEntity.h
//  SpriteKitGame
//
//  Created by Skyler Lauren on 1/25/15.
//  Copyright (c) 2015 Sky Mist Development. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PlayerEntity, TileStackEntity;

@interface ItemEntity : NSManagedObject

@property (nonatomic, retain) NSString * item_name;
@property (nonatomic, retain) NSNumber * quantity;
@property (nonatomic, retain) PlayerEntity *player_inventory;
@property (nonatomic, retain) PlayerEntity *player_item;
@property (nonatomic, retain) PlayerEntity *player_tool;
@property (nonatomic, retain) TileStackEntity *tile_stack_background;
@property (nonatomic, retain) TileStackEntity *tile_stack_foreground;
@property (nonatomic, retain) TileStackEntity *tile_stack_object;

@end
