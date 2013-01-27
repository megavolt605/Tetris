//
//  MVAppDelegate.m
//  Tetris
//
//  Created by Igor Smirnov on 20.06.12.
//  Copyright (c) 2012 megavolt605@gmail.com. All rights reserved.
//

#import "MVAppDelegate.h"
#import "MVTetrisPreferencesWindowController.h"

@implementation MVAppDelegate

@synthesize window = _window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
}

- (IBAction) showPreferences: (id) sender {
    if (!preferences) {
        preferences = [MVTetrisPreferencesWindowController new];
    }
    [preferences showWindow: self];
}

- (BOOL) applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return true;
}

@end
