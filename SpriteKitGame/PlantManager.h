//
//  PlantManager.h
//  SpriteKitGame
//
//  Created by Skyler Lauren on 1/5/15.
//  Copyright (c) 2015 Sky Mist Development. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Plant.h"

@interface PlantManager : NSObject

//+(SKSpriteNode *)seedSpriteForPlant:(NSString *)plant;
+(Plant *)plantforName:(NSString *)plantName;

@end
