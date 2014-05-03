//
//  PlantManager.m
//  SpriteKitGame
//
//  Created by Skyler Lauren on 1/5/15.
//  Copyright (c) 2015 Sky Mist Development. All rights reserved.
//

#import "PlantManager.h"

@implementation PlantManager

//+(SKSpriteNode *)seedSpriteForPlant:(NSString *)plant
//{
//    NSString *plantSeeds = [NSString stringWithFormat:@"%@_seeds",plant];
//    SKTexture *texture = [SKTexture textureWithImageNamed:plantSeeds];
//    texture.filteringMode = SKTextureFilteringNearest;
//
//    SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithTexture:texture];
//    sprite.name = plantSeeds;
//    
//    return sprite;
//}

+(Plant *)plantforName:(NSString *)plantName
{
    Plant *plant;
    
    if ([plantName isEqualToString:@"corn"])
    {
        plant = [[Plant alloc]initWithName:plantName stage1:1 stage2:1 stage3:1];
    }
    else if ([plantName isEqualToString:@"pumpkin"])
    {
        plant = [[Plant alloc]initWithName:plantName stage1:1 stage2:3 stage3:4];
    }
    
    return plant;
}

@end
