//
//  MVTetrisPreferencesWindowController.m
//  Tetris
//
//  Created by Igor Smirnov on 12.01.13.
//  Copyright (c) 2013 megavolt605@gmail.com. All rights reserved.
//

#import "MVTetrisPreferencesWindowController.h"
#import "MVTetrisHighScore.h"

NSString * const MVTetrisPreferences_HighScores = @"HighScores";

@interface MVTetrisPreferencesWindowController ()

@end

@implementation MVTetrisPreferencesWindowController

+ (void) initialize {
    NSMutableDictionary * defaults = [NSMutableDictionary dictionary];
    NSMutableArray * emptyHighScores = [NSMutableArray array];
    [defaults setObject: emptyHighScores forKey: MVTetrisPreferences_HighScores];

    [[NSUserDefaults standardUserDefaults] registerDefaults: defaults];
}
    
- (id) init {
    self = [super initWithWindowNibName: @"MVTetrisPreferences"];
    NSMutableArray * ttt = [NSMutableArray new];
    [ttt addObject: [[MVTetrisHighScore alloc] init]];
    [ttt addObject: [[MVTetrisHighScore alloc] init]];
    [ttt addObject: [[MVTetrisHighScore alloc] init]];
    self.highScores = ttt;
    return self;
}

- (NSMutableArray *) highScores {
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray * loadedHighScores = [defaults objectForKey: MVTetrisPreferences_HighScores];
    return loadedHighScores;
}

- (void) setHighScores:(NSMutableArray *)highScores {
    [[NSUserDefaults standardUserDefaults] setObject: highScores forKey: MVTetrisPreferences_HighScores];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

@end
