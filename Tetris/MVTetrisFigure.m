//
//  MVTetrisFigure.m
//  Tetris
//
//  Created by Igor Smirnov
//  Copyright (c) 2012 megavolt605@gmail.com. All rights reserved.
//

#import "MVTetrisFigure.h"
#import "MVTetrisView.h"

// координаты с занятыми ячейками для всех типов фигур
const coord figureShapes[fkCount][4] = { 
    /* fkUnknown */ {},
    /* fkO       */ { {1,1}, {1,2}, {2,1}, {2,2} },
    /* fkI       */ { {1,0}, {1,1}, {1,2}, {1,3} },
    /* fkL       */ { {1,0}, {1,1}, {1,2}, {2,2} },
    /* fkJ       */ { {2,0}, {2,1}, {2,2}, {1,2} },
    /* fkS       */ { {1,1}, {2,1}, {0,2}, {1,2} },
    /* fkZ       */ { {0,1}, {1,1}, {1,2}, {2,2} },
    /* fkT       */ { {0,2}, {1,2}, {2,2}, {1,1} }
};

@implementation MVTetrisFigure

// инициализация
- (id) init {
    self = [super init];
    if (self) {
        self.kind = fkUnknown;
    }
    return self;
}

// установка типа фигуры
- (void) setKind:(figureKind) newKind {
    int x, y, i;
    
    // очистка изображения
    for (x = 0; x < 4; x++) {
        for (y = 0; y < 4; y++) {
            _shape.figure[x][y] = 0;
        }
    }
    
    _kind = newKind;

    // указываем цвет
    self.color = figureImages[_kind];

    // прорисовка нового изображения
    if (_kind != fkUnknown) {
        for (i = 0; i < 4; i++) {
            _shape.figure[ figureShapes[_kind][i].x ] [figureShapes[_kind][i].y] = 1;
        }
    }
}

- (figureKind) getKind {
    return _kind;
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
            buf[x][y] = _shape.figure[x][y];
        }
    }
    for (x = 0; x < 4; x++) {
        for (y = 0; y < 4; y++) {
            _shape.figure[x][y] = buf[3-y][x];
        }
    }
}

// выбор случайного типа фигуры
- (void) randomKind {
    self.kind = arc4random_uniform(fkCount - 1) + 1;
}

- (void) copyShapeFromFigure: (MVTetrisFigure *) aSource {
    for (int x = 0; x < 4; x++) {
        for (int y = 0; y < 4; y++) {
            _shape.figure[x][y] = aSource.shape.figure[x][y];
        }
    }
}

// клонирование текущей фигуры
- (MVTetrisFigure *) clone {
    MVTetrisFigure * res;
    res = [[MVTetrisFigure alloc] init];
    res.kind = self.kind;
    res.color = self.color;
    // обязательно копируем текущее положение фигуры (оно может отличаться от стандартного, после присвояния res.kind)
    [res copyShapeFromFigure: self];
    return res;
}


// прорисовка фигуры по координатам (координаты по вертикали переворачиваются)
- (void) drawFigureOnField: (MVTetrisView *) aField atX: (double) aX andY: (double) aY doDrawEmpty: (Boolean) aDoDrawEmpty {
    NSRect rect;
    float cellWidth = [aField bounds].size.width / (gameFieldWidth + 5);
    float cellHeight = [aField bounds].size.height / gameFieldHeight;
    for (int y = 0; y < 4; y++) {
        for (int x = 0; x < 4; x++) {
            rect = NSMakeRect( (aX + x ) * cellWidth , (gameFieldHeight - y - 1 - aY) * cellHeight, cellWidth, cellHeight);
            
            if ([self shape].figure[x][y]) {
                
                // ячейка занята
                [self.color drawInRect: rect fromRect: aField.cellRect operation: NSCompositeCopy fraction: 1.0f];
                
            } else {
                // или свободна
                
                // когда фигура рисуется на поле, пустые ячейки не нужно рисовать (затираются ячейки поля)
                if (aDoDrawEmpty) {
                    [aField.fieldImage drawInRect:rect fromRect: aField.cellRect operation: NSCompositeCopy fraction: 1.0f];
                }
            }
        }
    }
}

- (void) drawFigureOnField: (MVTetrisView *) aField atX: (int) aX andY: (int) aY {
    [self drawFigureOnField: aField atX: aX andY: aY doDrawEmpty: false];
}



@end
