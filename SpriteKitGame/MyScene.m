//
//  MyScene.m
//  SpriteKitGame
//
//  Created by Skyler Lauren on 5/2/14.
//  Copyright (c) 2014 Sky Mist Development. All rights reserved.
//

#import "MyScene.h"
#import "MapNode.h"
#import "Player.h"
#import "Map.h"
#import "ButtonSprite.h"
#import "AnalogSpriteNode.h"
#import "InventoryController.h"
#import "MapManager.h"
#import "TimeManager.h"
#import "TextNode.h"
#import "FoodStandController.h"
#import "SMDTextureLoader.h"

@interface MyScene ()<MapDelegate, ButtonSpriteDelegate, TextNodeDelegate, MapNodeDelegate, FoodStandControllerDelegate>

@property (nonatomic)CFTimeInterval lastUpdate;

@property (nonatomic, strong)InventoryController *inventoryController;
@property (nonatomic, strong)FoodStandController *foodStandController;

@property (nonatomic, strong)MapNode *mapNode;
@property (nonatomic, strong)Map *map;

@property (nonatomic, strong)AnalogSpriteNode *analogSpriteNode;

@property (nonatomic, strong)ButtonSprite *inventoryButton;

@property (nonatomic, strong)ButtonSprite *primaryButton;
@property (nonatomic, strong)SKSpriteNode *primaryButtonOverlay;

@property (nonatomic, strong)ButtonSprite *actionButton;
@property (nonatomic, strong)SKSpriteNode *actionButtonOverlay;

//hud
@property (nonatomic, strong)SKNode *hudNode;
@property (nonatomic, strong)SKSpriteNode *energyBar;
@property (nonatomic, strong)SKSpriteNode *healthBar;

@property (nonatomic, strong)SKSpriteNode *nightHud;

@property (nonatomic, strong)SKLabelNode *timeLabel;

@property (nonatomic)BOOL transitioning;

@property (nonatomic, strong)TextNode *textNode;

@property (nonatomic)CGPoint velocity;


@property (nonatomic, strong)SMDTextureLoader *textureLoader;

@end

@implementation MyScene

#pragma mark - Init and Lifecycle

-(void)didMoveToView:(SKView *)view
{

    self.textureLoader = [[SMDTextureLoader alloc]init];
    
    self.physicsWorld.gravity = CGVectorMake(0, 0);
    
    
    self.map = [MapManager mapForName:@"farm"];

    self.map.delegate = self;
    
    Player *player = [[Player alloc]init];
    self.map.player = player;

    self.mapNode = [[MapNode alloc]initWithMap:self.map];
    self.mapNode.delegate = self;
    [self addChild:self.mapNode];

    self.hudNode = [[SKNode alloc]init];
    [self addChild:self.hudNode];
    
#if TARGET_OS_IPHONE
    
    self.analogSpriteNode = [[AnalogSpriteNode alloc]init];
    self.analogSpriteNode.position = CGPointMake(self.analogSpriteNode.size.width/2, self.analogSpriteNode.size.height/2);
    [self.hudNode addChild:self.analogSpriteNode];

#else

#endif
    
    
  
    
    self.nightHud = [SKSpriteNode spriteNodeWithColor:[SKColor blackColor] size:self.view.frame.size];
    self.nightHud.size = self.view.frame.size;
    self.nightHud.position = CGPointMake(self.scene.size.width/2, self.scene.size.height/2);
    
    [self.hudNode addChild:self.nightHud];
    

    self.primaryButton = [[ButtonSprite alloc]initWithTexture:[self.textureLoader getTextureForName:@"primary_background"]];
    self.primaryButton.delegate = self;
    self.primaryButton.anchorPoint = CGPointMake(0, 0);
    self.primaryButton.position  = CGPointMake(self.scene.size.width-self.primaryButton.size.width-10, 10);// 100;
    self.primaryButton.userInteractionEnabled = YES;
    self.primaryButton.zPosition = 1;
    
    [self.hudNode addChild:self.primaryButton];
    
    self.primaryButtonOverlay = [SKSpriteNode spriteNodeWithColor:[SKColor clearColor] size:CGSizeMake(self.primaryButton.size.width*.75, self.primaryButton.size.width*.75)];
    self.primaryButtonOverlay.anchorPoint = CGPointMake(0, 0);
    self.primaryButtonOverlay.position = CGPointMake((self.primaryButton.size.width-self.primaryButtonOverlay.size.width)/2, (self.primaryButton.size.height-self.primaryButtonOverlay.size.height)/2);
    self.primaryButtonOverlay.zPosition = 2;

    [self.primaryButton addChild:self.primaryButtonOverlay];
    
    self.actionButton = [[ButtonSprite alloc]initWithTexture:[self.textureLoader getTextureForName:@"secondary_background"]];
    self.actionButton.delegate = self;
    self.actionButton.anchorPoint = CGPointMake(0, 0);
    self.actionButton.position  = CGPointMake(self.scene.size.width-self.actionButton.size.width-10, self.primaryButton.size.height+10);// 100;
    self.actionButton.zPosition = 1;
    self.actionButton.userInteractionEnabled = YES;
    
    [self.hudNode addChild:self.actionButton];
    
    self.actionButtonOverlay = [SKSpriteNode spriteNodeWithColor:[SKColor clearColor] size:CGSizeMake(self.actionButton.size.width, self.actionButton.size.width)];
    self.actionButton.anchorPoint = CGPointMake(0, 0);
    self.actionButtonOverlay.anchorPoint = CGPointMake(0, 0);
    self.actionButtonOverlay.zPosition = 1;

    [self.actionButton addChild:self.actionButtonOverlay];

#if TARGET_OS_IPHONE
    self.inventoryButton = [[ButtonSprite alloc] initWithTexture:[self.textureLoader getTextureForName:@"backpack"]];
    self.inventoryButton.delegate = self;
    self.inventoryButton.anchorPoint = CGPointMake(0, 0);
    self.inventoryButton.position  = CGPointMake(10, self.scene.size.height/2);// 100;
    self.inventoryButton.userInteractionEnabled = YES;
    self.inventoryButton.zPosition = 5;
    
    [self.hudNode addChild:self.inventoryButton];
#endif

    
    self.timeLabel = [SKLabelNode labelNodeWithText:@"time"];
    self.timeLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    self.timeLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeTop;
    self.timeLabel.fontSize = 14;
    self.timeLabel.position = CGPointMake(self.frame.size.width/2, self.frame.size.height-5);
    [self.hudNode addChild:self.timeLabel];
    

    self.energyBar = [SKSpriteNode spriteNodeWithTexture:[self.textureLoader getTextureForName:@"energy"]];
    self.energyBar.anchorPoint = CGPointMake(0, 0);
    self.energyBar.centerRect = CGRectMake(.4, .2, .4, .2);
    self.energyBar.xScale = 10;
    self.energyBar.alpha = .6;

    self.energyBar.position  = CGPointMake(0, self.view.frame.size.height-10-5);// 100;
    [self.hudNode addChild:self.energyBar];

    self.healthBar = [SKSpriteNode spriteNodeWithTexture:[self.textureLoader getTextureForName:@"health_bar"]];
    self.healthBar.anchorPoint = CGPointMake(0, 0);
    self.healthBar.centerRect = CGRectMake(.4, .2, .4, .2);
    self.healthBar.xScale = 10;
    self.healthBar.alpha = .6;
    self.healthBar.position  = CGPointMake(0, self.view.frame.size.height-10-17);// 100;

    [self.hudNode addChild:self.healthBar];
    
    self.hudNode.zPosition = 10;
   
}

-(void)primaryButtonPressed
{
    if (!self.map.player.equippedTool)
    {
        return;
    }
    
    [self.map primaryButtonPressedForPlayer:self.map.player];
    
}

-(void)actionButtonPressed
{
    [self.map actionButtonPressedForPlayer:self.map.player];
}

#if TARGET_OS_IPHONE

#else

- (void)handleKeyEvent:(NSEvent *)event keyDown:(BOOL)downOrUp
{
    if(event.isARepeat)
        return;
    
    if(self.inventoryController.inventorySpriteView.parent)
    {
        [self.inventoryController handleEvenet:event isDown:downOrUp];
        return;
    }
    else if (self.textNode.parent)
    {
        [self.textNode  handleEvenet:event isDown:downOrUp];
        return;
    }
    
    float speed = .6;
    
    
    // First check the arrow keys since they are on the numeric keypad.
    if ([event modifierFlags] & NSNumericPadKeyMask) { // arrow keys have this mask
        NSString *theArrow = [event charactersIgnoringModifiers];
        unichar keyChar = 0;
        if ([theArrow length] == 1) {
            keyChar = [theArrow characterAtIndex:0];
            switch (keyChar) {
                case NSUpArrowFunctionKey:
                    if (downOrUp)
                    {
                        self.velocity = CGPointMake(self.velocity.x, speed);
                    }
                    else
                    {
                        self.velocity = CGPointMake(self.velocity.x, 0);
                    }

                    break;
                case NSLeftArrowFunctionKey:
                    if (downOrUp)
                    {
                        self.velocity = CGPointMake(-speed, self.velocity.y);
                    }
                    else
                    {
                        self.velocity = CGPointMake(0, self.velocity.y);
                    }
                    break;
                case NSRightArrowFunctionKey:
                    if (downOrUp)
                    {
                        self.velocity = CGPointMake(speed, self.velocity.y);
                    }
                    else
                    {
                         self.velocity = CGPointMake(0, self.velocity.y);
                    }
                
                    break;
                case NSDownArrowFunctionKey:
                    if (downOrUp)
                    {
                        self.velocity = CGPointMake(self.velocity.x, -speed);
                    }
                    else
                    {
                        self.velocity = CGPointMake(self.velocity.x, 0);
                    }
                    break;
            }
        }
    }
    
    
    // / (slash)
    if(event.keyCode == 44 && downOrUp)
    {
        [self actionButtonPressed];
    }
    
    //i
    if(event.keyCode == 34 && downOrUp)
    {
        [self inventoryButtonPressed];
    }
    
    //space
    if(event.keyCode == 49 && downOrUp)
    {
        [self.map primaryButtonPressedForPlayer:self.map.player];
    }
    
    //y
    if(event.keyCode == 16 && downOrUp && self.textNode.parent)
    {
        [self didSelectAnswer:@"yes" forTextNode:self.textNode];
    }
    //n
    else if(event.keyCode == 45 && downOrUp && self.textNode.parent)
    {
        [self didSelectAnswer:@"no" forTextNode:self.textNode];
    }
    
    
}

- (void)keyDown:(NSEvent *)event {
    [self handleKeyEvent:event keyDown:YES];
}

- (void)keyUp:(NSEvent *)event {
    [self handleKeyEvent:event keyDown:NO];
}

#endif

#pragma mark - Update

-(void)didSimulatePhysics
{
    
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
        self.primaryButtonOverlay.texture = [self.textureLoader getTextureForName:self.map.player.equippedTool.itemName];
    }
    else
    {
        self.primaryButtonOverlay.texture = nil;
    }
    
    
    
#if TARGET_OS_IPHONE
    self.velocity = [self.analogSpriteNode velocity];
#endif
    
    float timeBetweenUpdates = currentTime-self.lastUpdate;
    
    self.timeLabel.text = [[TimeManager sharedManager]timeStringValue];
        
    if (!self.transitioning)
    {
        self.map.player.moveVelocity = self.velocity;
        
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
    
    self.actionButton.hidden = !self.map.canUseActionButton;

    if (!self.map.canUseActionButton)
    {
        self.actionButton.zPosition = 1;
    }
    else
    {
        self.actionButton.zPosition = 5;
    }
    
    switch (self.map.actionButtonType)
    {
        case ActionButtonTypeNone:
            self.actionButtonOverlay.texture = nil;
            break;
            
        case ActionButtonTypeHarvest:
            self.actionButtonOverlay.texture = [self.textureLoader getTextureForName:@"harvest"];
            break;
        
        case ActionButtonTypeSleep:
            self.actionButtonOverlay.texture = [self.textureLoader getTextureForName:@"sleep"];
            break;
        case ActionButtonTypeOpen:
            self.actionButtonOverlay.texture = [self.textureLoader getTextureForName:@"unknown"];
            break;
        case ActionButtonTypeTalk:
            self.actionButtonOverlay.texture = [self.textureLoader getTextureForName:@"unknown"];
            break;
            
            
        default:
            break;
    }
    
    if (self.map.actionButtonType == ActionButtonTypeNone && self.map.player.equippedItem)
    {
        self.actionButtonOverlay.texture = [self.textureLoader getTextureForName:self.map.player.equippedItem.itemName];
    }
   
    
    self.energyBar.xScale = (self.map.player.energy/self.map.player.maxEnergy) * 10;
    
    self.primaryButton.hidden = !(self.map.player.equippedTool);
    
    if (self.map.actionButtonType == ActionButtonTypeNone && !self.map.player.equippedItem)
    {
        self.actionButton.hidden = YES;
    }
    else
    {
        self.actionButton.hidden = NO;
    }
    
    if ([[TimeManager sharedManager] isNight])
    {
        self.nightHud.alpha = .2;
    }
    else
    {
        self.nightHud.alpha = 0;
    }
}

#pragma mark - MapNodeDelegate


-(void)loadMapWithName:(NSString *)mapName
{
    self.transitioning = YES;
    SKAction *fadOut = [SKAction fadeAlphaTo:0 duration:.25];
    
    SKAction *customAction = [SKAction customActionWithDuration:0 actionBlock:^(SKNode *node, CGFloat elapsedTime) {
        
        self.nightHud.alpha = 0;
        [node removeFromParent];
        
        Map *map = [MapManager mapForName:mapName];
        
        map.player = self.map.player;

        MapNode *mapNode = [[MapNode alloc]initWithMap:map];
        mapNode.delegate = self;
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

-(void)displayDialog:(Dialog *)dialog withBlock:(DialogBlock)completion
{
    self.textNode = [[TextNode alloc]initWithSize:CGSizeMake(self.size.width*.6, self.size.height*.4) withDialog:dialog];
    self.textNode.position = CGPointMake(self.scene.size.width/2, -self.size.height*.4);
    self.textNode.zPosition = 100;
    self.textNode.delegate = self;
    self.textNode.dialogBlock = completion;
    [self addChild:self.textNode];

    SKAction *slideUP = [SKAction moveToY:0 duration:.5];
    SKAction *startTextAnimating = [SKAction customActionWithDuration:0 actionBlock:^(SKNode *node, CGFloat elapsedTime) {
        [self.textNode startAnimation];
    }];
    
    SKAction *sequence = [SKAction sequence:@[slideUP, startTextAnimating]];
    [self.textNode runAction:sequence];
}

-(void)launchProjectile:(Item *)projectile fromPoint:(CGPoint)startPoint toPoint:(CGPoint)endPoint
{
    [self.mapNode launchProjectile:projectile atPoint:startPoint toPoint:endPoint];
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
}

-(void)inventoryButtonPressed
{
    
    if (!self.inventoryController)
    {
        self.inventoryController = [[InventoryController alloc]initWithSize:self.size andPlayer:self.map.player];
    }
 
    if(!self.inventoryController.inventorySpriteView.parent)
    {
        [self.inventoryController updateViews];
        [self addChild:self.inventoryController.inventorySpriteView];
    }
    else
    {
        [self.inventoryController.inventorySpriteView removeFromParent];
    }
}

#pragma mark - MapNodeDelegate
-(void)doneWithProjectile:(Item *)projectile atPoint:(CGPoint)point
{
    [self.map doneWithProjectile:projectile atPoint:point];
}

-(void)showFoodStand:(FoodStand *)foodStand
{
    
    self.foodStandController = [[FoodStandController alloc]initWithSize:self.size withFoodStand:(FoodStand *)foodStand withPlayer:self.map.player];
    self.foodStandController.delegate = self;
    [self addChild:self.foodStandController.foodStandSpriteView];

}

#pragma mark - TextNodeDelegate

-(void)didSelectAnswer:(NSString *)answer forTextNode:(TextNode *)textNode
{

    SKAction *slideUP = [SKAction moveToY:-textNode.size.height duration:.5];
    SKAction *startTextAnimating = [SKAction customActionWithDuration:0 actionBlock:^(SKNode *node, CGFloat elapsedTime) {

        [node removeFromParent];
        
    }];
    
    SKAction *sequence = [SKAction sequence:@[slideUP, startTextAnimating]];
    [textNode runAction:sequence];
}

#pragma mark - FoodStandControllerDelegate

-(void)doneWithFoodStand:(FoodStand *)foodStand
{
    [self.mapNode updateFoodStand:foodStand];
}

@end
