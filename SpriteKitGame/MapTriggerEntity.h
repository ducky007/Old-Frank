//
//  MapTriggerEntity.h
//  SpriteKitGame
//
//  Created by Skyler Lauren on 1/25/15.
//  Copyright (c) 2015 Sky Mist Development. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MapEntity;

@interface MapTriggerEntity : NSManagedObject

@property (nonatomic, retain) NSNumber * position_x;
@property (nonatomic, retain) NSNumber * position_y;
@property (nonatomic, retain) NSNumber * width;
@property (nonatomic, retain) NSNumber * height;
@property (nonatomic, retain) NSString * map_name;
@property (nonatomic, retain) MapEntity *map;

@end
