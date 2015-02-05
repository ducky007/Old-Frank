//
//  MapManager.h
//  SpriteKitGame
//
//  Created by Skyler Lauren on 2/8/15.
//  Copyright (c) 2015 Sky Mist Development. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Map.h"

@interface MapManager : NSObject

+ (Map *)mapForName:(NSString *)mapName;

@end
