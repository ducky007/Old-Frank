//
//  Item.m
//  SpriteKitGame
//
//  Created by Skyler Lauren on 1/7/15.
//  Copyright (c) 2015 Sky Mist Development. All rights reserved.
//

#import "Item.h"
#import "ItemManager.h"

@implementation Item

-(id)initWithItemEntity:(ItemEntity *)itemEntity
{
    if (!itemEntity) {
        return  nil;
    }
    
    self = [[ItemManager sharedManager]getItem:itemEntity.item_name];
    self.quantity = [itemEntity.quantity integerValue];
    self.itemEntity = itemEntity;
    return self;
}

-(void)setQuantity:(NSInteger)quantity
{
    self.itemEntity.quantity = @(quantity);
    _quantity = quantity;
}

@end
