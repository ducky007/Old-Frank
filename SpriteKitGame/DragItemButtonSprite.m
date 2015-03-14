//
//  DragItemButtonSprite.m
//  Old Frank
//
//  Created by Skyler Lauren on 3/11/15.
//  Copyright (c) 2015 Sky Mist Development. All rights reserved.
//

#import "DragItemButtonSprite.h"

@implementation DragItemButtonSprite

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in [touches allObjects])
    {
        CGPoint position = [touch locationInNode:self];
        self.itemSprite.position = position;
    }
}

@end
