//
//  FoodStandNode.m
//  Old Frank
//
//  Created by Skyler Lauren on 3/11/15.
//  Copyright (c) 2015 Sky Mist Development. All rights reserved.
//

#import "FoodStandNode.h"
#import "ButtonSprite.h"
#import "DragItemButtonSprite.h"

@interface FoodStandNode ()<ItemButtonSpriteDelegate, ButtonSpriteDelegate>

@property (nonatomic, strong)NSMutableDictionary *textures;
@property (nonatomic, strong)SKSpriteNode *inventoryItemContainer;
@property (nonatomic, strong)Player *player;
@property (nonatomic, strong)NSMutableArray *inventoryButtons;
@property (nonatomic, strong)ButtonSprite *closeButtonSprite;


@end

@implementation FoodStandNode

-(id)initWithSize:(CGSize)size withPlayer:(Player *)player;
{
    self = [super init];
    
    self.zPosition = 20;
    self.player = player;

    self.position = CGPointMake(size.width/2, size.height/2);
    SKSpriteNode *background = [SKSpriteNode spriteNodeWithColor:[SKColor whiteColor] size:size];
    [self addChild:background];

    
    NSInteger positionX = 0;
    NSInteger positionY = 0;
    
    
    SKSpriteNode *foodStandSprite = [SKSpriteNode spriteNodeWithTexture:[self getTextureForName:@"foodstand_1"]];
    foodStandSprite.position = CGPointMake(positionX, positionY);
    [self addChild:foodStandSprite];
    
    positionX += foodStandSprite.size.width;
    
    foodStandSprite = [SKSpriteNode spriteNodeWithTexture:[self getTextureForName:@"foodstand_2"]];
    foodStandSprite.position = CGPointMake(positionX, positionY);
    [self addChild:foodStandSprite];
    
    positionX += foodStandSprite.size.width;

    
    foodStandSprite = [SKSpriteNode spriteNodeWithTexture:[self getTextureForName:@"foodstand_3"]];
    foodStandSprite.position = CGPointMake(positionX, positionY);
    [self addChild:foodStandSprite];
    
    positionX -= foodStandSprite.size.width*2;
    positionY -= foodStandSprite.size.height;

    
    foodStandSprite = [SKSpriteNode spriteNodeWithTexture:[self getTextureForName:@"foodstand_4"]];
    foodStandSprite.position = CGPointMake(positionX, positionY);
    [self addChild:foodStandSprite];
    
    positionX += foodStandSprite.size.width;

    
    foodStandSprite = [SKSpriteNode spriteNodeWithTexture:[self getTextureForName:@"foodstand_5"]];
    foodStandSprite.position = CGPointMake(positionX, positionY);
    [self addChild:foodStandSprite];
    
    positionX += foodStandSprite.size.width;
    
    foodStandSprite = [SKSpriteNode spriteNodeWithTexture:[self getTextureForName:@"foodstand_6"]];
    foodStandSprite.position = CGPointMake(positionX, positionY);
    [self addChild:foodStandSprite];
    
    
    
    self.inventoryItemContainer = [[SKSpriteNode alloc]initWithColor:[SKColor greenColor] size:CGSizeMake(5*32, 8*32)];
    self.inventoryItemContainer.anchorPoint = CGPointMake(0, 1);
    
    NSInteger diff = (size.height-self.inventoryItemContainer.size.height)/2;
    
    self.inventoryItemContainer.position = CGPointMake(-size.width/2+32, size.height/2-diff);
    [self addChild:self.inventoryItemContainer];
    [self updateViews];

    NSInteger padding = 10;
    
    self.closeButtonSprite = [ButtonSprite spriteNodeWithColor:[SKColor redColor] size:CGSizeMake(32, 32)];
    self.closeButtonSprite.delegate = self;
    self.closeButtonSprite.zPosition = 10;
    self.closeButtonSprite.position = CGPointMake(size.width/2-self.closeButtonSprite.size.width/2-padding, size.height/2-self.closeButtonSprite.size.height/2 -padding);
    self.closeButtonSprite.userInteractionEnabled = YES;
    [self addChild:self.closeButtonSprite];
    
    return self;
}

-(void)updateViews
{
    
    for (SKSpriteNode *sprite in self.inventoryItemContainer.children)
    {
        [sprite removeFromParent];
    }
    NSInteger x = 0;
    NSInteger y = 0;
    
    NSInteger i = 0;
    
    self.inventoryButtons = [[NSMutableArray alloc]init];
    
    for (Item *item in self.player.inventory)
    {
        DragItemButtonSprite *itemButtonSprite = [[DragItemButtonSprite alloc]initWithItem:item];
        itemButtonSprite.position = CGPointMake(x+itemButtonSprite.size.width/2, y-itemButtonSprite.size.height/2);
        itemButtonSprite.delegate = self;
        [self.inventoryItemContainer addChild:itemButtonSprite];
        x += 32;
        
        if (x >= self.inventoryItemContainer.size.width)
        {
            x = 0;
            y-= 32;
        }
        
#if TARGET_OS_MAC
        
      
        
#endif
        i++;
        
    }
    
    while (y > -self.inventoryItemContainer.size.height)
    {
        SKSpriteNode *outline = [SKSpriteNode spriteNodeWithImageNamed:@"outline"];
        
        outline.position = CGPointMake(x+outline.size.width/2, y -outline.size.height/2);
        
        [self.inventoryItemContainer addChild:outline];
        
        x += 32;
        
        if (x >= self.inventoryItemContainer.size.width)
        {
            x = 0;
            y-= 32;
        }
    }
    
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

-(void)itemButtonSpritePressed:(ItemButtonSprite *)itemButtonSprite
{
    
}

-(void)buttonSpritePressed:(ButtonSprite *)buttonSprite
{
    [self removeFromParent];
}

@end
