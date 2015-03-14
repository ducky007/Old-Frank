//
//  Player.m
//  SpriteKitGame
//
//  Created by Skyler Lauren on 1/5/15.
//  Copyright (c) 2015 Sky Mist Development. All rights reserved.
//

#import "Player.h"
#import "ItemManager.h"
#import "SMDCoreDataHelper.h"
#import "ItemEntity.h"

@implementation Player

static inline CGPoint rwAdd(CGPoint a, CGPoint b) {
    return CGPointMake((int)(a.x + b.x), (int)a.y + b.y);
}

static inline CGPoint rwMult(CGPoint a, float b) {
    return CGPointMake(a.x * b, a.y * b);
}

-(id)init
{
    self = [super init];
    
    NSArray *players = [[SMDCoreDataHelper sharedHelper]fetchEntities:@"PlayerEntity"];
    self.imageName = @"knight";
    
    self.width = 30;
    self.height = 60;
    self.rows = 4;
    self.columns = 2;
   
    if (players.count == 1)
    {
        NSLog(@"found old player");
        
        [self loadPlayerFromCoreData:players[0]];
    }
    else
    {
        PlayerEntity *playerEntity = [[SMDCoreDataHelper sharedHelper]createNewEntity:@"PlayerEntity"];
        self.playerEntity = playerEntity;
        
        self.energy = 100;
        self.maxEnergy = 100;
        
        [self addItemWithName:@"basic_sword"];
        [self addItemWithName:@"fire_spellbook"];
        [self addItemWithName:@"basic_watering_can"];

    }
    
    return self;
}

-(void)setEnergy:(float)energy
{
    self.playerEntity.energy = @(energy);
    _energy = energy;
}

-(void)setMaxEnergy:(float)maxEnergy
{
    self.playerEntity.max_energy = @(maxEnergy);
    _maxEnergy = maxEnergy;
}

-(void)loadPlayerFromCoreData:(PlayerEntity *)playerEntity
{
    self.energy = [playerEntity.energy floatValue];
    self.maxEnergy = [playerEntity.max_energy floatValue];
    self.equippedItem = [[Item alloc]initWithItemEntity:playerEntity.equppied_item];
    self.equippedTool = [[Item alloc]initWithItemEntity:playerEntity.equipped_tool];
    
    for (ItemEntity *itemEntity in [playerEntity.inventory allObjects])
    {
        NSLog(@"adding from core data: %@", itemEntity.item_name);
        Item *item = [[Item alloc]initWithItemEntity:itemEntity];
        [self.inventory addObject:item];
    }
    
    self.playerEntity = playerEntity;
    
}

-(NSMutableArray *)inventory
{
    if (!_inventory) {
        _inventory = [[NSMutableArray alloc]init];
    }
    
    return _inventory;
}

-(void)addItemWithName:(NSString *)name
{

    BOOL added = NO;
    
    if (self.equippedItem)
    {
        if ([self.equippedItem.itemName isEqualToString:name]
            && self.equippedItem.maxStack > (self.equippedItem.quantity+1))
        {
            self.equippedItem.quantity += 1;
            NSLog(@"increased equipped: %@ quantity: %@", self.equippedItem.itemName, @(self.equippedItem.quantity));
            added = YES;
            return;
        }
    }
    
    for (Item *item in self.inventory)
    {
        if ([item.itemName isEqualToString:name]
            && item.maxStack > (item.quantity +1))
        {
            item.quantity += 1;
            
            NSLog(@"added new item: %@", item.itemName);

            added = YES;
            
            return;
        }
    }
    
    if (!added)
    {
        Item *item = [[ItemManager sharedManager]getItem:name];
        
        ItemEntity *itemEntity = [[SMDCoreDataHelper sharedHelper]createNewEntity:@"ItemEntity"];
        itemEntity.item_name = item.itemName;
        itemEntity.quantity = @(item.quantity);
        item.itemEntity = itemEntity;
        itemEntity.player_inventory = self.playerEntity;

        NSLog(@"added new stack: %@", item.itemName);

        [self.inventory addObject:item];
        
        [[SMDCoreDataHelper sharedHelper]save];
    }
}

-(void)equipItem:(Item *)item
{
    switch (item.itemType)
    {
        case ItemTypeSword:
            [self equipTool:item];
            break;
        case ItemTypePlant:
            [self equipRegularItem:item];
            break;
        case ItemTypeHoe:
            [self equipTool:item];
            break;
        case ItemTypeWateringCan:
            [self equipTool:item];
            break;
        case ItemTypeSeed:
            [self equipRegularItem:item];
            break;
        case ItemTypeSpellBook:
            [self equipRegularItem:item];
            break;
            
        default:
            break;
    }
}

-(void)equipTool:(Item *)item
{
    if (self.equippedTool)
    {
        [self unequipTool];
    }
    
    [self.inventory removeObject:item];
    self.equippedTool = item;
    
    item.itemEntity.player_inventory = nil;
    item.itemEntity.player_tool = self.playerEntity;

}

-(void)equipRegularItem:(Item *)item
{
    if (self.equippedItem)
    {
        [self unequipItem];
    }
    
    [self.inventory removeObject:item];
    self.equippedItem = item;
    
    item.itemEntity.player_inventory = nil;
    item.itemEntity.player_item = self.playerEntity;

}

-(void)unequipItem
{
    Item *item = self.equippedItem;
    
    
    [self.inventory addObject:item];
    self.equippedItem = nil;
    
    item.itemEntity.player_inventory = nil;
    item.itemEntity.player_item = self.playerEntity;
}
         
-(void)unequipTool
{
    Item *item = self.equippedTool;
    
    [self.inventory addObject:item];
    self.equippedTool = nil;
    
    item.itemEntity.player_tool = nil;
    item.itemEntity.player_inventory = self.playerEntity;
}

-(void)removeItem
{
    self.equippedItem.quantity--;
    
    NSLog(@"Equip count: %@", @(self.equippedItem.quantity));
    
    if (!self.equippedItem.quantity)
    {
         [[SMDCoreDataHelper sharedHelper]removeEntity:self.equippedItem.itemEntity andSave:YES];
        
        self.equippedItem = nil;
    }
    else if (self.equippedItem.quantity < 0)
    {
        NSLog(@"ERROR FOR QUANTITY!!!");
    }
}

-(void)update:(float)dt
{
    if (self.moveVelocity.x || self.moveVelocity.y)
    {
        self.isMoving = YES;
    }
    else
    {
        self.frameIndex = 0;
        self.isMoving = NO;
        return;
    }
    
    if (fabsf(self.moveVelocity.x) > fabsf(self.moveVelocity.y))
    {
        if(self.moveVelocity.x > 0)
        {
            self.direction = DirectionRight;
        }
        else
        {
            self.direction = DirectionLeft;
        }
    }
    else
    {
        if(self.moveVelocity.y > 0)
        {
            self.direction = DirectionUp;
    
        }
        else
        {
            self.direction = DirectionDown;
        }
    }
    
    self.frameTimer += dt;
    
    if (self.frameTimer > self.frameTimerMax)
    {
        self.frameIndex = (self.frameIndex + 1) % 2;
        self.frameTimer = 0;
    }

    float frameMax = .1;
    float frameTimerMaxX = frameMax * (1.0f/fabsf(self.moveVelocity.x));
    float frameTimerMaxY = frameMax * (1.0f/fabsf(self.moveVelocity.y));
    
    self.frameTimerMax = (frameTimerMaxX > frameTimerMaxY) ? frameTimerMaxY : frameTimerMaxX;
    
    self.moveVelocity = rwMult(self.moveVelocity, 300.0f*dt);
    self.moveVelocity = CGPointMake((int)self.moveVelocity.x, (int)self.moveVelocity.y);

    CGRect playerRect = CGRectMake(self.position.x-self.width/2, -self.position.y, self.width, self.height/2);
    CGPoint oldVelocity = CGPointMake(self.moveVelocity.x, self.moveVelocity.y);
    
    for (NSValue *value in self.collisionRects)
    {
        
#if TARGET_OS_IPHONE
        CGRect collisionRect = [value CGRectValue];
#else
        CGRect collisionRect = [value rectValue];
#endif
        
        //x first
        if (self.moveVelocity.x != 0)
        {
            playerRect.origin.x += (int)oldVelocity.x;
            
            if (CGRectIntersectsRect(collisionRect, playerRect))
            {
                //modify x
                if (self.moveVelocity.x > 0)
                {
                    float diff = playerRect.origin.x+playerRect.size.width-collisionRect.origin.x;
                    self.moveVelocity = CGPointMake(self.moveVelocity.x-diff, self.moveVelocity.y);
                }
                else
                {
                    float diff = collisionRect.origin.x+collisionRect.size.width-playerRect.origin.x;
                    self.moveVelocity = CGPointMake(self.moveVelocity.x+diff, self.moveVelocity.y);
                }
            }
            
            playerRect.origin.x -= (int)oldVelocity.x;
        }
        
        //y second
        if (self.moveVelocity.y != 0)
        {
            playerRect.origin.y -= (int)oldVelocity.y;
            
            if (CGRectIntersectsRect(collisionRect, playerRect))
            {
                //modify y
                if (self.moveVelocity.y > 0)
                {
                    float diff = collisionRect.origin.y+collisionRect.size.height-playerRect.origin.y;
                    self.moveVelocity = CGPointMake(self.moveVelocity.x, self.moveVelocity.y-diff);
                }
                else
                {
                    float diff = playerRect.origin.y+playerRect.size.height-collisionRect.origin.y;
                    self.moveVelocity = CGPointMake(self.moveVelocity.x, self.moveVelocity.y+diff);
                }

            }
            
            playerRect.origin.y += (int)oldVelocity.y;
        }
    }
    
    if (self.moveVelocity.x != oldVelocity.x && self.moveVelocity.y != oldVelocity.y)
    {
        NSLog(@"Picking One");
        //pick one
        if (abs(self.moveVelocity.x) < abs(self.moveVelocity.y))
        {
            self.moveVelocity = CGPointMake(self.moveVelocity.x, 0);
        }
        else
        {
            self.moveVelocity = CGPointMake(0, self.moveVelocity.y);
        }
    }
    
    self.position = rwAdd(self.position, self.moveVelocity);
}

@end
