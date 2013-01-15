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
    NSImage * gameField [gameFieldWidth] [gameFieldHeight];     // цвета на поле
    Boolean gameFieldData [gameFieldWidth] [gameFieldHeight];   // занятость клеток
    NSPoint currentPos;                                         // координаты текущей фигуры
    MVTetrisFigure * currentFigure;                             // текущая фигура
    MVTetrisFigure * nextFigure;                                // следующая фигура
    NSTimer * timerRedraw;                                      // таймер перерисовки
    NSTimer * timerGame;                                        // таймер игры
}

// инициализация
- (id) initWithFrame: (NSRect) frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.inGame = [NSNumber numberWithBool: false];
        
        // создаем картинки
        figureImages[fkJ] = [NSImage imageNamed: @"Tetris_01.png"];
        figureImages[fkL] = [NSImage imageNamed: @"Tetris_02.png"];
        figureImages[fkLine] = [NSImage imageNamed: @"Tetris_03.png"];
        figureImages[fkS] = [NSImage imageNamed: @"Tetris_04.png"];
        figureImages[fkSquare] = [NSImage imageNamed: @"Tetris_05.png"];
        figureImages[fkZ] = [NSImage imageNamed: @"Tetris_06.png"];
        
        _wallImage = [NSImage imageNamed: @"Tetris_07.png"];
        _fieldImage = [NSImage imageNamed: @"Tetris_08.png"];
        
        // инициализируем таймеры
        timerRedraw = [NSTimer scheduledTimerWithTimeInterval: 0.1f target: self selector: @selector(tickRedraw:) userInfo: nil repeats: true];
        timerGame = [NSTimer scheduledTimerWithTimeInterval: 0.2f target: self selector: @selector(tickGame:) userInfo: nil repeats: true];
        
        [self clearGame];
    }
    return self;
}

// очистка поля
- (void) clearGameField {
    // поле
    memset(gameFieldData, 0, sizeof(gameFieldData));

    for (int x = 1; x < gameFieldWidth - 1; x++ ) {
        for (int y = 0; y < gameFieldHeight; y++ ) {
            gameField[x][y] = self.fieldImage;
        }
    }
    
    // стенки стакана (вертикальные)
    for (int y = 0; y < gameFieldHeight; y++ ) {
        gameField[0][y] = gameField[gameFieldWidth - 1][y] = self.wallImage;
        gameFieldData[0][y] = true;

        gameField[gameFieldWidth - 1][y] = gameField[gameFieldWidth - 1][y] = self.wallImage;
        gameFieldData[gameFieldWidth - 1][y] = true;
    }
    
    // дно стакана
    for (int x = 1; x < gameFieldWidth - 1; x++ ) {
        gameField[x][gameFieldHeight - 1] = self.wallImage;
        gameFieldData[x][gameFieldHeight - 1] = true;
    }
}

// отрисовка игрового поля
- (void) drawGameField {
    float cellWidth = [self bounds].size.width / (gameFieldWidth + 5);
    float cellHeight = [self bounds].size.height / gameFieldHeight;
    int x, y;
    
    for (y = 0; y < gameFieldHeight; y++) {
        for (x  = 0; x < gameFieldWidth; x++) {
            [gameField[x][y] drawInRect: NSMakeRect(x * cellWidth, (gameFieldHeight - y - 1) * cellHeight, cellWidth, cellHeight)
                               fromRect: [self cellRect]
                              operation: NSCompositeCopy
                               fraction: 1.0f];
        }
    } 
}

// отрисовка вида
- (void) drawRect:(NSRect)dirtyRect {
    [self drawGameField];
    
    // рисуем следующую фигуру
    [nextFigure drawFigureOnField: self atX: gameFieldWidth + 1 andY: 0 doDrawEmpty: true];
    
    // если в игре, рисуем текущую фигуру
    if ([_inGame boolValue]) {
        [currentFigure drawFigureOnField: self atX: currentPos.x andY: currentPos.y];
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
            self.lines = [NSNumber numberWithInt: _lines.integerValue + 1];
            
            // сжатие (стакан не сжимаем)
            for (cy = vy - 1; cy >= 0; cy--) {
                for (cx = 1; cx < (gameFieldWidth - 1); cx++) {
                    gameField[cx][cy + 1] = gameField[cx][cy];
                    gameFieldData[cx][cy + 1] = gameFieldData[cx][cy];
                }
            }
            
            // обнуляем верхнюю строку (без границ справа и слева)
            for (cx = 1; cx < (gameFieldWidth - 1); cx++) {
                gameField[cx][0] = _fieldImage;
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
                self.figures = [NSNumber numberWithInt: _figures.integerValue + 1];
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
    self.figures = [NSNumber numberWithInt: 0];
    self.lines = [NSNumber numberWithInt: 0];
    [labelTitleScore setStringValue: @"Очки:"];
}

// остановка игры
- (IBAction) stopGame:(id)sender {
    self.inGame = [NSNumber numberWithBool: false];
}

// начало новой игры
- (IBAction) newGame:(id)sender {
    [self clearGame];
    [self newFigure];
    [labelTitleScore setStringValue: @"Очки:"];
    self.inGame = [NSNumber numberWithBool: true];
}

- (IBAction) highScores:(id)sender {
    [highScoresDrawer toggle: self];
}

- (NSRect) cellRect {
    return NSMakeRect(0, 0, self.fieldImage.size.width + 1, self.fieldImage.size.height + 1);
}

@end
