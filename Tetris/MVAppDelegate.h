//
//  MVAppDelegate.h
//  Tetris
//
//  Created by Igor Smirnov on 20.06.12.
//  Copyright (c) 2012 megavolt605@gmail.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MVTetris.h"

@class MVTetrisPreferencesWindowController;

@interface MVAppDelegate : NSObject <NSApplicationDelegate> {
    IBOutlet MVTetrisPreferencesWindowController * preferences;
}

- (IBAction) showPreferences: (id) sender;

@property (assign) IBOutlet NSWindow * window;
@property (assign) IBOutlet MVTetris * field;

@end
