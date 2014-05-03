//
//  Plant.m
//  SpriteKitGame
//
//  Created by Skyler Lauren on 1/5/15.
//  Copyright (c) 2015 Sky Mist Development. All rights reserved.
//

#import "Plant.h"

@implementation Plant

-(id)initWithName:(NSString *)plantName stage1:(NSInteger)stage1 stage2:(NSInteger)stage2 stage3:(NSInteger)stage3
{
    self = [super init];
    
    self.plantName = plantName;
    self.stage1Days = stage1;
    self.stage2Days = stage2;
    self.stage3Days = stage3;
    NSLog(@"PLANT NAME: %@", self.plantName);
    
    return self;
}

-(void)setDaysWatered:(NSInteger)daysWatered
{
    self.plantEntity.days_watered = @(daysWatered);
    _daysWatered = daysWatered;
}

-(void)setWatered:(BOOL)watered
{
    self.plantEntity.watered = @(watered);
    _watered = watered;
}

-(NSInteger)currentStage
{
    if (self.daysWatered >= (self.stage1Days + self.stage2Days + self.stage3Days))
    {
        self.readyToPick = YES;
        return 3;
    }
    else if (self.daysWatered >= (self.stage1Days + self.stage2Days))
    {
        return 2;
    }
    else if (self.daysWatered >= self.stage1Days)
    {
        return 1;
    }
    else
    {
        return 0;
    }
}

@end
