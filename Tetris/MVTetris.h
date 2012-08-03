//
//  MVTetris.h
//  Tetris
//
//  Created by Igor Smirnov
//  Copyright (c) 2012 megavolt605@gmail.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MVTetrisFigure.h"

// размеры игрового поля
const int gameFieldWidth  = 16;
const int gameFieldHeight = 30;

@interface MVTetris : NSView {
    // связка с текстовым полем для вывода количество очков
    IBOutlet NSTextField * labelScore;
    
    // связка с кнопкой начала/остановки игры
    IBOutlet NSToolbarItem * newGameButton;
}

// связка с событием нажатия кнопки
- (IBAction) newGame:(id)sender;

@end
