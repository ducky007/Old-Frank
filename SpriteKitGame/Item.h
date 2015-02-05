//
//  Item.h
//  SpriteKitGame
//
//  Created by Skyler Lauren on 1/7/15.
//  Copyright (c) 2015 Sky Mist Development. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ItemEntity.h"

typedef NS_ENUM(NSUInteger, ItemType) {
    ItemTypeSeed = 0,
    ItemTypePlant = 1,
    ItemTypeHoe = 2,
    ItemTypeSword = 3,
    ItemTypeWateringCan = 4,
    ItemTypeBackground = 5,
    ItemTypeWood = 6,
    ItemTypeRock = 7,
    ItemTypeSpellBook = 8,
    ItemTypeFoodstand = 9,
};


@interface Item : NSObject

-(id)initWithItemEntity:(ItemEntity *)itemEntity;

@property (nonatomic, strong)ItemEntity *itemEntity;

@property (nonatomic, strong)NSString *itemName;
@property (nonatomic)NSInteger maxStack;
@property (nonatomic)ItemType itemType;
@property (nonatomic)NSInteger quantity;
@property (nonatomic)BOOL impassable;
@property (nonatomic)BOOL canPickUp;

@end
