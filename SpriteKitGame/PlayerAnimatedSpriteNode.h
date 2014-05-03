//
//  PlayerAnimatedSpriteNode.h
//  SpriteKitGame
//
//  Created by Skyler Lauren on 12/30/14.
//  Copyright (c) 2014 Sky Mist Development. All rights reserved.
//

#import "AnimatedSpriteNode.h"
#import "Player.h"

@interface PlayerAnimatedSpriteNode : AnimatedSpriteNode

@property (nonatomic, strong)Player *player;

-(void)equipItemWithName:(NSString *)name;
-(id)initWithPlayer:(Player *)player;

@end
