//
//  ItemButtonSprite.h
//  SpriteKitGame
//
//  Created by Skyler Lauren on 2/4/15.
//  Copyright (c) 2015 Sky Mist Development. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "Item.h"    

@class ItemButtonSprite;

@protocol ItemButtonSpriteDelegate <NSObject>

-(void)itemButtonSpritePressed:(ItemButtonSprite *)itemButtonSprite;

@end

@interface ItemButtonSprite : SKSpriteNode

-(id)initWithItem:(Item *)item;

@property (weak)id<ItemButtonSpriteDelegate> delegate;
@property (nonatomic, strong)Item *item;
@property (nonatomic, strong)SKSpriteNode *itemSprite;

@end
