//
//  TileStack.h
//  SpriteKitGame
//
//  Created by Skyler Lauren on 1/1/15.
//  Copyright (c) 2015 Sky Mist Development. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Plant.h"
#import "Item.h"
#import "TileStackEntity.h"

@interface TileStack : NSObject

@property (nonatomic, strong)TileStackEntity *tileStackEntity;

@property (nonatomic, strong)Item *backgroundItem;
@property (nonatomic, strong)Item *objectItem;
@property (nonatomic, strong)Item *foregroundItem;

@property (nonatomic)BOOL isFarmPlot;
@property (nonatomic)BOOL isTilled;
@property (nonatomic)BOOL isWatered;

@property (nonatomic)NSInteger indexX;
@property (nonatomic)NSInteger indexY;

@property (nonatomic)Plant *plant;

-(void)addItem:(Item *)item forLayer:(NSInteger)layer;
-(void)updateForNewDay;

@end
