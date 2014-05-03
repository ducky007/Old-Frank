//
//  TileStackNode.h
//  SpriteKitGame
//
//  Created by Skyler Lauren on 1/21/15.
//  Copyright (c) 2015 Sky Mist Development. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>
#import "TileStack.h"   
#import "ItemSprite.h"

@interface TileStackNode : SKNode

-(id)initWithTileStack:(TileStack *)tileStack;

@property (nonatomic, strong)TileStack *tileStack;

@property (nonatomic, strong)ItemSprite *backgroundItemSprite;
@property (nonatomic, strong)ItemSprite *objectItemSprite;
@property (nonatomic, strong)ItemSprite *foregroundItemSprite;

-(void)update;


@end
