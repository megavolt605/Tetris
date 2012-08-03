//
//  MVTetrisFigure.h
//  Tetris
//
//  Created by Igor Smirnov
//  Copyright (c) 2012 megavolt605@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

// тип фигуры
typedef enum figureKind {
    fkFirst,
    fkUnknown = fkFirst, 
    fkSquare, 
    fkLine, 
    fkL, 
    fkJ, 
    fkS, 
    fkZ,
    fkLast = fkZ,
    fkCount
} figureKind;

// изображение фигуры
typedef struct {int figure [4][4]; } figureShape;

// координаты
typedef struct {int x, y; } coord;

// цвета фигур
NSColor * figureColors [fkCount];

@interface MVTetrisFigure : NSObject {
    figureKind _kind;   // тип фигуры
    figureShape shape;  // изображение фигуры
    NSColor * color;    // цвет фигуры
}

// чтение/установка типа фигуры
- (void) setKind:(figureKind)newKind;
- (figureKind) kind;

// поворот фигуры
- (void) rotate;

// выбор случайного типа фигуры
- (void) randomKind;

// клонирование текущей фигуры
- (MVTetrisFigure *) clone;

// объявление свойств
@property (readwrite) figureKind kind;
@property (readonly) figureShape shape;
@property (readwrite) NSColor * color;

@end
