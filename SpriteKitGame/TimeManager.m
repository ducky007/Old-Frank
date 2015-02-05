//
//  TimeManager.m
//  SpriteKitGame
//
//  Created by Skyler Lauren on 2/9/15.
//  Copyright (c) 2015 Sky Mist Development. All rights reserved.
//

#import "TimeManager.h"

@implementation TimeManager

+(TimeManager *)sharedManager
{
    static TimeManager *_sharedInstance = nil;
    
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[TimeManager alloc] init];
    });
    
    return _sharedInstance;
}

-(id)init{
    self = [super init];
    
        self.time = 360;
    
    return self;
}

-(void)addTime:(float)dt
{
    self.time += (dt *1);
    
    if (self.time > 1440)
    {
        self.time = 0;
    }
    
    if ((self.time >= 0 && self.time < 360) ||
        (self.time >= 1200))
    {
        self.isNight = YES;
    }
    else
    {
        self.isNight = NO;
    }
}

- (NSString *)timeFormatted:(int)totalSeconds
{
    
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    
    if (minutes > 12)
    {
        minutes = minutes-12;
    }
    else if (minutes == 0)
    {
        minutes = 12;
    }
    
    NSString *AMPM;
    
    if (totalSeconds >= 720)
    {
        AMPM = @"PM";
    }
    else
    {
        AMPM = @"AM";
    }
    
    return [NSString stringWithFormat:@"%02d:%02d %@", minutes, seconds, AMPM];
}


-(NSString *)timeStringValue
{
    return [self timeFormatted:self.time];
}


@end
