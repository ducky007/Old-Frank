//
//  ViewController.h
//  SpriteKitGame
//

//  Copyright (c) 2014 Sky Mist Development. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>
#import "Player.h"

@interface GameViewController : UIViewController

-(void)showInventoryViewForPlayer:(Player *)player;

@end
