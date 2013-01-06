//
//  MVTetris.m
//  Tetris
//
//  Created by Igor Smirnov
//  Copyright (c) 2012 megavolt605@gmail.com. All rights reserved.
//

#import "MVTetris.h"

// размеры игрового поля
const int gameFieldWidth  = 16;
const int gameFieldHeight = 28;

@implementation MVTetris {
    NSColor * gameField [ gameFieldWidth ] [ gameFieldHeight ];     // цвета на поле
    Boolean gameFieldData [ gameFieldWidth ][ gameFieldHeight ];    // занятость клеток
    NSPoint currentPos;                                             // координаты текущей фигуры
    MVTetrisFigure * currentFigure;                                 // текущая фигура
    MVTetrisFigure * nextFigure;                                    // следующая фигура
    NSTimer * timerRedraw;                                          // таймер перерисовки
    NSTimer * timerGame;                                            // таймер игры
}

// инициализация
- (id) initWithFrame: (NSRect) frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self clearGame];
        self.inGame = [NSNumber numberWithBool: false];
        self.score = [NSNumber numberWithInt: 0];
        
        // инициализируем таймеры
        timerRedraw = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(tickRedraw:) userInfo:nil repeats:YES];
        timerGame = [NSTimer scheduledTimerWithTimeInterval:0.2f target:self selector:@selector(tickGame:) userInfo:nil repeats:YES];
        
        // создаем цвета фигур
        figureColors[fkJ] = [NSColor redColor]; 
        figureColors[fkL] = [NSColor greenColor]; 
        figureColors[fkLine] = [NSColor blueColor]; 
        figureColors[fkS] = [NSColor purpleColor]; 
        figureColors[fkSquare] = [NSColor yellowColor]; 
        figureColors[fkZ] = [NSColor cyanColor]; 
        figureColors[fkUnknown] = [NSColor whiteColor]; 
    }
    return self;
}

// очистка поля
- (void) clearGameField {
    for (int x = 0; x < gameFieldWidth; x++ ) {
        for (int y = 0; y < gameFieldHeight; y++ ) {
            gameField[x][y] = ((gameFieldData[x][y] = (x == 0) | (y == (gameFieldHeight - 1)) | (x == (gameFieldWidth - 1))) ? [NSColor blueColor] : [NSColor blackColor]);
            // конструкция строкой выше прикольная, но мне уж очень не нравится из-за плохой читаемости 
            // я бы написал так:
            // Boolean border = (x == 0) | (y == (gameFieldHeight - 1)) | (x == (gameFieldWidth - 1));
            // gameFieldData[x][y] = border;
            // gameField[x][y] = (border ? [NSColor blueColor] : [NSColor blackColor]);
            //
            // пытаюсь быть истинным СИшником :)
        }
    }
}

// прорисовка фигуры по координатам (координаты по вертикали переворачиваются)
- (void) drawFigure: (MVTetrisFigure *) figure atX: (int) ax andY: (int) ay doDrawEmpty: (Boolean) drawEmpty {
    NSBezierPath * p;
    float cellWidth = [self bounds].size.width / (gameFieldWidth + 5);
    float cellHeight = [self bounds].size.height / gameFieldHeight;
    for (int y = 0; y < 4; y++) {
        for (int x = 0; x < 4; x++) {
            p = [NSBezierPath bezierPathWithRect: NSMakeRect( (ax + x ) * cellWidth , (gameFieldHeight - y - 1 - ay) * cellHeight, cellWidth - 2, cellHeight - 2)];
            
            if ([figure shape].figure[x][y]) {
    
                // ячейка занята
                [[figure color] set];
                [p fill];
                [p stroke];

            } else {
                // или свободна
                
                // когда фигура рисуется на поле, пустые ячейки не нужно рисовать (затираются ячейки поля)
                if (drawEmpty) {
                    [[NSColor blackColor] set];
                    [p fill];
                    [p stroke];
                }
            }
        }
    }
}

- (void) drawFigure: (MVTetrisFigure *) figure atX: (int) ax andY: (int) ay {
    [self drawFigure: figure 
                 atX: ax 
                andY: ay
         doDrawEmpty: false];
}

// отрисовка игрового поля
- (void) drawGameField {
    NSBezierPath * p;
    float cellWidth = [self bounds].size.width / (gameFieldWidth + 5);
    float cellHeight = [self bounds].size.height / gameFieldHeight;
    int x, y;
    
    for (y = 0; y < gameFieldHeight; y++) {
        for (x  = 0; x < gameFieldWidth; x++) {
            [gameField[x][y] set];
            p = [NSBezierPath bezierPathWithRect:NSMakeRect(x * cellWidth, (gameFieldHeight - y - 1) * cellHeight, cellWidth - 2, cellHeight - 2)];
            [p fill];
            [p stroke];
        }
    } 
}

// отрисовка вида
- (void) drawRect:(NSRect)dirtyRect {
    [self drawGameField];
    
    // рисуем следующую фигуру
    [self drawFigure: nextFigure 
                 atX: gameFieldWidth + 1
                andY: 0
         doDrawEmpty:true];
    
    // если в игре, рисуем текущую фигуру
    if ([_inGame boolValue]) {
        [self drawFigure: currentFigure
                     atX: currentPos.x
                    andY: currentPos.y];
    }
}

// проверка пересечения текущей фигуры с уже занятыми ячейками игрового поля
- (bool) checkIntersectFigure: (MVTetrisFigure *) figure atX: (int) x andY: (int) y {   
    int cx, cy;
    
    for (int vx = 0; vx < 4; vx++) {
        cx = x + vx;
        for (int vy = 0; vy < 4; vy++) {
            cy = y + vy;
            // охрана от выхода за пределы поля
            if ((cx >= 0) & (cx < gameFieldWidth) & (cy >= 0) & (cy < gameFieldHeight)) {
                if ((gameFieldData[cx][cy]) & (figure.shape.figure[vx][vy])) {
                    return true;
                }
            }
        }
    }
    return false;
}

// объясняем, что мы хотим обрабатывать события
- (BOOL) acceptsFirstResponder {
    return true;
}

// нажата какая-либо кнопка
- (void) keyDown: (NSEvent *) theEvent {
    [self interpretKeyEvents:[NSArray arrayWithObject:theEvent]];
}

// событие: кнопка вверх
- (IBAction) moveUp: (id) sender {
    
    MVTetrisFigure * test;
    
    // проверка, что после переворота нашей фигуре есть место на игровом поле (нет пересечений с занятыми клетками)
    // для этого клонируем фигуру
    test = [currentFigure clone];
    
    // поворачиваем
    [test rotate];
    
    // проверяем
    if (! [self checkIntersectFigure:test atX:currentPos.x andY:currentPos.y]) {
        // ок, можно повернуть основную фигуру
        [currentFigure rotate];
    }
}

// событие: кнопка вниз
- (IBAction) moveDown: (id) sender {
    // нам надо спрогнозировать падение текущей фигуры до первого "наложения"
    Boolean found = false;
    int y = currentPos.y;
    while (!found) {
        if ([self checkIntersectFigure:currentFigure atX:currentPos.x andY:y + 1]) {
            found = true;
            break;
        }
        y++;
    }
    
    // в принципе, должны найти всегда, т.к. низ стакана не пустой но на всякий случай - проверка
    if (found)
        currentPos.y = y; // все остальное (фиксирование фигуры, пр. произойдет по тику таймера)
    else 
        NSLog(@"Падение: Я не должен увидеть это в протоколе");
    
}

// событие: кнопка влево
- (IBAction) moveLeft: (id) sender {
    // перемещение возможно только без пересечений с занятыми клетками
    if (! [self checkIntersectFigure:currentFigure atX:currentPos.x-1 andY:currentPos.y]) 
        currentPos.x--;
}

// событие: кнопка вправо
- (IBAction) moveRight: (id) sender {
    // перемещение возможно только без пересечений с занятыми клетками
    if (! [self checkIntersectFigure:currentFigure atX:currentPos.x+1 andY:currentPos.y]) 
        currentPos.x++;
}

// событие: таймер перерисовки
- (void) tickRedraw:(id)sender {
    [self setNeedsDisplay:true];
}

// остановить падение: зафиксировать текущую по текущим координатам на поле, 
// проверить наличие на поле полностью занятых строк, 
// осуществить сжатие игрового поля из-за полностью занятых линий, если таковые есть
- (void) stopFall {
    int cx, cy;
    int vx, vy;
    
    // фиксация текущей фигуры
    for (vx = 0; vx < 4; vx++) {
        cx = currentPos.x + vx;
        if ( (cx >= 0) & (cx < gameFieldWidth)) {
            for (vy = 0; vy < 4; vy++) {
                cy = currentPos.y + vy;
                if ( (cy >= 0) & (cy < gameFieldHeight) & (currentFigure.shape.figure[vx][vy]) ) {
                    gameField[cx][cy] = [currentFigure color];
                    gameFieldData[cx][cy] = true;
                }
            }
        }
    }
    
    // ищем заполненные линии
    for (vy = 0; vy < (gameFieldHeight-1); vy++) {
        
        // проверяем
        Boolean lineIsFull = true;
        for (vx = 1; vx < (gameFieldWidth-1); vx++) {
            lineIsFull = lineIsFull & (gameFieldData[vx][vy]);
            if (!lineIsFull) 
                break;
        }
        
        // нашли полностью заполненную линию
        if (lineIsFull) {
            self.score = [NSNumber numberWithInt: _score.integerValue + 5];
            
            // сжатие (стакан не сжимаем)
            for (cy = vy - 1; cy >= 0; cy--) {
                for (cx = 1; cx < (gameFieldWidth - 1); cx++) {
                    gameField[cx][cy + 1] = gameField[cx][cy];
                    gameFieldData[cx][cy + 1] = gameFieldData[cx][cy];
                }
            }
            
            // обнуляем верхнюю строку (без границ справа и слева)
            for (cx = 1; cx < (gameFieldWidth - 1); cx++) {
                gameField[cx][0] = [NSColor blackColor];
                gameFieldData[cx][0] = false;
            }
        }
    }
}

// сделать текущую фигуру из следующей, случайно выбрать форму и цвет следующей
- (void) newFigure {
    currentFigure = nextFigure;
    nextFigure = [[MVTetrisFigure alloc] init];
    [nextFigure randomKind];
    currentPos = NSMakePoint((gameFieldWidth - 4) / 2, 0);
}

// событие: таймер игры
- (void) tickGame:(id)sender; {
    if ([_inGame boolValue]) {
        
        // если фигура, переместясь вниз на клетку будет пересекаться с занятыми ячейками на поле, 
        // то нужно ее зафиксировать, сделать текущей фигуру на базе следующей, сгенерировать следующую фигуру
        if ([self checkIntersectFigure:currentFigure atX:currentPos.x andY:currentPos.y + 1]) {
            [self stopFall];
            [self newFigure];
            
            // проверка конца игры: новая фигура на начальном месте пересекается с имеющемися ячейками
            if ([self checkIntersectFigure:currentFigure atX:currentPos.x andY:currentPos.y]) {
                [self stopGame:nil];
            } else {
                // все ок, прибавляем очки и обновляем их в окне
                self.score = [NSNumber numberWithInt: _score.integerValue + 1];
            }
        } else 
            // просто перемещаем вниз
            currentPos.y++;        
    }
}

// очистка состояния игры
- (void) clearGame {
    [self clearGameField];
    nextFigure = [[MVTetrisFigure alloc] init];
    [nextFigure randomKind];
    self.score = [NSNumber numberWithInt: 0];
}

// остановка игры
- (IBAction) stopGame:(id)sender {
    self.inGame = [NSNumber numberWithBool: false];
    [labelTitleScore setStringValue: @"Final score:"];
}

// начало новой игры
- (IBAction) newGame:(id)sender {
    [self clearGame];
    [self newFigure];
    [labelTitleScore setStringValue: @"Score:"];
    self.inGame = [NSNumber numberWithBool: true];
}

@end
