//
//  AnimatedSpriteNode.h
//  SpriteKitGame
//
//  Created by Skyler Lauren on 5/2/14.
//  Copyright (c) 2014 Sky Mist Development. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>


@interface AnimatedSpriteNode : SKSpriteNode

@property (nonatomic, strong)NSArray *walkingArray;

@property (nonatomic)NSInteger rows;
@property (nonatomic)NSInteger columns;

-(instancetype)initWithImageNamed:(NSString *)imageName withWidth:(NSInteger)width withHeight:(NSInteger)height;

-(void)update;


@end
