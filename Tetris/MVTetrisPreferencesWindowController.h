//
//  MVTetrisPreferencesWindowController.h
//  Tetris
//
//  Created by Igor Smirnov on 12.01.13.
//  Copyright (c) 2013 megavolt605@gmail.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MVTetris.h"

extern NSString * const MVTetrisPreferences_HighScores;

@interface MVTetrisPreferencesWindowController : NSWindowController {
    IBOutlet MVTetris * tetris;
}

@property NSMutableArray * highScores;

@end
