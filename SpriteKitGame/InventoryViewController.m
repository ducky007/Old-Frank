//
//  InventoryViewController.m
//  SpriteKitGame
//
//  Created by Skyler Lauren on 1/4/15.
//  Copyright (c) 2015 Sky Mist Development. All rights reserved.
//

#import "InventoryViewController.h"
//#import "InventoryItem.h"
#import  <QuartzCore/CALayer.h>



@interface InventoryViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *inventoryScrollView;

@property (weak, nonatomic) IBOutlet UIView *inventoryContainerView;

@property (weak, nonatomic) IBOutlet UIButton *itemSlotButton;
@property (weak, nonatomic) IBOutlet UIButton *toolSlotButton;

@property (weak, nonatomic) IBOutlet UIView *equippedItemContainerView;
@property (weak, nonatomic) IBOutlet UIView *equippedToolContainerView;


@end

@implementation InventoryViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [self updateInventoryView];
}


-(void)updateInventoryView
{
    for (UIView *view in self.inventoryContainerView.subviews)
    {
        [view removeFromSuperview];
    }
    
    NSString *folderPath;
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *library = [path objectAtIndex:0];
    
    folderPath = [library stringByAppendingPathComponent:@"Document"];
    library = [library stringByAppendingPathComponent:@"custom"];
    
    BOOL success = [[NSFileManager defaultManager] createDirectoryAtPath:folderPath withIntermediateDirectories:NO attributes:nil error:nil];
    
    NSLog(@"create %d",success);
 
    
    
    CGRect frame = self.inventoryContainerView.frame;
    frame.size.height = self.inventoryScrollView.frame.size.height;
    self.inventoryContainerView.frame = frame;

    NSInteger xPosition = 0;
    NSInteger yPosition = 0;
    NSInteger index = 0;
    
    for (Item *item in self.player.inventory)
    {
        UIView *itemView = [[UIView alloc]initWithFrame:CGRectMake(xPosition, yPosition, 32, 32)];
        
        UIImage *background = [UIImage imageNamed:@"outline"];
        UIImageView *backgroundImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 32, 32)];
        backgroundImageView.image = background;
        backgroundImageView.layer.magnificationFilter = kCAFilterNearest;
        
        UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 32, 32)];
        [button setImage:[UIImage imageNamed:item.itemName] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(inventoryItemPressed:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = index;
        button.imageView.layer.magnificationFilter = kCAFilterNearest;

        NSInteger quanity = item.quantity;
        
        [itemView addSubview:backgroundImageView];
        [itemView addSubview:button];
        
        if (quanity > 1)
        {
            NSInteger leftDigit = quanity/10;
            NSInteger rightDigit = quanity-(leftDigit *10);
            
            
            UIImageView *rightNumber = [[UIImageView alloc]initWithFrame:CGRectMake(32-4, 32-7, 4, 7)];
            rightNumber.image = [UIImage imageNamed:[NSString stringWithFormat:@"num%@", @(rightDigit)]];
            
            UIImageView *leftNumber = [[UIImageView alloc]initWithFrame:CGRectMake(32-8, 32-7, 4, 7)];
            leftNumber.image = [UIImage imageNamed:[NSString stringWithFormat:@"num%@", @(leftDigit)]];
            
            [itemView addSubview:leftNumber];
            [itemView addSubview:rightNumber];
            
        }
        
        
        [self.inventoryContainerView addSubview:itemView];
        
        xPosition +=32;

        
        if(xPosition+32 > self.inventoryContainerView.frame.size.width)
        {
            xPosition = 0;
            yPosition += 32;
        }
        
        index++;
    }
    
    while (yPosition < self.inventoryContainerView.frame.size.height - 32)
    {
        UIView *itemView = [[UIView alloc]initWithFrame:CGRectMake(xPosition, yPosition, 32, 32)];
        
        UIImage *background = [UIImage imageNamed:@"outline"];
        UIImageView *backgroundImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 32, 32)];
        backgroundImageView.image = background;
        
        [itemView addSubview:backgroundImageView];
        
        [self.inventoryContainerView addSubview:itemView];
        
        xPosition +=32;
        
        if(xPosition+32 > self.inventoryContainerView.frame.size.width)
        {
            xPosition = 0;
            yPosition += 32;
        }
        
    }
    
    frame = self.inventoryContainerView.frame;
    frame.size.height = yPosition;
    self.inventoryContainerView.frame = frame;
    
    self.inventoryScrollView.contentSize = self.inventoryContainerView.frame.size;
    
    [self updatePlayerEquippedItemView];
}

-(void)updatePlayerEquippedItemView
{
    for (UIView *view in self.equippedItemContainerView.subviews)
    {
        [view removeFromSuperview];
    }
    
    UIView *view = [self viewForItem:self.player.equippedItem withTag:0];
    [self.equippedItemContainerView addSubview:view];
    
    [self updatePlayerEquippedToolView];
}

-(void)updatePlayerEquippedToolView
{
    for (UIView *view in self.equippedToolContainerView.subviews)
    {
        [view removeFromSuperview];
    }
    
    UIView *view = [self viewForItem:self.player.equippedTool withTag:1];
    [self.equippedToolContainerView addSubview:view];
}

-(UIView *)viewForItem:(Item *)item withTag:(NSInteger)tag
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 32, 32)];
    
    UIImageView *outline = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 32, 32)];
    outline.image = [UIImage imageNamed:@"outline"];
    [view addSubview:outline];
    
    if (!item)
    {
        return view;
    }
    
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 32, 32)];
    button.tag = tag;
    [button setImage:[UIImage imageNamed:item.itemName] forState:UIControlStateNormal];
    [view addSubview:button];
    
    NSInteger quanity = item.quantity;
    
    if (quanity > 1)
    {
        NSInteger leftDigit = quanity/10;
        NSInteger rightDigit = quanity-(leftDigit *10);
        
        
        UIImageView *rightNumber = [[UIImageView alloc]initWithFrame:CGRectMake(32-4, 32-7, 4, 7)];
        rightNumber.image = [UIImage imageNamed:[NSString stringWithFormat:@"num%@", @(rightDigit)]];
        
        UIImageView *leftNumber = [[UIImageView alloc]initWithFrame:CGRectMake(32-8, 32-7, 4, 7)];
        leftNumber.image = [UIImage imageNamed:[NSString stringWithFormat:@"num%@", @(leftDigit)]];
        
        [view addSubview:leftNumber];
        [view addSubview:rightNumber];
    }
    
    
    [button addTarget:self action:@selector(itemSlotButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
   
    
    return view;
}

-(void)inventoryItemPressed:(UIButton *)sender
{
    Item *item = self.player.inventory[sender.tag];
    [self.player equipItem:item];
    
    [self updateInventoryView];
}

- (IBAction)itemSlotButtonPressed:(UIButton *)sender
{
    switch (sender.tag)
    {
        case 0:
            [self.player unequipItem];
            break;
        case 1:
            [self.player unequipTool];
            break;
            
        default:
            break;
    }
    
    [self updateInventoryView];
}

- (IBAction)closeButtonPressed:(UIButton *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}



@end
