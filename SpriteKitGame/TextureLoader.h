//
//  TextureLoader.h
//  Old Frank
//
//  Created by Skyler Lauren on 3/14/15.
//  Copyright (c) 2015 Sky Mist Development. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>

@interface TextureLoader : NSObject

-(SKTexture *)getTextureForName:(NSString *)name;

@end
