//
//  DialogManager.h
//  SpriteKitGame
//
//  Created by Skyler Lauren on 2/25/15.
//  Copyright (c) 2015 Sky Mist Development. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Dialog.h"


@interface DialogManager : NSObject

+(Dialog *)getDialogWithDialogName:(DialogName)dialogName;

@end
