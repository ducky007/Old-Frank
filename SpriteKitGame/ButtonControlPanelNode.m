//
//  ButtonControlPanelNode.m
//  SpriteKitGame
//
//  Created by Skyler Lauren on 1/29/15.
//  Copyright (c) 2015 Sky Mist Development. All rights reserved.
//

#import "ButtonControlPanelNode.h"

@implementation ButtonControlPanelNode

-(id)init{
    
    self = [super initWithColor:[UIColor clearColor] size:CGSizeMake(200,200)];
    
    self.zPosition = 101;
    
    self.userInteractionEnabled = YES;
    
    self.primaryButton = [[SKSpriteNode alloc]initWithImageNamed:@"primary_background"];
    self.primaryButton.position  = CGPointMake(0,0);// 100;
    [self addChild:self.primaryButton];
    
    self.primaryButtonOverlay = [SKSpriteNode spriteNodeWithColor:[UIColor clearColor] size:CGSizeMake(self.primaryButton.size.width*.75, self.primaryButton.size.width*.75)];
    self.primaryButtonOverlay.position = CGPointMake(0,0);
    
    [self.primaryButton addChild:self.primaryButtonOverlay];
    
    self.secondaryButton = [[SKSpriteNode alloc]initWithImageNamed:@"secondary_background"];
    self.secondaryButton.position  = CGPointMake(0,0);// 100;
    self.secondaryButton.zPosition = 101;
    
    self.secondaryButton.userInteractionEnabled = YES;
    
    [self addChild:self.secondaryButton];
    
    self.secondaryButtonOverlay = [SKSpriteNode spriteNodeWithColor:[UIColor clearColor] size:CGSizeMake(self.secondaryButton.size.width, self.secondaryButton.size.width)];
    self.secondaryButtonOverlay.zPosition = 102;
    
    [self.secondaryButton addChild:self.secondaryButtonOverlay];
    
    self.actionButton = [[SKSpriteNode alloc]initWithImageNamed:@"secondary_background"];
    self.actionButton.position  = CGPointMake(0,0);
    [self addChild:self.actionButton];
    
    self.actionButtonOverlay = [SKSpriteNode spriteNodeWithColor:[UIColor clearColor] size:CGSizeMake(self.actionButton.size.width, self.secondaryButton.size.width)];
    
    [self.secondaryButton addChild:self.actionButtonOverlay];
    
    
    self.inventoryButton = [[SKSpriteNode alloc]initWithImageNamed:@"backpack"];
    self.inventoryButton.position  = CGPointMake(0,0);// 100;
    self.inventoryButton.zPosition = 105;
    
    [self addChild:self.inventoryButton];
    
    
    
    return self;
    
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touched");
    
    for (UITouch *touch in touches)
    {
        CGPoint location = [touch locationInNode:self];
        
        self.primaryButton.position = location;
        
        self.actionButton.position = CGPointMake(location.x-(self.primaryButton.size.width/2)-self.actionButton.size.width/2-10, location.y);
        
        self.secondaryButton.position = CGPointMake(location.x+(self.primaryButton.size.width/2)+self.secondaryButton.size.width/2+10, location.y);
        
        self.inventoryButton.position = CGPointMake(location.x, location.y+(self.primaryButton.size.width/2)+self.inventoryButton.size.height/2);
        
        self.primaryButton.alpha = .5;
        self.secondaryButton.alpha = .5;
        self.inventoryButton.alpha = .5;
        self.actionButton.alpha = .5;
        self.cancelButton.alpha = .5;
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches)
    {
        self.alpha = 1;
        CGPoint location = [touch locationInNode:self];
        
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches)
    {
        CGPoint location = [touch locationInNode:self];
        
        SKSpriteNode *selectedSprite;
        
        if (CGRectContainsPoint(self.primaryButton.calculateAccumulatedFrame, location))
        {
            selectedSprite = self.primaryButton;
        }
        else if (CGRectContainsPoint(self.secondaryButton.calculateAccumulatedFrame, location))
        {
            selectedSprite = self.secondaryButton;
        }
        else if (CGRectContainsPoint(self.actionButton.calculateAccumulatedFrame, location))
        {
            selectedSprite = self.actionButton;
        }
        else if (CGRectContainsPoint(self.inventoryButton.calculateAccumulatedFrame, location))
        {
            selectedSprite = self.inventoryButton;
        }
        
        if (selectedSprite)
        {
            [self.delegate selectedControlButton:selectedSprite];
        }
    }
    
    self.primaryButton.alpha = 0;
    self.secondaryButton.alpha = 0;
    self.inventoryButton.alpha = 0;
    self.actionButton.alpha = 0;
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.primaryButton.alpha = 0;
    self.secondaryButton.alpha = 0;
    self.inventoryButton.alpha = 0;
    self.actionButton.alpha = 0;
}


@end
