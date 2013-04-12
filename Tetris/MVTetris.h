//
//  MVTetris.h
//  Tetris
//
//  Created by Igor Smirnov on 31.01.13.
//  Copyright (c) 2013 megavolt605@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MVTetrisFigure.h"

@interface MVTetris : NSObject

@property MVTetrisFigure * currentFigure;                             // текущая фигура
@property MVTetrisFigure * nextFigure;                                // следующая фигура

@property (assign) NSNumber * inGame;  // признак активности игры
@property (assign) NSNumber * level;   // текущий уровень
@property (assign) NSNumber * score;   // текущее количество очков
@property (assign) NSNumber * figures; // текущее количество фигур
@property (assign) NSNumber * lines;   // текущее количество линий

@end
