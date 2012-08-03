//
//  MVTetrisFigure.m
//  Tetris
//
//  Created by Igor Smirnov
//  Copyright (c) 2012 megavolt605@gmail.com. All rights reserved.
//

#import "MVTetrisFigure.h"

// координаты с занятыми ячейками для всех типов фигур
const coord figureShapes[7][4] = { 
    // fkUnknown
    {}, 
    
    // fkSquare
    { {1,1}, {1,2}, {2,1}, {2,2} }, 
    
    // fkLine
    { {1,0}, {1,1}, {1,2}, {1,3} }, 
    
    // fkL
    { {1,0}, {1,1}, {1,2}, {2,2} }, 
    
    // fkJ
    { {2,0}, {2,1}, {2,2}, {1,2} }, 
    
    // fkS
    { {1,1}, {2,1}, {0,2}, {1,2} }, 
    
    // fkZ
    { {0,1}, {1,1}, {1,2}, {2,2} } 
};

@implementation MVTetrisFigure
{
    
}
// объявление свойств
@synthesize shape;
@synthesize color;

// инициализация
- (id) init {
    self = [super init];
    if (self) {
        self.kind = fkUnknown;
    }
    return self;
}


// чтение типа фигуры
- (figureKind) kind {
    return _kind;
}

// установка типа фигуры
- (void) setKind:(figureKind)newKind {
    int x, y, i;
    
    // очистка изображения
    for (x = 0; x < 4; x++) {
        for (y = 0; y < 4; y++) {
            shape.figure[x][y] = 0;
        }
    }
    
    _kind = newKind;

    // указываем цвет
    self.color = figureColors[_kind];

    // прорисовка нового изображения
    if (_kind != fkUnknown) { 
        for (i = 0; i < 4; i++) {
            shape.figure[ figureShapes[_kind][i].x ] [figureShapes[_kind][i].y] = 1;
        }
    }
}

// поворот изображения фигуры против часовой стрелки
// лирическое отступление:
// я, в свое время, поиграл в большое количество модификаций тетрисов.
// но хотелось создать то самое поведение, которое пальцы помнят еще
// с тетриса на ДВК2 и УКНЦ, ну и как бы тут две настройки:
// изначальное расположение фигуры в сетке 4х4
// и направление поворота. поэтому - против часовой :)
- (void) rotate {
    int x, y;
    int buf [4][4];
    for (x = 0; x < 4; x++) {
        for (y = 0; y < 4; y++) {
            buf[x][y] = shape.figure[x][y];
        }
    }
    for (x = 0; x < 4; x++) {
        for (y = 0; y < 4; y++) {
            shape.figure[x][y] = buf[3-y][x];
        }
    }
}

// выбор случайного типа фигуры
- (void) randomKind {
    self.kind = arc4random_uniform(6) + 1;
}

// клонирование текущей фигуры
- (MVTetrisFigure *) clone {
    MVTetrisFigure * res;
    res = [[MVTetrisFigure alloc] init];
    res.kind = self.kind;
    res.color = self.color;
    return res;
}

@end
