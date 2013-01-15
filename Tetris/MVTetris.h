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
    
    // связка с кнопкой начала игры
    IBOutlet NSButton * newGameButton;

    // связка с кнопкой остановки игры
    IBOutlet NSButton * stopGameButton;
    
    IBOutlet NSDrawer * highScoresDrawer;
    
}

// связка с событием нажатия кнопки
- (IBAction) newGame: (id) sender;
- (IBAction) stopGame: (id) sender;

// показ/скрытие таблицы рекордов
- (IBAction) highScores: (id) sender;

- (NSRect) cellRect;

@property (readonly) NSImage * fieldImage;
@property (readonly) NSImage * wallImage;

@property (assign) NSNumber * inGame;
@property (assign) NSNumber * score;   // текущее количество очков
@property (assign) NSNumber * figures; // текущее количество фигур
@property (assign) NSNumber * lines;   // текущее количество линий

@end
