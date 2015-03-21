//
//  InventoryController.m
//  SpriteKitGame
//
//  Created by Skyler Lauren on 2/4/15.
//  Copyright (c) 2015 Sky Mist Development. All rights reserved.
//

#import "InventoryController.h"
#import "ButtonSprite.h"
#import "ItemButtonSprite.h"
#import "SMDTextureLoader.h"
#import "TextSprite.h"

@interface InventoryController ()<ButtonSpriteDelegate, ItemButtonSpriteDelegate>

@property (nonatomic, strong)SKSpriteNode *playerSprite;
@property (nonatomic, strong)Player *player;
@property (nonatomic, strong)ButtonSprite *closeButton;
@property (nonatomic, strong)SKSpriteNode *inventoryItemContainer;

@property (nonatomic, strong)ItemButtonSprite *toolItemButtonSprite;
@property (nonatomic, strong)ItemButtonSprite *itemItemButtonSprite;
@property (nonatomic, strong)SKSpriteNode *selectOutline;
@property (nonatomic)NSInteger selectedIndex;

@property (nonatomic)CGSize size;

@property (nonatomic, strong)NSMutableArray *inventoryButtons;
@property (nonatomic, strong)SMDTextureLoader *textureLoader;

@end

@implementation InventoryController

-(id)initWithSize:(CGSize)size andPlayer:(Player *)player
{
    self = [super init];
    
    self.textureLoader = [[SMDTextureLoader alloc]init];
    
    self.size = size;
    
    self.inventorySpriteView = [SKSpriteNode spriteNodeWithColor:[SKColor whiteColor] size:size];
    self.inventorySpriteView.userInteractionEnabled = YES;
    
    self.inventorySpriteView.anchorPoint = CGPointMake(0, 0);
    self.inventorySpriteView.zPosition = 30000;
    self.player = player;
    
    SKTexture *playerTexture = [self.textureLoader getTextureForName:@"player"];

    self.playerSprite = [SKSpriteNode spriteNodeWithTexture:playerTexture];
    self.playerSprite.position = CGPointMake(size.width-self.playerSprite.size.width*2, size.height/2);
    [self.inventorySpriteView addChild:self.playerSprite];
    
    SKSpriteNode *outline = [SKSpriteNode spriteNodeWithTexture:[self.textureLoader getTextureForName:@"outline"]];
    outline.position = CGPointMake(self.playerSprite.position.x, size.height/2-self.playerSprite.size.height/2-outline.size.width/2-10);
    [self.inventorySpriteView addChild:outline];
    
    outline = [SKSpriteNode spriteNodeWithTexture:[self.textureLoader getTextureForName:@"outline"]];
    outline.position = CGPointMake(self.playerSprite.position.x, size.height/2+self.playerSprite.size.height/2+outline.size.width/2+10);
    [self.inventorySpriteView addChild:outline];
    
    //CloseButton
    self.closeButton = [[ButtonSprite alloc]initWithColor:[SKColor purpleColor] size:CGSizeMake(50, 50)];
    self.closeButton.position = CGPointMake(size.width-self.closeButton.size.width/2-10, size.height-self.closeButton.size.height/2-10);
    self.closeButton.userInteractionEnabled = YES;
    self.closeButton.delegate = self;
    
    [self.inventorySpriteView addChild:self.closeButton];
    
    self.inventoryItemContainer = [[SKSpriteNode alloc]initWithColor:[SKColor greenColor] size:CGSizeMake(5*32, 8*32)];
    self.inventoryItemContainer.anchorPoint = CGPointMake(0, 1);
    
    float diff = self.inventorySpriteView.size.height-self.inventoryItemContainer.size.height;
    
    self.inventoryItemContainer.position = CGPointMake(32, self.inventoryItemContainer.size.height + diff/2);
    [self.inventorySpriteView addChild:self.inventoryItemContainer];
    [self updateViews];
    
    TextSprite *textSprite = [[TextSprite alloc]initWithString:[NSString stringWithFormat:@"Gold $%@", @(self.player.gold)]];
    textSprite.position = CGPointMake(size.width/2, size.height-textSprite.calculateAccumulatedFrame.size.height-5);
    [self.inventorySpriteView addChild:textSprite];
    
    return self;
}

-(void)updateViews
{
    [self.toolItemButtonSprite removeFromParent];
    [self.itemItemButtonSprite removeFromParent];
    
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
        ItemButtonSprite *itemButtonSprite = [[ItemButtonSprite alloc]initWithItem:item];
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
        
        if (i == self.selectedIndex)
        {
            SKTexture *texture = [self.textureLoader getTextureForName:@"select_outline"];
            texture.filteringMode = SKTextureFilteringNearest;
            itemButtonSprite.texture = texture;
        }
        
        [self.inventoryButtons addObject:itemButtonSprite];
       
#endif
        i++;
        
    }
    
    while (y > -self.inventoryItemContainer.size.height)
    {
        SKSpriteNode *outline = [SKSpriteNode spriteNodeWithTexture:[self.textureLoader getTextureForName:@"outline"]];
        
        outline.position = CGPointMake(x+outline.size.width/2, y -outline.size.height/2);
        
        [self.inventoryItemContainer addChild:outline];
        
        x += 32;
        
        if (x >= self.inventoryItemContainer.size.width)
        {
            x = 0;
            y-= 32;
        }
    }
    

    
    self.toolItemButtonSprite = [[ItemButtonSprite alloc]initWithItem:self.player.equippedTool];
    self.toolItemButtonSprite.position = CGPointMake(self.playerSprite.position.x-self.playerSprite.size.width/2-self.toolItemButtonSprite.size.width/2-10, self.size.height/2-self.toolItemButtonSprite.size.width/2);
    self.toolItemButtonSprite.delegate = self;
    [self.inventorySpriteView addChild:self.toolItemButtonSprite];
    
    
    self.itemItemButtonSprite = [[ItemButtonSprite alloc]initWithItem:self.player.equippedItem];
    self.itemItemButtonSprite.position =  CGPointMake(self.playerSprite.position.x+self.playerSprite.size.width/2+self.itemItemButtonSprite.size.width/2+10, self.size.height/2-self.itemItemButtonSprite.size.width/2);
    self.itemItemButtonSprite.delegate = self;
    [self.inventorySpriteView addChild:self.itemItemButtonSprite];
}

-(void)buttonSpritePressed:(ButtonSprite *)buttonSprite
{
    NSLog(@"Touch");

    if (buttonSprite == self.closeButton)
    {
        [self.inventorySpriteView removeFromParent];
    }
}

-(void)itemButtonSpritePressed:(ItemButtonSprite *)itemButtonSprite
{
    if (itemButtonSprite == self.toolItemButtonSprite)
    {
        [self.player unequipTool];
    }
    else if (itemButtonSprite == self.itemItemButtonSprite)
    {
        [self.player unequipItem];
    }
    else if (itemButtonSprite.item.itemType == ItemTypeSword ||
             itemButtonSprite.item.itemType == ItemTypeWateringCan
             )
    {
        [self.player equipItem:itemButtonSprite.item];
    }
    else
    {
        [self.player equipItem:itemButtonSprite.item];
    }
    
    [self updateViews];
    
    NSLog(@"You pressed: %@", itemButtonSprite.item.itemName);
}

#if TARGET_OS_IPHONE

#else
-(void)handleEvenet:(NSEvent *)event isDown:(BOOL)downOrUp
{
    if(event.isARepeat)
        return;
    
    
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
                        if (self.selectedIndex-5 >= 0 )
                        {
                            self.selectedIndex -= 5;
                        }
                    }
                    break;
                case NSLeftArrowFunctionKey:
                    if (downOrUp)
                    {
                        if (self.selectedIndex-1 >= 0 )
                        {
                            self.selectedIndex--;
                        }
                    }
                    break;
                case NSRightArrowFunctionKey:
                    if (downOrUp)
                    {
                        if (self.selectedIndex+1 <= self.player.inventory.count-1 )
                        {
                            self.selectedIndex++;
                        }
                    }
                    
                    break;
                case NSDownArrowFunctionKey:
                    if (downOrUp)
                    {
                        if (self.selectedIndex+5 <= self.player.inventory.count-1 )
                        {
                            self.selectedIndex += 5;
                        }
                    }
                    break;
            }
        }
    }
    
    //i
    if((event.keyCode == 34 || event.keyCode ==12) && downOrUp)
    {
        [self.inventorySpriteView removeFromParent];
    }
    
    //space
    if(event.keyCode == 49 && downOrUp)
    {
        NSLog(@"Space");
        [self itemButtonSpritePressed:self.inventoryButtons[self.selectedIndex]];
    }
    
    NSLog(@"index: %@", @(self.selectedIndex));
    [self updateViews];
}

#endif


@end
