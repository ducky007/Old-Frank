//
//  Dialog.h
//  SpriteKitGame
//
//  Created by Skyler Lauren on 2/25/15.
//  Copyright (c) 2015 Sky Mist Development. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, DialogResponse) {
    DialogResponseOk = 0,
    DialogResponseCont = 1,
    DialogResponseYes = 2,
    DialogResponseNo = 3,
};

typedef NS_ENUM(NSUInteger, DialogResponseType) {
    DialogResponseTypeOk = 0,
    DialogResponseTypeCont = 1,
    DialogResponseTypeYesNo = 2,
};

typedef NS_ENUM(NSUInteger, DialogName) {
    DialogNameSleep = 0,
    DialogPassedOut = 1,
    DialogNameFoodStand = 2,
};

typedef void (^ DialogBlock)(DialogResponse response);

@interface Dialog : NSObject

@property (nonatomic, strong)NSString *text;
@property (nonatomic)DialogResponseType responseType;
@property (nonatomic)DialogName dialogName;

@end
