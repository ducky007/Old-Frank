//
//  TextureLoader.m
//  Old Frank
//
//  Created by Skyler Lauren on 3/14/15.
//  Copyright (c) 2015 Sky Mist Development. All rights reserved.
//

#import "TextureLoader.h"


@interface TextureLoader ()

@property (nonatomic, strong)NSMutableDictionary *textures;

@end

@implementation TextureLoader

-(id)init
{
    self = [super init];
    
    self.textures = [[NSMutableDictionary alloc]init];
    
    return self;
}

-(SKTexture *)getTextureForName:(NSString *)name
{
    
    SKTexture *texture = self.textures[name];
    
    if (!texture)
    {
        texture = [SKTexture textureWithImageNamed:name];
        texture.filteringMode = SKTextureFilteringNearest;
        [self.textures setObject:texture forKey:name];
    }
    
    return texture;
}

@end
