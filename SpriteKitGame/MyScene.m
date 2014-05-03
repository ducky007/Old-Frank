//
//  MyScene.m
//  SpriteKitGame
//
//  Created by Skyler Lauren on 5/2/14.
//  Copyright (c) 2014 Sky Mist Development. All rights reserved.
//

#import "MyScene.h"
#import "PlayerAnimatedSpriteNode.h"
#import "MapNode.h"
#import "GameViewController.h"
#import "Player.h"
#import "ItemManager.h"
#import "Map.h" 
#import "ButtonSprite.h"
#import "AnalogSpriteNode.h"
#import "ButtonControlPanelNode.h"

@interface MyScene ()<MapDelegate, ButtonSpriteDelegate, ButtonControlPanelNodeDelegate>

@property (nonatomic)CFTimeInterval lastUpdate;

@property (nonatomic, strong)UIView *hudView;
@property (nonatomic, strong)UITouch *firstTouch;

//Analog Controller
//@property (nonatomic, strong)UIImageView *controllerContainer;
//@property (nonatomic, strong)UIImageView *joyStick;

@property (nonatomic, strong)MapNode *mapNode;
@property (nonatomic, strong)Map *map;

//buttons
@property (nonatomic, strong)AnalogSpriteNode *analogSpriteNode;
@property (nonatomic, strong)ButtonControlPanelNode *buttonControlPanelNode;

//action view


@property (nonatomic, strong)ButtonSprite *inventoryButton;

@property (nonatomic, strong)ButtonSprite *primaryButton;
@property (nonatomic, strong)SKSpriteNode *primaryButtonOverlay;

@property (nonatomic, strong)ButtonSprite *secondaryButton;
@property (nonatomic, strong)SKSpriteNode *secondaryButtonOverlay;

@property (nonatomic, strong)ButtonSprite *actionButton;
@property (nonatomic, strong)SKSpriteNode *actionButtonOverlay;

//hud
@property (nonatomic, strong)SKNode *hudNode;
@property (nonatomic, strong)SKSpriteNode *energyBar;
@property (nonatomic, strong)SKSpriteNode *healthBar;

@property (nonatomic, strong)SKSpriteNode *nightHud;

@property (nonatomic, strong)SKLabelNode *timeLabel;

@property (nonatomic)float time;
@property (nonatomic)BOOL hasUpdated;
@property (nonatomic)BOOL transitioning;

@property (nonatomic, strong)NSMutableDictionary *textures;

@end

@implementation MyScene

#pragma mark - Init and Lifecycle

-(void)didMoveToView:(SKView *)view
{
    
    
    self.textures = [[NSMutableDictionary alloc]init];
    
    self.physicsWorld.gravity = CGVectorMake(0, 0);
    
    
    self.map = [[Map alloc]initWithFileName:@"farm.json"];
    self.map.delegate = self;
    
    Player *player = [[Player alloc]init];
    self.map.player = player;

    self.mapNode = [[MapNode alloc]initWithMap:self.map];
    [self addChild:self.mapNode];

    self.hudNode = [[SKNode alloc]init];
    [self addChild:self.hudNode];
    
    self.analogSpriteNode = [[AnalogSpriteNode alloc]init];
    self.analogSpriteNode.position = CGPointMake(self.analogSpriteNode.size.width/2, self.analogSpriteNode.size.height/2);
    [self.hudNode addChild:self.analogSpriteNode];
    
//    self.buttonControlPanelNode = [[ButtonControlPanelNode alloc]init];
//    self.buttonControlPanelNode.position = CGPointMake(self.scene.size.width-self.buttonControlPanelNode.size.width/2, self.buttonControlPanelNode.size.height/2);
//    self.buttonControlPanelNode.delegate = self;
//    [self.hudNode addChild:self.buttonControlPanelNode];
    
    self.nightHud = [SKSpriteNode spriteNodeWithColor:[SKColor blackColor] size:self.view.frame.size];
    self.nightHud.size = self.view.frame.size;
    self.nightHud.position = CGPointMake(self.scene.size.width/2, self.scene.size.height/2);
    
    [self.hudNode addChild:self.nightHud];
    
    self.time = 360;
    self.time = 1140;
    
    self.primaryButton = [[ButtonSprite alloc]initWithTexture:[self getTextureForName:@"primary_background"]];
    self.primaryButton.delegate = self;
    self.primaryButton.anchorPoint = CGPointMake(0, 0);
    self.primaryButton.position  = CGPointMake(self.scene.size.width-self.primaryButton.size.width-10, 10);// 100;
    self.primaryButton.userInteractionEnabled = YES;
    
    [self.hudNode addChild:self.primaryButton];
    
    self.primaryButtonOverlay = [SKSpriteNode spriteNodeWithColor:[UIColor clearColor] size:CGSizeMake(self.primaryButton.size.width*.75, self.primaryButton.size.width*.75)];
    self.primaryButtonOverlay.anchorPoint = CGPointMake(0, 0);
    self.primaryButtonOverlay.position = CGPointMake((self.primaryButton.size.width-self.primaryButtonOverlay.size.width)/2, (self.primaryButton.size.height-self.primaryButtonOverlay.size.height)/2);

    [self.primaryButton addChild:self.primaryButtonOverlay];
    
    self.secondaryButton = [[ButtonSprite alloc]initWithTexture:[self getTextureForName:@"secondary_background"]];
    self.secondaryButton.delegate = self;
    self.secondaryButton.anchorPoint = CGPointMake(0, 0);
    self.secondaryButton.position  = CGPointMake(self.scene.size.width-self.secondaryButton.size.width-10, self.primaryButton.size.height+10);// 100;
    self.secondaryButton.zPosition = 101;

    self.secondaryButton.userInteractionEnabled = YES;
    
    [self.hudNode addChild:self.secondaryButton];
    
    self.secondaryButtonOverlay = [SKSpriteNode spriteNodeWithColor:[UIColor clearColor] size:CGSizeMake(self.secondaryButton.size.width, self.secondaryButton.size.width)];
    self.secondaryButtonOverlay.zPosition = 102;

    self.secondaryButtonOverlay.anchorPoint = CGPointMake(0, 0);
    
    [self.secondaryButton addChild:self.secondaryButtonOverlay];
    
    self.actionButton = [[ButtonSprite alloc]initWithTexture:[self getTextureForName:@"secondary_background"]];
    self.actionButton.delegate = self;
    self.actionButton.anchorPoint = CGPointMake(0, 0);
    self.actionButton.position  = CGPointMake(self.scene.size.width-self.actionButton.size.width-10, self.primaryButton.size.height+10);// 100;
    self.actionButton.zPosition = 110;
    self.actionButton.userInteractionEnabled = YES;
    
    [self.hudNode addChild:self.actionButton];
    
    self.actionButtonOverlay = [SKSpriteNode spriteNodeWithColor:[UIColor clearColor] size:CGSizeMake(self.actionButton.size.width, self.secondaryButton.size.width)];
    self.actionButton.anchorPoint = CGPointMake(0, 0);
    
    [self.secondaryButton addChild:self.actionButtonOverlay];

    
    self.inventoryButton = [[ButtonSprite alloc]initWithImageNamed:@"backpack"];
    self.inventoryButton.delegate = self;
    self.inventoryButton.anchorPoint = CGPointMake(0, 0);
    self.inventoryButton.position  = CGPointMake(10, self.scene.size.height/2);// 100;
    self.inventoryButton.userInteractionEnabled = YES;
    self.inventoryButton.zPosition = 105;
    
    [self.hudNode addChild:self.inventoryButton];

    
    self.timeLabel = [SKLabelNode labelNodeWithText:@"time"];
    self.timeLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    self.timeLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeTop;
    self.timeLabel.fontSize = 14;
    self.timeLabel.position = CGPointMake(self.frame.size.width/2, self.frame.size.height-5);
    [self.hudNode addChild:self.timeLabel];
    

    SKTexture *texture = [SKTexture textureWithImageNamed:@"energy"];
    texture.filteringMode = SKTextureFilteringNearest;
    self.energyBar = [SKSpriteNode spriteNodeWithTexture:texture];
    self.energyBar.anchorPoint = CGPointMake(0, 0);
    self.energyBar.centerRect = CGRectMake(.4, .2, .4, .2);
    self.energyBar.xScale = 10;
    self.energyBar.alpha = .6;

    self.energyBar.position  = CGPointMake(0, self.view.frame.size.height-10-5);// 100;
    [self.hudNode addChild:self.energyBar];

    texture = [SKTexture textureWithImageNamed:@"health_bar"];
    texture.filteringMode = SKTextureFilteringNearest;
    self.healthBar = [SKSpriteNode spriteNodeWithTexture:texture];
    self.healthBar.anchorPoint = CGPointMake(0, 0);
    self.healthBar.centerRect = CGRectMake(.4, .2, .4, .2);
    self.healthBar.xScale = 10;
    self.healthBar.alpha = .6;
    self.healthBar.position  = CGPointMake(0, self.view.frame.size.height-10-17);// 100;

    [self.hudNode addChild:self.healthBar];
    
    self.hudNode.zPosition = 100;

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


-(void)primaryButtonPressed
{
    if (!self.map.player.equippedTool)
    {
        return;
    }
    
    [self.map primaryButtonPressedForPlayer:self.map.player];
    
}

-(void)secondaryButtonPressed
{
    if (!self.map.player.equippedItem)
    {
        return;
    }

    [self.map secondaryButtonPressedForPlayer:self.map.player];

}

-(void)actionButtonPressed
{
    [self.map actionButtonPressedForPlayer:self.map.player];
}

#pragma mark - Touches




#pragma mark - Update

-(void)didSimulatePhysics
{
    
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


-(void)update:(CFTimeInterval)currentTime
{
    if (!self.lastUpdate)
    {
        self.lastUpdate = currentTime;
        return;
    }
    
    if (self.map.player.equippedTool)
    {
        self.primaryButtonOverlay.texture = [self getTextureForName:self.map.player.equippedTool.itemName];
    }
    else
    {
        self.primaryButtonOverlay.texture = nil;
    }
    
    if (self.map.player.equippedItem)
    {
        self.secondaryButtonOverlay.texture = [self getTextureForName:self.map.player.equippedItem.itemName];
    }
    else
    {
        self.secondaryButtonOverlay.texture = nil;
    }
    
    CGPoint moveVelocity = [self.analogSpriteNode velocity];
    
    float timeBetweenUpdates = currentTime-self.lastUpdate;
    
    //time stuff
    if ([self.map updateTime])
    {
        self.time += (timeBetweenUpdates *10);
        
        if (self.time > 1440)
        {
            self.time = 0;
        }
        
        if ((self.time >= 0 && self.time < 360) ||
            (self.time >= 1200))
        {
            self.nightHud.alpha = .4;
        }
        else
        {
            self.nightHud.alpha = 0;
        }
        
        if (!self.hasUpdated && (self.time > 360 && self.time < 370))
        {
            [self.map updateForNewDay];
            self.hasUpdated = YES;
        }
        else if (!(self.time > 360 && self.time < 370))
        {
            self.hasUpdated = NO;
        }
    }
    
    self.timeLabel.text = [NSString stringWithFormat:@"%@", [self timeFormatted:self.time]];
    
    if (!self.transitioning)
    {
        self.map.player.moveVelocity = moveVelocity;
        
        [self.map update:timeBetweenUpdates];
    }
    
    [self.mapNode update];
    
    [self.map.dirtyIndexes removeAllObjects];

    
    self.mapNode.position = CGPointMake(-self.mapNode.animatedSpriteNode.position.x+self.scene.size.width/2, -self.mapNode.animatedSpriteNode.position.y+self.scene.size.height/2);
    
    //keep map from going off screen
    CGPoint position = self.mapNode.position;
    
    if (position.x > self.map.tileWidth/2)
        position.x = self.map.tileWidth/2;
    
    
    if (position.y > self.map.tileWidth/2)
        position.y = self.map.tileWidth/2;
    
    if (position.y < -self.map.mapHeight*self.map.tileWidth+self.scene.scene.size.height+self.map.tileWidth/2)
        position.y = -self.map.mapHeight*self.map.tileWidth+self.scene.scene.size.height+self.map.tileWidth/2;
    if (position.x < -self.map.mapWidth*self.map.tileWidth+self.scene.scene.size.width+self.map.tileWidth/2)
        position.x = -self.map.mapWidth*self.map.tileWidth+self.scene.scene.size.width+self.map.tileWidth/2;
    
    self.mapNode.position = CGPointMake((int)(position.x), (int)(position.y));

    self.lastUpdate = currentTime;
    
    self.actionButton.hidden = !self.map.canPickUp;
    
    self.energyBar.xScale = (self.map.player.energy/self.map.player.maxEnergy) * 10;
    
    self.primaryButton.hidden = !(self.map.player.equippedTool);
    self.secondaryButton.hidden = !(self.map.player.equippedItem);
}

#pragma mark - MapNodeDelegate


-(void)loadMapWithName:(NSString *)mapName
{
    self.transitioning = YES;
    SKAction *fadOut = [SKAction fadeAlphaTo:0 duration:.25];
    
    SKAction *customAction = [SKAction customActionWithDuration:0 actionBlock:^(SKNode *node, CGFloat elapsedTime) {
        
        self.nightHud.alpha = 0;
        [node removeFromParent];
        
        Map *map = [[Map alloc]initWithFileName:[NSString stringWithFormat:@"%@.json",mapName]];
        map.player = self.map.player;

        MapNode *mapNode = [[MapNode alloc]initWithMap:map];
        mapNode.alpha = 0;
        
        self.map = map;
        self.mapNode = mapNode;

        [self addChild:mapNode];
        
        SKAction *fadin = [SKAction fadeAlphaTo:1 duration:.25];
        SKAction *doneFading = [SKAction customActionWithDuration:0 actionBlock:^(SKNode *node, CGFloat elapsedTime) {
            
            self.map.delegate = self;
            self.transitioning = NO;

        }];
        
        [mapNode runAction:[SKAction sequence:@[fadin, doneFading]]];

    }];
    
    [self.mapNode runAction:[SKAction sequence:@[fadOut, customAction]]];
    
}

-(void)setMapTime:(float)time
{
    self.time = time;
}

-(void)buttonSpritePressed:(ButtonSprite *)buttonSprite
{
    NSLog(@"delegate touch");
   
    if (buttonSprite == self.inventoryButton)
    {
        [self inventoryButtonPressed];
    }
    else if (buttonSprite == self.primaryButton)
    {
        [self primaryButtonPressed];
    }
    else if (buttonSprite == self.actionButton)
    {
        [self actionButtonPressed];
    }
    else if (buttonSprite == self.secondaryButton)
    {
        [self secondaryButtonPressed];
    }
}

-(void)inventoryButtonPressed
{
    [self.gameViewController showInventoryViewForPlayer:self.map.player];
}

-(void)selectedControlButton:(SKSpriteNode *)controlButton
{
    if (controlButton == self.buttonControlPanelNode.primaryButton)
    {
        [self primaryButtonPressed];
    }
    else if (controlButton == self.buttonControlPanelNode.secondaryButton)
    {
        [self secondaryButtonPressed];
    }
    else if (controlButton == self.buttonControlPanelNode.inventoryButton)
    {
        [self inventoryButtonPressed];
    }
    else if (controlButton == self.buttonControlPanelNode.actionButton)
    {
        [self actionButtonPressed];
    }
    else if (controlButton == self.buttonControlPanelNode.cancelButton)
    {
        
    }
    
    
}

@end
