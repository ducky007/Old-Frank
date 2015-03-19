//
//  FarmMap.m
//  Old Frank
//
//  Created by Skyler Lauren on 3/14/15.
//  Copyright (c) 2015 Sky Mist Development. All rights reserved.
//

#import "FarmMap.h"

@implementation FarmMap

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

-(void)updateForNewDay
{
    [super updateForNewDay];
    
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


@end
