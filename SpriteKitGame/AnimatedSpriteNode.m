//
//  AnimatedSpriteNode.m
//  SpriteKitGame
//
//  Created by Skyler Lauren on 5/2/14.
//  Copyright (c) 2014 Sky Mist Development. All rights reserved.
//

#import "AnimatedSpriteNode.h"
#import "SMDTextureLoader.h"

@interface AnimatedSpriteNode ()

@property (nonatomic, strong)NSArray *walkRight;
@property (nonatomic, strong)NSArray *walkLeft;
@property (nonatomic, strong)NSArray *walkUp;
@property (nonatomic, strong)NSArray *walkDown;
@property (nonatomic, strong)SMDTextureLoader *textureLoader;

@end


@implementation AnimatedSpriteNode

-(instancetype)initWithImageNamed:(NSString *)imageName withWidth:(NSInteger)width withHeight:(NSInteger)height
{
    self = [super init];
    
    if (self)
    {
        self.textureLoader = [[SMDTextureLoader alloc]init];
        self.rows = height;
        self.columns = width;
        
        SKTexture *fullTexture = [SKTexture textureWithImageNamed:imageName];
        
        float widthPercent = 1.0f/width;
        float heightPercent = 1.0f/height;
        
        for (NSInteger i = 0; i < height; i++)
        {
            NSMutableArray *textureArray = [[NSMutableArray alloc]init];
            
            for (NSInteger j = 0; j < width; j++)
            {
                SKTexture *texture = [SKTexture textureWithRect:CGRectMake(j*widthPercent, i*heightPercent, widthPercent, heightPercent) inTexture:fullTexture];
                texture.filteringMode = SKTextureFilteringNearest;

                [textureArray addObject:texture];
            }
            
            switch (i)
            {
                case 3:
                    self.walkDown = textureArray;
                    break;
                case 2:
                    self.walkUp = textureArray;
                    break;
                case 1:
                    self.walkLeft = textureArray;
                    break;
                case 0:
                    self.walkRight = textureArray;
                    break;
                    
                default:
                    break;
            }
        }
        
        
        
        self.walkingArray = @[self.walkUp, self.walkDown, self.walkLeft, self.walkRight];
        
        NSMutableArray *walkingTexture = [[NSMutableArray alloc]init];
        
        for (NSInteger i = 0; i < 4; i++)
        {
            SKTexture *texture = [self.textureLoader getTextureForName:[NSString stringWithFormat:@"frank_walk_left_%@", @(i+1)]];
            [walkingTexture addObject:texture];
        }
        
        self.walkingArray = @[walkingTexture, self.walkingArray[1], walkingTexture, self.walkingArray[3]];
        
        walkingTexture = [[NSMutableArray alloc]init];
        
        for (NSInteger i = 0; i < 4; i++)
        {
            SKTexture *texture = [self.textureLoader getTextureForName:[NSString stringWithFormat:@"frank_walk_right_%@", @(i+1)]];
            [walkingTexture addObject:texture];
        }
        
        self.walkingArray = @[self.walkingArray[0], walkingTexture, self.walkingArray[2], walkingTexture];

        
        self.texture = self.walkingArray[0][0];
        self.size = self.texture.size;
        //NSLog(@"Size: %@", NSStringFromCGSize(self.size));

        self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(self.size.width, self.size.height/2) center:CGPointMake(0, -self.size.height/4)];
        self.physicsBody.dynamic = YES;
        self.physicsBody.allowsRotation = NO;

    }
    
    return self;
}

-(void)update
{
    
}

@end
