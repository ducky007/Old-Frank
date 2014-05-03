//
//  ButtonSprite.h
//  SpriteKitGame
//
//  Created by Skyler Lauren on 1/28/15.
//  Copyright (c) 2015 Sky Mist Development. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@class ButtonSprite;

@protocol ButtonSpriteDelegate <NSObject>

-(void)buttonSpritePressed:(ButtonSprite *)buttonSprite;

@end

@interface ButtonSprite : SKSpriteNode

@property (weak)id<ButtonSpriteDelegate> delegate;

@end
