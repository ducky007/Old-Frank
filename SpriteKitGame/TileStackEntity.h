//
//  TileStackEntity.h
//  SpriteKitGame
//
//  Created by Skyler Lauren on 1/25/15.
//  Copyright (c) 2015 Sky Mist Development. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ItemEntity, MapEntity, PlantEntity;

@interface TileStackEntity : NSManagedObject

@property (nonatomic, retain) NSNumber * index_x;
@property (nonatomic, retain) NSNumber * index_y;
@property (nonatomic, retain) NSNumber * is_farm_plot;
@property (nonatomic, retain) NSNumber * is_tilled;
@property (nonatomic, retain) NSNumber * is_watered;
@property (nonatomic, retain) ItemEntity *background_item;
@property (nonatomic, retain) ItemEntity *foreground_item;
@property (nonatomic, retain) MapEntity *map;
@property (nonatomic, retain) ItemEntity *object_item;
@property (nonatomic, retain) PlantEntity *plant;

@end
