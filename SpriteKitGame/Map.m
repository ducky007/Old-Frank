//
//  Map.m
//  SpriteKitGame
//
//  Created by Skyler Lauren on 1/15/15.
//  Copyright (c) 2015 Sky Mist Development. All rights reserved.
//

#import "Map.h"
#import "TileStack.h"
#import "PlantManager.h"
#import "MapTrigger.h"
#import "MapEntity.h"
#import "SMDCoreDataHelper.h"
#import "MapTile.h"
#import "ItemManager.h"
#import "ItemEntity.h"
#import "MapTriggerEntity.h"
#import "TimeManager.h"

@interface Map ()

@property (nonatomic, strong)NSArray *farmPlots;

@property (nonatomic, strong)NSArray *mapTriggers;

@property (nonatomic)CGPoint playerStart;

@property (nonatomic)BOOL addObjects;
@property (nonatomic)BOOL hasUpdated;

@end

@implementation Map

-(void)setPlayer:(Player *)player
{
    player.position = self.playerStart;
//    player.position = CGPointMake(100, 100);
    _player = player;
}

-(id)initWithFileName:(NSString *)fileName
{
    self = [super init];
    
    if (self)
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"map_name = %@", fileName];
        NSArray *maps = [[SMDCoreDataHelper sharedHelper]fetchEntities:@"MapEntity" withPreditcate:predicate];

        self.dirtyIndexes = [[NSMutableArray alloc]init];
        
        if (maps.count == 1)
        {
            NSLog(@"found old map");

            [self loadMapFromCoreData:maps[0]];
        }
        else
        {
            [self loadFile:fileName];
        }
    }
    
    return self;
}

-(void)loadMapFromCoreData:(MapEntity *)mapEntity
{
    
    self.addObjects = [mapEntity.add_objects boolValue];
    self.updateTime = [mapEntity.update_time boolValue];
    
    self.mapWidth = [mapEntity.width integerValue];
    self.mapHeight = [mapEntity.height integerValue];
    self.tileWidth = [mapEntity.tile_width integerValue];
    
    NSMutableArray *farmPlots = [[NSMutableArray alloc] init];
    NSMutableArray *mapTriggers = [[NSMutableArray alloc] init];
    
    NSMutableArray *tiles = [[NSMutableArray alloc]init];

    NSLog(@"first run for TileStacks");
    
    for (NSInteger i = 0; i < self.mapWidth; i++)
    {
        NSMutableArray *rowArray = [[NSMutableArray alloc]init];
        
        for (NSInteger j = 0; j < self.mapHeight; j++)
        {
            TileStack *tileStack = [[TileStack alloc]init];
            [rowArray addObject:tileStack];
        }
        
        [tiles addObject:rowArray];
    }
    
    self.mapTiles = tiles;
    
    NSLog(@"second run for TileStacks");

    for (TileStackEntity *tileStackEntity in [mapEntity.tiles allObjects])
    {
        NSInteger index_X = [tileStackEntity.index_x integerValue];
        NSInteger index_Y = [tileStackEntity.index_y integerValue];
        
        TileStack *tileStack = self.mapTiles[index_X][index_Y];
        tileStack.indexX = index_X;
        tileStack.indexY = index_Y;
        tileStack.isFarmPlot = [tileStackEntity.is_farm_plot boolValue];
        tileStack.isWatered = [tileStackEntity.is_watered boolValue];
        tileStack.isTilled = [tileStackEntity.is_tilled boolValue];
        
        if (tileStack.isFarmPlot)
        {
            [farmPlots addObject:tileStack];
        }

        if (tileStackEntity.background_item)
        {
            Item *item = [[ItemManager sharedManager]getItem:tileStackEntity.background_item.item_name];
            item.quantity = [tileStackEntity.background_item.quantity integerValue];
            tileStack.backgroundItem = item;
        }

        if (tileStackEntity.object_item)
        {
            Item *item = [[ItemManager sharedManager]getItem:tileStackEntity.object_item.item_name];
            item.quantity = [tileStackEntity.object_item.quantity integerValue];
            tileStack.objectItem = item;
        }

        if (tileStackEntity.foreground_item)
        {
            Item *item = [[ItemManager sharedManager]getItem:tileStackEntity.foreground_item.item_name];
            item.quantity = [tileStackEntity.foreground_item.quantity integerValue];
            tileStack.foregroundItem = item;
        }
        
        if(tileStackEntity.plant)
        {
            Plant *plant = [PlantManager plantforName:tileStackEntity.plant.plant_name];
            plant.daysWatered = [tileStackEntity.plant.days_watered integerValue];
            tileStack.plant = plant;
            plant.plantEntity = tileStackEntity.plant;
        }
        
        tileStack.tileStackEntity = tileStackEntity;
    }
    
    NSLog(@"triggers");
    
    for (MapTriggerEntity *mapTrigger in [mapEntity.triggers allObjects])
    {
        NSInteger x = [mapTrigger.position_x integerValue];
        NSInteger y = [mapTrigger.position_y integerValue];
        NSInteger width = [mapTrigger.width integerValue];
        NSInteger height = [mapTrigger.height integerValue];
        NSString *mapName = mapTrigger.map_name;
        
        MapTrigger *mapTrigger = [[MapTrigger alloc]init];
        mapTrigger.rect = CGRectMake(x, y, width, height);
        mapTrigger.mapName = mapName;
        [mapTriggers addObject:mapTrigger];
    }
    
    NSInteger x = [mapEntity.start_x integerValue];
    NSInteger y = [mapEntity.start_y integerValue];
    
    self.playerStart = CGPointMake(x, y);
    
    self.mapTriggers = mapTriggers;
    self.farmPlots = farmPlots;
    
    NSLog(@"done");
    
}

-(void)loadFile:(NSString *)fileName
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"json"];
    
    NSError *error = nil;
    
    NSData *JSONData = [NSData dataWithContentsOfFile:filePath options:NSDataReadingMappedIfSafe error:&error];
    
    MapEntity *mapEntity = [[SMDCoreDataHelper sharedHelper]createNewEntity:@"MapEntity"];
    
    NSDictionary *mapDictionary = [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingAllowFragments error:&error];
    
    NSDictionary *properties = mapDictionary[@"properties"];
    
    self.addObjects = [properties[@"addObjects"] boolValue];
    self.updateTime = [properties[@"updateTime"] boolValue];
    
    self.mapWidth = [mapDictionary[@"width"] integerValue];
    self.mapHeight = [mapDictionary[@"height"] integerValue];
    
    mapEntity.add_objects = @(self.addObjects);
    mapEntity.update_time = @(self.updateTime);
    mapEntity.width = @(self.mapWidth);
    mapEntity.height = @(self.mapHeight);
    mapEntity.map_name = fileName;
    
    NSLog(@"Core");
    
    NSMutableArray *tiles = [[NSMutableArray alloc]init];
    
    for (NSInteger i = 0; i < self.mapWidth; i++)
    {
        NSMutableArray *rowArray = [[NSMutableArray alloc]init];
        
        for (NSInteger j = 0; j < self.mapHeight; j++)
        {
            TileStack *tileStack = [[TileStack alloc]init];
            TileStackEntity *tileStackEntity = [[SMDCoreDataHelper sharedHelper]createNewEntity:@"TileStackEntity"];
            tileStackEntity.map = mapEntity;
            tileStack.tileStackEntity = tileStackEntity;
            [rowArray addObject:tileStack];
        }
        
        [tiles addObject:rowArray];
    }
    
    self.mapTiles = tiles;
    
    NSMutableDictionary *textureDictionary = [[NSMutableDictionary alloc]init];
    
    for (NSDictionary *tileset in mapDictionary[@"tilesets"])
    {
        NSInteger staringEnum = [tileset[@"firstgid"] integerValue];
        NSInteger tileWidth = [tileset[@"tilewidth"] integerValue];
        
        self.tileWidth = tileWidth;
        mapEntity.tile_width = @(tileWidth);
        
        NSDictionary *tileProperties = tileset[@"tileproperties"];
        
        for (NSString *tileKey in [tileProperties allKeys])
        {
            NSInteger key = [tileKey integerValue];
            MapTile *tile = [[MapTile alloc]init];
            tile.indexKey = key+staringEnum;
            tile.properties = tileProperties[tileKey];
            [textureDictionary setObject:tile forKey:[NSString stringWithFormat:@"%@", @(key+staringEnum)]];            
            tile.properties = tileProperties[tileKey];
        }
    }
    
    NSInteger layer = 0;
    NSMutableArray *farmPlots = [[NSMutableArray alloc] init];
    NSMutableArray *mapTriggers = [[NSMutableArray alloc] init];
    
    //layers
    for (NSDictionary *layerDictionary in mapDictionary[@"layers"])
    {
        NSArray *data = layerDictionary[@"data"];
        
        if (data.count)
        {
            NSMutableArray *rowsArray = [[NSMutableArray alloc]init];
            
            NSInteger rangeStart;
            NSInteger rangeLength = self.mapWidth;
            
            for (int i = 0; i < self.mapHeight; i++)
            {
                rangeStart = data.count - ((i+1)*self.mapWidth);
                NSArray *row = [data subarrayWithRange:NSMakeRange(rangeStart, rangeLength)];
                [rowsArray addObject:row];
            }
            
            for (int i = 0; i < rowsArray.count; i ++)
            {
                NSArray *row = rowsArray[i];
                
                for (int j = 0; j < row.count; j++)
                {
                    NSNumber *number = row[j];
                   
                    if (number.integerValue)
                    {
                        NSString *key = [NSString stringWithFormat:@"%@", number];
                        MapTile *tile = textureDictionary[key];
                        
                        Item *item;
                        
                        if (tile.properties[@"name"])
                        {
                            item = [[ItemManager sharedManager]getItem:tile.properties[@"name"]];
                        }
                        
                        TileStack *tileStack = self.mapTiles[j][i];
                        tileStack.indexX = j;
                        tileStack.indexY = i;
                        
                        if([tile.properties[@"name"] isEqualToString:@"farm_plot"])
                        {
                            tileStack.isFarmPlot = YES;
                            [farmPlots addObject:tileStack];
                        }
                        else
                        {
                            [tileStack addItem:item forLayer:layer];
                        }
                        
                    }
                }
            }
            
            layer++;
        }
        
        NSArray *objects = layerDictionary[@"objects"];
        
        if (objects.count)
        {
            
            for (NSDictionary *objectDictionary in objects)
            {
                NSInteger width = [objectDictionary[@"width"] integerValue];
                NSInteger height = [objectDictionary[@"height"] integerValue];
                
                NSInteger x = [objectDictionary[@"x"] integerValue]+width/2-self.tileWidth/2;
                NSInteger y = self.mapHeight*self.tileWidth - [objectDictionary[@"y"] integerValue]-height/2-self.tileWidth/2;
                
                NSDictionary *properties = objectDictionary[@"properties"];
               
                if (properties[@"loadMap"])
                {
                    x = [objectDictionary[@"x"] integerValue]-self.tileWidth/2;
                    y = self.mapHeight*self.tileWidth - [objectDictionary[@"y"] integerValue]-self.tileWidth/2;
                    
                    MapTrigger *mapTrigger = [[MapTrigger alloc]init];
                    
                    MapTriggerEntity *mapTriggerEntity = [[SMDCoreDataHelper sharedHelper]createNewEntity:@"MapTriggerEntity"];
                    mapTriggerEntity.map = mapEntity;
                    mapTriggerEntity.position_x = @(x);
                    mapTriggerEntity.position_y = @(y);
                    mapTriggerEntity.width = @(width);
                    mapTriggerEntity.height = @(height);
                    mapTriggerEntity.map_name = properties[@"loadMap"];
                    
                    mapTrigger.rect = CGRectMake(x, y, width, height);
                    mapTrigger.mapName = properties[@"loadMap"];
                    [mapTriggers addObject:mapTrigger];
                }
                else if (properties[@"playerStart"])
                {
                    x = [objectDictionary[@"x"] integerValue]-self.tileWidth/2;
                    y = self.mapHeight*self.tileWidth - [objectDictionary[@"y"] integerValue]-self.tileWidth/2;
                    
                    self.playerStart = CGPointMake(x+width/2, y+height/2);
                    
                    mapEntity.start_x = @(self.playerStart.x);
                    mapEntity.start_y = @(self.playerStart.y);
                    
                }
            }
        }
    }
    
    self.mapTriggers = mapTriggers;
    self.farmPlots = farmPlots;
    
    if (self.addObjects)
    {
        [self addRandomSeedBag];
        [self addRandomObjects];
        [self addRandomObjects];
        [self addRandomObjects];
        [self addRandomObjects];
        [self addRandomObjects];
        [self addRandomObjects];
    }
    
    //don't to save until after done setting up
    for (NSInteger i = 0; i < self.mapWidth; i++)
    {
        for (NSInteger j = 0; j < self.mapHeight; j++)
        {
            TileStack *tileStack = self.mapTiles[i][j];
            tileStack.shouldSave = YES;
        }
    }
    
    [[SMDCoreDataHelper sharedHelper]save];
}

-(NSArray *)tilesAroundIndex:(MapIndex)mapIndex
{
    NSMutableArray *tiles = [[NSMutableArray alloc]init];
    
    if (mapIndex.x - 1 >= 0)
    {
        [tiles addObject:self.mapTiles[mapIndex.x-1][mapIndex.y]];
    }
    
    if (mapIndex.y - 1 >= 0)
    {
        [tiles addObject:self.mapTiles[mapIndex.x][mapIndex.y-1]];
    }
    
    if (mapIndex.x + 1 < self.mapWidth)
    {
        [tiles addObject:self.mapTiles[mapIndex.x+1][mapIndex.y]];
    }
    
    if (mapIndex.y + 1 >= 0)
    {
        [tiles addObject:self.mapTiles[mapIndex.x][mapIndex.y+1]];
    }

    if (mapIndex.x-1 >= 0 && mapIndex.y-1 >=0)
    {
        [tiles addObject:self.mapTiles[mapIndex.x-1][mapIndex.y-1]];
    }
    
    if (mapIndex.x+1 < self.mapWidth && mapIndex.y+1 < self.mapHeight)
    {
        [tiles addObject:self.mapTiles[mapIndex.x+1][mapIndex.y+1]];
    }
    
    if (mapIndex.x-1 >= 0 && mapIndex.y+1 < self.mapHeight)
    {
        [tiles addObject:self.mapTiles[mapIndex.x-1][mapIndex.y+1]];
    }
    
    if (mapIndex.x+1 < self.mapWidth && mapIndex.y-1 >=0)
    {
        [tiles addObject:self.mapTiles[mapIndex.x+1][mapIndex.y-1]];
    }
    
    [tiles addObject:self.mapTiles[mapIndex.x][mapIndex.y]];
    
    
    return tiles;
}

-(NSValue *)rectForTile:(TileStack *)tileStack
{
    CGRect frame = CGRectMake(tileStack.indexX*self.tileWidth-self.tileWidth/2, -tileStack.indexY*self.tileWidth-self.tileWidth/2, self.tileWidth, self.tileWidth);
    
#if TARGET_OS_IPHONE
    return [NSValue valueWithCGRect:frame];
#else
    return [NSValue valueWithRect:frame];
#endif
    
}

-(void)updateCollisionArrayForPlayer:(Player *)player
{
    CGPoint point = CGPointMake(player.position.x, player.position.y-player.height/4);
    MapIndex index = [self indexForPositionCGPoint:point];
    
    NSArray *tilesAroundIndex = [self tilesAroundIndex:index];
    
    NSMutableArray *collisionTiles = [[NSMutableArray alloc]init];
    
    for (TileStack *tileStack in tilesAroundIndex)
    {
        if (tileStack.objectItem.impassable)
        {
            [collisionTiles addObject:[self rectForTile:tileStack]];
        }
    }
    
    self.player.collisionRects = collisionTiles;
}

-(void)update:(float)dt
{
    [self updateCollisionArrayForPlayer:self.player];
    
    [self.player update:dt];
    
    //keep player on map
    CGPoint playerPosition = self.player.position;
    
    if (playerPosition.x < self.player.width/2-self.tileWidth/2)
        playerPosition.x = self.player.width/2-self.tileWidth/2;
    
    if (playerPosition.y < self.player.height/2-self.tileWidth/2)
        playerPosition.y = self.player.height/2-self.tileWidth/2;
    
    if (playerPosition.x > self.mapWidth*self.tileWidth-self.player.width/2-self.tileWidth/2)
        playerPosition.x = self.mapWidth*self.tileWidth-self.player.width/2-self.tileWidth/2;
    
    if (playerPosition.y > self.mapHeight*self.tileWidth-self.player.height/2-self.tileWidth/2)
        playerPosition.y = self.mapHeight*self.tileWidth-self.player.height/2-self.tileWidth/2;
    
    self.player.position = playerPosition;
    
    TileStack *tileStack = [self tileStackForPlayer:self.player];
    
    if (tileStack.objectItem.canPickUp)
    {
        self.canUseActionButton = YES;
        self.actionButtonType = ActionButtonTypeHarvest;
    }
    else if(tileStack.objectItem.itemType == ItemTypeFoodstand)
    {
        self.canUseActionButton = YES;
        self.actionButtonType = ActionButtonTypeOpen;
    }
    else
    {
        self.canUseActionButton = NO;
        self.actionButtonType = ActionButtonTypeNone;
    }
    
    if (tileStack.objectItem || tileStack.isFarmPlot)
    {
        if (tileStack.objectItem.itemType != ItemTypeBackground && tileStack.objectItem.itemType != ItemTypeFoodstand)
        {
            self.outlinePosition = CGPointMake(tileStack.indexX * self.tileWidth, tileStack.indexY * self.tileWidth);
        }
        else
        {
            self.outlinePosition = CGPointMake(-1000, -1000);
        }
    }
    else
    {
        self.outlinePosition = CGPointMake(-1000, -1000);
    }
    
    for (MapTrigger *mapTrigger in self.mapTriggers)
    {
        if (CGRectContainsPoint(mapTrigger.rect, self.player.position))
        {
            NSLog(@"Hello River. Time to switch maps to %@", mapTrigger.mapName);
            [self.delegate loadMapWithName:mapTrigger.mapName];
        }
    }
    
    if (self.player.energy <= 0)
    {
        NSLog(@"Passed out");
        
        [self.delegate displayDialog:[DialogManager getDialogWithDialogName:DialogPassedOut] withBlock:^(DialogResponse response) {
            
        }];
        
        [self updateForNewDay];
        self.player.energy = self.player.maxEnergy * .5;
        [[TimeManager sharedManager] setTime:480];
        [self.delegate loadMapWithName:@"house"];
    }
    
    if (self.updateTime)
    {
        TimeManager *timeManager = [TimeManager sharedManager];
        [timeManager addTime:dt];
        
        if (!self.hasUpdated && (timeManager.time > 360 && timeManager.time < 370))
        {
            [self updateForNewDay];
            self.hasUpdated = YES;
        }
        else if (!(timeManager.time > 360 && timeManager.time < 370))
        {
            self.hasUpdated = NO;
        }
    }
}


-(void)addRandomObjects
{
    NSArray *objectArray = @[@"rose", @"",@"stump", @"",@"stump",@"weed",@"weed",@"weed",@"",@"",@"small_rock",@"small_rock",@"medium_rock",@"medium_rock", @"large_rock", @"", @"", @"large_rock", @"", @"", @"", @"", @"", @"", @"", @"bag_of_gold"];
    
    for (TileStack *tileStack in self.farmPlots)
    {
        if (!tileStack.isTilled && !tileStack.objectItem)
        {
            NSInteger random = arc4random() % objectArray.count;
            NSString *randomItemName = objectArray[random];
            
            if (randomItemName.length)
            {
                Item *item = [[ItemManager sharedManager]getItem:randomItemName];
                tileStack.objectItem = item;
            }
        }
    }
}

-(void)addRandomSeedBag
{
    for (NSInteger i = 0; i < 2; i++)
    {
        Item *seeds;
        
        while (!seeds)
        {
            NSInteger randomX = arc4random() % self.mapWidth;
            NSInteger randomY = arc4random() % self.mapHeight;
            TileStack *tileStack = self.mapTiles[randomX][randomY];
            
            if (!tileStack.objectItem)
            {
                seeds = [[ItemManager sharedManager]getItem:@"corn_seeds"];
                tileStack.objectItem = seeds;
                
                CGPoint index = CGPointMake(tileStack.indexX, tileStack.indexY);

            #if TARGET_OS_IPHONE
                [self.dirtyIndexes addObject:[NSValue valueWithCGPoint:index]];
            #else
                [self.dirtyIndexes addObject:[NSValue valueWithPoint:index]];
            #endif
            
            }
        }
    }
}

-(MapIndex)indexForPositionCGPoint:(CGPoint)point
{
    NSInteger x = ((point.x+self.tileWidth/2)/self.tileWidth);
    NSInteger y = ((point.y+self.tileWidth/2)/self.tileWidth);
    
    MapIndex mapIndex;
    mapIndex.x = x;
    mapIndex.y = y;
    
    return mapIndex;
}

-(void)updateForNewDay
{
    for (TileStack *tileStack in self.farmPlots)
    {
        [tileStack updateForNewDay];
        
        CGPoint index = CGPointMake(tileStack.indexX, tileStack.indexY);

        #if TARGET_OS_IPHONE
        [self.dirtyIndexes addObject:[NSValue valueWithCGPoint:index]];
        #else
        [self.dirtyIndexes addObject:[NSValue valueWithPoint:index]];
        #endif
    }
    
    [self addRandomObjects];
    [self addRandomSeedBag];
}

-(TileStack *)tileStackForPlayer:(Player *)player
{
    CGPoint offsetPoint = CGPointMake(player.position.x, player.position.y-player.height/4);
    
    MapIndex index = [self indexForPositionCGPoint:offsetPoint];
    
    switch (player.direction)
    {
        case DirectionRight:
            if ((index.x + 1) < self.mapWidth-1)
            {
                index.x = index.x+1;
            }
            break;
        case DirectionLeft:
            if ((index.x - 1) > 0)
            {
                index.x= index.x-1;
            }
            break;
        case DirectionUp:
            if ((index.y + 1) < self.mapHeight-1)
            {
                index.y = index.y+1;
            }
            break;
        case DirectionDown:
            if ((index.y - 1) > 0)
            {
                index.y = index.y-1;
            }
            break;
            
        default:
            break;
    }
    
    return self.mapTiles[index.x][index.y];
}

-(void)primaryButtonPressedForPlayer:(Player *)player
{
    TileStack *tileStack = [self tileStackForPlayer:player];
    
    //tilling
    if (tileStack.isFarmPlot && !tileStack.isTilled && !tileStack.objectItem &&self.player.equippedTool.itemType == ItemTypeSword)
    {
        Item *item = [[ItemManager sharedManager]getItem:@"tilled"];
        tileStack.backgroundItem = item;
        tileStack.isTilled = YES;
        
        CGPoint index = CGPointMake(tileStack.indexX, tileStack.indexY);
        
        #if TARGET_OS_IPHONE
        [self.dirtyIndexes addObject:[NSValue valueWithCGPoint:index]];
        #else
        [self.dirtyIndexes addObject:[NSValue valueWithPoint:index]];
        #endif
        
        self.player.energy -= 5;

    }
    //watering
    else if (tileStack.isFarmPlot && tileStack.isTilled && self.player.equippedTool.itemType == ItemTypeWateringCan)
    {
        Item *item = [[ItemManager sharedManager]getItem:@"watered"];
        tileStack.backgroundItem = item;
        tileStack.isWatered = YES;
        
        CGPoint index = CGPointMake(tileStack.indexX, tileStack.indexY);
        
        #if TARGET_OS_IPHONE
        [self.dirtyIndexes addObject:[NSValue valueWithCGPoint:index]];
        #else
        [self.dirtyIndexes addObject:[NSValue valueWithPoint:index]];
        #endif
        
        self.player.energy -= 5;

    }
}

-(void)actionButtonPressedForPlayer:(Player *)player
{
    TileStack *tileStack = [self tileStackForPlayer:player];

    if (self.actionButtonType == ActionButtonTypeNone)
    {
        NSLog(@"harvest");
        
        if (!tileStack.objectItem && tileStack.isTilled && player.equippedItem.itemType == ItemTypeSeed)
        {

            NSString *plantName = [player.equippedItem.itemName stringByReplacingOccurrencesOfString:@"_seeds" withString:@""];
            Plant *plant = [PlantManager plantforName:plantName];
            tileStack.plant = plant;
            
            CGPoint index = CGPointMake(tileStack.indexX, tileStack.indexY);
            
#if TARGET_OS_IPHONE
            [self.dirtyIndexes addObject:[NSValue valueWithCGPoint:index]];
#else
            [self.dirtyIndexes addObject:[NSValue valueWithPoint:index]];
#endif
            
            [self.player removeItem];
        }
        else if (player.equippedItem.itemType == ItemTypeSpellBook)
        {
            if ([player.equippedItem.itemName isEqualToString:@"fire_spellbook"])
            {
                CGPoint point = CGPointMake(tileStack.indexX*self.tileWidth, tileStack.indexY*self.tileWidth);
                self.player.energy -= 10;
                [self.delegate launchProjectile:[[ItemManager sharedManager]getItem:@"fire_01"] fromPoint:self.player.position toPoint:point];
            }
        }
    }
    else
    {
        //picking up item
        if (self.actionButtonType == ActionButtonTypeHarvest && tileStack.objectItem.canPickUp && !tileStack.plant)
        {
            NSString *item = tileStack.objectItem.itemName;
            
            CGPoint index = CGPointMake(tileStack.indexX, tileStack.indexY);
            
#if TARGET_OS_IPHONE
            [self.dirtyIndexes addObject:[NSValue valueWithCGPoint:index]];
#else
            [self.dirtyIndexes addObject:[NSValue valueWithPoint:index]];
#endif
            
            tileStack.objectItem = nil;
            
            [self.player addItemWithName:item];
        }
        //picking up plant
        else if (self.actionButtonType == ActionButtonTypeHarvest && tileStack.objectItem.canPickUp && tileStack.plant)
        {
            NSString *item = tileStack.plant.plantName;
            tileStack.plant = nil;
            tileStack.objectItem = nil;
            [self.player addItemWithName:item];
            
            CGPoint index = CGPointMake(tileStack.indexX, tileStack.indexY);
            
#if TARGET_OS_IPHONE
            [self.dirtyIndexes addObject:[NSValue valueWithCGPoint:index]];
#else
            [self.dirtyIndexes addObject:[NSValue valueWithPoint:index]];
#endif
            
        }
        else if (self.actionButtonType == ActionButtonTypeOpen && tileStack.objectItem.itemType == ItemTypeFoodstand)
        {
            [self.delegate displayDialog:[DialogManager getDialogWithDialogName:DialogNameFoodStand] withBlock:^(DialogResponse response) {
            }];
        }
    }

    
    
   
}

-(void)doneWithProjectile:(Item *)projectile atPoint:(CGPoint)point
{
    MapIndex index = [self indexForPositionCGPoint:point];
    
    //needs to be switched to block instead of delegate callback
    if (index.x > self.mapWidth-1 || index.y > self.mapHeight-1)
    {
        return;
    }
    
    TileStack *tileStack = self.mapTiles[index.x][index.y];
    
    if (tileStack.objectItem.itemType == ItemTypeWood)
    {
        tileStack.objectItem = nil;
        CGPoint dirtyIndex = CGPointMake(index.x, index.y);
        
#if TARGET_OS_IPHONE
        [self.dirtyIndexes addObject:[NSValue valueWithCGPoint:dirtyIndex]];
#else
        [self.dirtyIndexes addObject:[NSValue valueWithPoint:dirtyIndex]];
#endif    
        
    }
}



@end
