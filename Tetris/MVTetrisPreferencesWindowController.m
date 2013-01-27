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
    NSMutableArray * defaultHighScores = [NSMutableArray array];
    
    [defaults setObject: defaultHighScores forKey: MVTetrisPreferences_HighScores];

    [[NSUserDefaults standardUserDefaults] registerDefaults: defaults];
}
    
- (id) init {
    self = [super initWithWindowNibName: @"MVTetrisPreferences"];
    return self;
}

- (NSMutableArray *) highScores {
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSArray * loadedHighScores = [[defaults objectForKey: MVTetrisPreferences_HighScores] mutableCopy];
    NSMutableArray * resultHighScores = [NSMutableArray new];
    
    for (NSDictionary * dict in loadedHighScores) {
        MVTetrisHighScore * score = [MVTetrisHighScore highScore: [dict valueForKey: @"score"] forDate: [dict valueForKey: @"date"]];
        [resultHighScores addObject: score];
    }
    
    return resultHighScores;
}

- (void) setHighScores:(NSMutableArray *)highScores {
    NSMutableArray * savedHighScores = [NSMutableArray new];
    for (MVTetrisHighScore * score in highScores) {
        NSMutableDictionary * scoreDict = [NSMutableDictionary new];
        [scoreDict setObject: score.date forKey: @"date"];
        [scoreDict setObject: score.score forKey: @"score"];
        [savedHighScores addObject: scoreDict];
    }
    [[NSUserDefaults standardUserDefaults] setObject: savedHighScores forKey: MVTetrisPreferences_HighScores];
}

- (IBAction) clearHighScores: (id) sender {
    self.highScores = [NSMutableArray new];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
}

@end
