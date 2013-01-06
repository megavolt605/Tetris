//
//  MVAppDelegate.h
//  Tetris
//
//  Created by Igor Smirnov on 20.06.12.
//  Copyright (c) 2012 megavolt605@gmail.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MVTetris.h"

@interface MVAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet MVTetris *field;

@end
