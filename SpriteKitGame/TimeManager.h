//
//  TimeManager.h
//  SpriteKitGame
//
//  Created by Skyler Lauren on 2/9/15.
//  Copyright (c) 2015 Sky Mist Development. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TimeManager : NSObject

@property (nonatomic)float time;
@property (nonatomic)BOOL isNight;

+(TimeManager *)sharedManager;

-(void)addTime:(float)dt;
-(NSString *)timeStringValue;

@end
