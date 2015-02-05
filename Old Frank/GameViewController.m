//
//  GameViewController.m
//  Old Frank
//
//  Created by Skyler Lauren on 2/20/15.
//  Copyright (c) 2015 Sky Mist Development. All rights reserved.
//

#import "GameViewController.h"
#import "MyScene.h"

@interface GameViewController ()


@property (nonatomic, strong)IBOutlet SKView *skView;


@end
@implementation GameViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    // Configure the view.
    SKView *skView = [[SKView alloc]initWithFrame:self.view.frame];
    [self.view addSubview:skView];
    
    // Width constraint, half of parent view width
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:skView
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeWidth
                                                         multiplier:1
                                                           constant:0]];
    
    // Height constraint, half of parent view height
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:skView
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeHeight
                                                         multiplier:1
                                                           constant:0]];
    
    // Center horizontally
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:skView
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0
                                                           constant:0.0]];
    
    // Center vertically
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:skView
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1.0
                                                           constant:0.0]];

    skView.ignoresSiblingOrder = YES;
    //    skView.showsFPS = YES;
    
    // Create and configure the scene.
    //SKScene * scene = [MyScene sceneWithSize:CGSizeMake(self.view.bounds.size.height, self.view.bounds.size.width)];
    MyScene * scene = [MyScene sceneWithSize:self.view.bounds.size];
    
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    // Present the scene.
    [skView presentScene:scene];
    
}


@end
