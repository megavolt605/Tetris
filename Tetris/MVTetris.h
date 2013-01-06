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
extern const int gameFieldWidth;
extern const int gameFieldHeight;

@interface MVTetris : NSView {
    // связка с полем с заголовком игровых очков
    IBOutlet NSTextField * labelTitleScore;
    
    // связка с текстовым полем для вывода количества очков
    IBOutlet NSTextField * labelScore;
    
    // связка с кнопкой начала игры
    IBOutlet NSButton * newGameButton;

    // связка с кнопкой остановки игры
    IBOutlet NSButton * stopGameButton;
}

// связка с событием нажатия кнопки
- (IBAction) newGame:(id)sender;
- (IBAction) stopGame:(id)sender;

@property NSNumber *inGame;
@property NSNumber *score;   // текущее количество очков


@end
