//
//  MVTetrisPreferencesWindowController.h
//  Tetris
//
//  Created by Igor Smirnov on 12.01.13.
//  Copyright (c) 2013 megavolt605@gmail.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MVTetrisView.h"

extern NSString * const MVTetrisPreferences_HighScores;

@interface MVTetrisPreferencesWindowController : NSWindowController {
    IBOutlet MVTetrisView * tetris;
}

@property NSMutableArray * highScores;

- (IBAction) clearHighScores: (id) sender;

@end
