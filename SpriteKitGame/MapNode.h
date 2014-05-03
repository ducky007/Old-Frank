//
//  MapNode.h
//  SpriteKitGame
//
//  Created by Skyler Lauren on 5/3/14.
//  Copyright (c) 2014 Sky Mist Development. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "PlayerAnimatedSpriteNode.h"
#import "Map.h"



@interface MapNode : SKNode

@property (nonatomic, strong)Map *map;

-(id)initWithMap:(Map *)map;

-(void)update;

@property (nonatomic, strong)AnimatedSpriteNode *animatedSpriteNode;

@end
