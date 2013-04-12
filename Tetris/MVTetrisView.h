//
//  MVTetris.h
//  Tetris
//
//  Created by Igor Smirnov
//  Copyright (c) 2012 megavolt605@gmail.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MVTetrisFigure.h"
#import "MVTetris.h"

@class MVTetrisPreferencesWindowController;

// размеры игрового поля
extern const int gameFieldWidth;
extern const int gameFieldHeight;

@interface MVTetrisView : NSView {
    // связка с полем с заголовком игровых очков
    IBOutlet NSTextField * labelTitleScore;
    
    // связка с кнопкой начала игры
    IBOutlet NSButton * newGameButton;

    // связка с кнопкой остановки игры
    IBOutlet NSButton * stopGameButton;
    
    IBOutlet NSDrawer * highScoresDrawer;
    
    IBOutlet MVTetrisPreferencesWindowController * highScoresPreferencesController;
    
    IBOutlet MVTetris * tetris;
    
}

// связка с событием нажатия кнопки
- (IBAction) newGame: (id) sender;
- (IBAction) stopGame: (id) sender;

// показ/скрытие таблицы рекордов
- (IBAction) highScores: (id) sender;

@property (readonly) NSImage * fieldImage;
@property (readonly) NSImage * wallImage;

@end
