//
//  ButtonControlPanelNode.h
//  SpriteKitGame
//
//  Created by Skyler Lauren on 1/29/15.
//  Copyright (c) 2015 Sky Mist Development. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@protocol  ButtonControlPanelNodeDelegate <NSObject>

-(void)selectedControlButton:(SKSpriteNode *)controlButton;

@end

@interface ButtonControlPanelNode : SKSpriteNode

@property (nonatomic, strong)SKSpriteNode *primaryButton;
@property (nonatomic, strong)SKSpriteNode *secondaryButton;
@property (nonatomic, strong)SKSpriteNode *actionButton;
@property (nonatomic, strong)SKSpriteNode *inventoryButton;
@property (nonatomic, strong)SKSpriteNode *cancelButton;

@property (nonatomic, strong)SKSpriteNode *primaryButtonOverlay;
@property (nonatomic, strong)SKSpriteNode *secondaryButtonOverlay;
@property (nonatomic, strong)SKSpriteNode *actionButtonOverlay;

@property (weak)id<ButtonControlPanelNodeDelegate> delegate;

@end
