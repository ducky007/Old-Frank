//
//  PlantEntity.h
//  SpriteKitGame
//
//  Created by Skyler Lauren on 1/25/15.
//  Copyright (c) 2015 Sky Mist Development. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TileStackEntity;

@interface PlantEntity : NSManagedObject

@property (nonatomic, retain) NSNumber * days_watered;
@property (nonatomic, retain) NSString * plant_name;
@property (nonatomic, retain) NSNumber * watered;
@property (nonatomic, retain) TileStackEntity *tile_stack;

@end
