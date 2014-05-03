//
//  Map.h
//  SpriteKitGame
//
//  Created by Skyler Lauren on 1/15/15.
//  Copyright (c) 2015 Sky Mist Development. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Player.h"

typedef struct {
    NSInteger x;
    NSInteger y;
} MapIndex;

@protocol MapDelegate <NSObject>

-(void)loadMapWithName:(NSString *)mapName;
-(void)setMapTime:(float)time;

@end

@interface Map : NSObject

@property (nonatomic)NSInteger tileWidth;

@property (nonatomic)NSInteger mapWidth;
@property (nonatomic)NSInteger mapHeight;

@property (nonatomic, strong)NSArray *mapTiles;
@property (nonatomic, strong)NSArray *impassableArray;
@property (nonatomic, strong)Player *player;
@property (nonatomic)CGPoint outlinePosition;

@property (nonatomic)float currentTime;

@property (nonatomic)BOOL updateTime;
@property (nonatomic)BOOL canPickUp;

@property (nonatomic, strong)NSMutableArray *dirtyIndexes;

@property (weak)id <MapDelegate> delegate;

-(id)initWithFileName:(NSString *)fileName;

-(void)updateForNewDay;
-(void)update:(float)dt;

-(void)primaryButtonPressedForPlayer:(Player *)player;
-(void)secondaryButtonPressedForPlayer:(Player *)player;
-(void)actionButtonPressedForPlayer:(Player *)player;




@end
