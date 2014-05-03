//
//  MapNode.m
//  SpriteKitGame
//
//  Created by Skyler Lauren on 5/3/14.
//  Copyright (c) 2014 Sky Mist Development. All rights reserved.
//

#import "MapNode.h"
#import "TileStack.h"
#import "MapTile.h"
#import "PlantManager.h"
#import "MapTrigger.h"
#import "MapEntity.h"
#import "SMDCoreDataHelper.h"
#import "TileStackNode.h"
#import "ItemSprite.h"

@interface MapNode ()

@property (nonatomic, strong)SKSpriteNode *outlineSprite;
@property (nonatomic, strong)NSArray *farmPlots;

@property (nonatomic, strong)NSArray *mapTriggers;

@property (nonatomic)CGPoint playerStart;

@property (nonatomic)BOOL addObjects;

@property (nonatomic, strong)NSArray *tileStackNodes;

@property (nonatomic, strong)NSMutableDictionary *textures;

@end

@implementation MapNode

-(id)initWithMap:(Map *)map
{
    self = [super init];
    
    if (self) {
        
        NSLog(@"Loading Map now");
        self.map = map;
        self.textures = [[NSMutableDictionary alloc]init];
        [self loadMap:map];
    }
    
    return self;
}

-(SKTexture *)getTextureForName:(NSString *)name
{
    
    SKTexture *texture = self.textures[name];
    
    if (!texture)
    {
//        NSLog(@"Creating: %@", name);
        texture = [SKTexture textureWithImageNamed:name];
        texture.filteringMode = SKTextureFilteringNearest;
        [self.textures setObject:texture forKey:name];
    }
    
    return texture;
}

-(void)loadMap:(Map *)map
{
    NSLog(@"looping");
    
    PlayerAnimatedSpriteNode *animatedSprite = [[PlayerAnimatedSpriteNode alloc]initWithPlayer:self.map.player];
    animatedSprite.zPosition = 4;
    self.animatedSpriteNode = animatedSprite;
    [self addChild:animatedSprite];
    
    NSMutableArray *tiles = [[NSMutableArray alloc]init];
    
    for (NSInteger i = 0; i < map.mapWidth; i++)
    {
        NSMutableArray *rowArray = [[NSMutableArray alloc]init];
        
        for (NSInteger j = 0; j < map.mapHeight; j++)
        {
            TileStackNode *tilestackNode = [[TileStackNode alloc]init];
            [rowArray addObject:tilestackNode];
        }
        
        [tiles addObject:rowArray];
    }
    
    self.tileStackNodes = tiles;
    
    for (NSInteger i = 0; i < self.map.mapWidth; i++)
    {
        for (NSInteger j = 0; j < self.map.mapHeight; j++)
        {
            TileStack *tileStack = self.map.mapTiles[i][j];
            
            TileStackNode *tileStackNode = self.tileStackNodes[i][j];
            tileStackNode.tileStack = tileStack;
            
            tileStackNode.position = CGPointMake(tileStack.indexX * map.tileWidth, tileStack.indexY  * map.tileWidth);
            
            if (tileStack.backgroundItem)
            {
                
                NSString *itemName = tileStack.backgroundItem.itemName;
                
                SKTexture *texture = [self getTextureForName:itemName];
                
                ItemSprite *itemSprite = [ItemSprite spriteNodeWithTexture:texture];
                itemSprite.name = itemName;
                tileStackNode.backgroundItemSprite = itemSprite;
            }
            
            if (tileStack.objectItem) {

                NSString *itemName = tileStack.objectItem.itemName;
                
                SKTexture *texture = [self getTextureForName:itemName];
                
                ItemSprite *itemSprite = [ItemSprite spriteNodeWithTexture:texture];
                itemSprite.name = itemName;

                tileStackNode.objectItemSprite = itemSprite;

            }
            if (tileStack.foregroundItem)
            {
                NSString *itemName = tileStack.foregroundItem.itemName;
                
                SKTexture *texture = [self getTextureForName:itemName];
                
                ItemSprite *itemSprite = [ItemSprite spriteNodeWithTexture:texture];
                itemSprite.name = itemName;
                
                tileStackNode.foregroundItemSprite = itemSprite;

            }

            [self addChild:tileStackNode];
        }
    }
    
    NSLog(@"Done");

    SKTexture *texture = [SKTexture textureWithImageNamed:@"outline"];
    texture.filteringMode = SKTextureFilteringNearest;
    self.outlineSprite = [SKSpriteNode spriteNodeWithTexture:texture];
    self.outlineSprite.zPosition = 3;
    [self addChild:self.outlineSprite];
}

-(void)update
{
    [self.animatedSpriteNode update];
    self.outlineSprite.position = self.map.outlinePosition;
    
    for (NSValue *value in self.map.dirtyIndexes)
    {
        CGPoint index = [value CGPointValue];
        [self updateTileStackAtIndex:index];
    }
}

-(void)updateTileStackAtIndex:(CGPoint)index
{
    MapIndex mapIndex;
    mapIndex.x = index.x;
    mapIndex.y = index.y;
    
    TileStackNode *tileStackNode = self.tileStackNodes[mapIndex.x][mapIndex.y];
    TileStack *tileStack = self.map.mapTiles[mapIndex.x][mapIndex.y];
    
    if (![tileStackNode.backgroundItemSprite.name isEqualToString:tileStack.backgroundItem.itemName])
    {
        ItemSprite *itemSprite;
        
        if (tileStack.backgroundItem)
        {
            NSString *itemName = tileStack.backgroundItem.itemName;
            itemSprite = [[ItemSprite alloc]initWithTexture:[self getTextureForName:itemName]];
            itemSprite.name = itemName;
        }
       
        tileStackNode.backgroundItemSprite = itemSprite;
    }
    
    if (![tileStackNode.objectItemSprite.name isEqualToString:tileStack.objectItem.itemName])
    {
        ItemSprite *itemSprite;
        
        if (tileStack.objectItem)
        {
            NSString *itemName = tileStack.objectItem.itemName;
            itemSprite = [[ItemSprite alloc]initWithTexture:[self getTextureForName:itemName]];
            itemSprite.name = itemName;
        }
        
        tileStackNode.objectItemSprite = itemSprite;
    }

    if (![tileStackNode.foregroundItemSprite.name isEqualToString:tileStack.foregroundItem.itemName])
    {
        ItemSprite *itemSprite;
        
        if (tileStack.foregroundItem)
        {
            NSString *itemName = tileStack.foregroundItem.itemName;
            itemSprite = [[ItemSprite alloc]initWithTexture:[self getTextureForName:itemName]];
            itemSprite.name = itemName;
        }
        
        tileStackNode.foregroundItemSprite = itemSprite;
    }
}

@end
