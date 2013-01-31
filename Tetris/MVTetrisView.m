//
//  MVTetris.m
//  Tetris
//
//  Created by Igor Smirnov
//  Copyright (c) 2012 megavolt605@gmail.com. All rights reserved.
//

#import "MVTetrisView.h"
#import "MVTetrisPreferencesWindowController.h"
#import "MVTetrisHighScore.h"
#import "NSImage+Tetris.h"

// размеры игрового поля
const int gameFieldWidth  = 16;
const int gameFieldHeight = 28;
const int linesToLevelUp = 3;

@implementation MVTetrisView {
    NSImage * gameField [gameFieldWidth] [gameFieldHeight];     // цвета на поле
    Boolean gameFieldData [gameFieldWidth] [gameFieldHeight];   // занятость клеток
    NSPoint currentPos;                                         // координаты текущей фигуры
    MVTetrisFigure * currentFigure;                             // текущая фигура
    MVTetrisFigure * nextFigure;                                // следующая фигура
    NSTimer * timerRedraw;                                      // таймер перерисовки
    NSTimer * timerGame;                                        // таймер игры
    NSTimer * timerLinesDissapear;
    NSMutableArray * filledLinesIndexes;
    float currentDisappearOpacity;
}

// инициализация
- (id) initWithFrame: (NSRect) frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.inGame = @NO;
        
        // создаем картинки
        figureImages[fkJ] = [NSImage imageNamed: @"Tetris_Blue.png"];
        figureImages[fkL] = [NSImage imageNamed: @"Tetris_Brown.png"];
        figureImages[fkI] = [NSImage imageNamed: @"Tetris_Cyan.png"];
        figureImages[fkS] = [NSImage imageNamed: @"Tetris_Green.png"];
        figureImages[fkO] = [NSImage imageNamed: @"Tetris_Yellow.png"];
        figureImages[fkZ] = [NSImage imageNamed: @"Tetris_Red.png"];
        figureImages[fkT] = [NSImage imageNamed: @"Tetris_Magenta.png"];
        
        _wallImage = [NSImage imageNamed: @"Tetris_Gray.png"];
        _fieldImage = [NSImage imageNamed: @"Tetris_Black.png"];
        
        // инициализируем таймер перерисовки
        timerRedraw = [NSTimer scheduledTimerWithTimeInterval: 0.05f
                                                       target: self
                                                     selector: @selector(tickRedraw:)
                                                     userInfo: nil
                                                      repeats: true];
        
        filledLinesIndexes = [NSMutableArray arrayWithCapacity: gameFieldHeight];
        
        [self clearGame];
    }
    return self;
}

// очистка поля
- (void) clearGameField {
    // поле
    memset(gameFieldData, 0, sizeof(gameFieldData));

    for (NSInteger x = 1; x < gameFieldWidth - 1; x++ ) {
        for (NSInteger y = 0; y < gameFieldHeight; y++ ) {
            gameField[x][y] = self.fieldImage;
        }
    }
    
    // стенки стакана (вертикальные)
    for (NSInteger y = 0; y < gameFieldHeight; y++ ) {
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
    NSInteger x, y;
    
    for (y = 0; y < gameFieldHeight; y++) {
        for (x  = 0; x < gameFieldWidth; x++) {

            float fraction = 1.0f; // прозрачность клетки
            
            // если мы на стадии "исчезновения" линий, то устанавливаем текущую прозрачность (кроме стенок)
            if ([timerLinesDissapear isValid] & (x != 0) & (x != (gameFieldWidth-1))) {
                if ([filledLinesIndexes indexOfObject: [NSNumber numberWithInteger: y]] != NSNotFound) {
                    fraction = currentDisappearOpacity;
                }
            }
            
            // отрисовка теккущей ячейки
            NSImage * cell = gameField[x][y];
            [cell drawInRect: NSMakeRect(x * cellWidth, (gameFieldHeight - y - 1) * cellHeight, cellWidth, cellHeight)
                               fromRect: [cell cellRect]
                              operation: NSCompositeCopy
                               fraction: fraction];
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
- (bool) checkIntersectFigure: (MVTetrisFigure *) figure atX: (NSInteger) x andY: (NSInteger) y {   
    NSInteger cx, cy;
    
    for (NSInteger vx = 0; vx < 4; vx++) {
        cx = x + vx;
        for (NSInteger vy = 0; vy < 4; vy++) {
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
    
    MVTetrisFigure * testFigure;
    
    // проверка, что после переворота нашей фигуре есть место на игровом поле (нет пересечений с занятыми клетками)
    // для этого клонируем фигуру
    testFigure = [currentFigure clone];
    
    // поворачиваем
    [testFigure rotate];
    
    // проверяем
    if (! [self checkIntersectFigure: testFigure atX: currentPos.x andY: currentPos.y]) {
        // ок, можно повернуть основную фигуру
        [currentFigure rotate];
    }
}

// событие: кнопка вниз
- (IBAction) moveDown: (id) sender {
    // нам надо спрогнозировать падение текущей фигуры до первого "наложения"
    Boolean found = false;
    NSInteger y = currentPos.y;
    while (!found) {
        if ([self checkIntersectFigure: currentFigure atX: currentPos.x andY: y + 1]) {
            found = true;
            break;
        }
        y++;
    }
    
    // в принципе, должны найти всегда, т.к. низ стакана не пустой но на всякий случай - проверка
    if (found) {
        currentPos.y = y; // все остальное (фиксирование фигуры, пр. произойдет по тику таймера)
        [timerGame fire];
    } else {
        NSLog(@"Падение: Я не должен увидеть это в протоколе");
    }
}

// событие: кнопка влево
- (IBAction) moveLeft: (id) sender {
    // перемещение возможно только без пересечений с занятыми клетками
    if (! [self checkIntersectFigure: currentFigure atX: currentPos.x - 1 andY: currentPos.y])
        currentPos.x--;
}

// событие: кнопка вправо
- (IBAction) moveRight: (id) sender {
    // перемещение возможно только без пересечений с занятыми клетками
    if (! [self checkIntersectFigure: currentFigure atX: currentPos.x+1 andY: currentPos.y]) 
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
    NSInteger cx, cy;
    NSInteger vx, vy;
    
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
    
    [filledLinesIndexes removeAllObjects];
    
    // ищем заполненные линии
    for (vy = 0; vy < (gameFieldHeight-1); vy++) {
        
        // проверяем
        Boolean lineIsFull = true;
        for (vx = 1; vx < (gameFieldWidth-1); vx++) {
            lineIsFull = lineIsFull & (gameFieldData[vx][vy]);
            if (!lineIsFull) 
                break;
        }
        
        // нашли полностью заполненную линию, запоминаем
        if (lineIsFull) {
            [filledLinesIndexes addObject: [NSNumber numberWithInteger: vy]];
        }
    }
    
    // если есть заполненные линии
    if (filledLinesIndexes.count) {
        
        // обновляем статистику
        self.score = [NSNumber numberWithInt: self.score.integerValue + 5 * filledLinesIndexes.count];
        
        for (vx = self.lines.integerValue + 1; vx <= self.lines.integerValue + filledLinesIndexes.count; vx++) {
            
            // при необходимости увеличиваем уровень
            if ((vx % linesToLevelUp) == 0) {
                self.level = [NSNumber numberWithInt: self.level.integerValue + 1];
            }
        }
        
        self.lines = [NSNumber numberWithInt: self.lines.integerValue + filledLinesIndexes.count];
        
        // ставим игру на паузу
        [timerGame invalidate];
        
        // запускаем таймер для отрисовки "исчезновения" заполненных линий
        currentDisappearOpacity = 1.0f;
        timerLinesDissapear = [NSTimer scheduledTimerWithTimeInterval: 0.03f
                                                               target: self
                                                             selector: @selector(tickLineDissapear:)
                                                             userInfo: nil
                                                              repeats: true];
    }
}

- (void) tickLineDissapear: (id) sender {
    if (currentDisappearOpacity >= 0.0f) {
        currentDisappearOpacity = currentDisappearOpacity - 0.1f;
        [self setNeedsDisplay: true];
    } else {
        [timerLinesDissapear invalidate];
        
        for (int i = 0; i < filledLinesIndexes.count; i++) {
            NSInteger vy = [[filledLinesIndexes objectAtIndex: i] integerValue];
            
            // сжатие (стакан не сжимаем)
            for (NSInteger cy = vy - 1; cy >= 0; cy--) {
                for (NSInteger cx = 1; cx < (gameFieldWidth - 1); cx++) {
                    gameField[cx][cy + 1] = gameField[cx][cy];
                    gameFieldData[cx][cy + 1] = gameFieldData[cx][cy];
                }
            }
            
            // обнуляем верхнюю строку (без границ справа и слева)
            for (int cx = 1; cx < (gameFieldWidth - 1); cx++) {
                gameField[cx][0] = _fieldImage;
                gameFieldData[cx][0] = false;
            }
        }
            
        float gameTick = (self.level.integerValue < 10) ? 1.0f - (self.level.floatValue / 10.0f) : 0.1f;
        
        timerGame = [NSTimer scheduledTimerWithTimeInterval: gameTick
                                                     target: self
                                                   selector: @selector(tickGame:)
                                                   userInfo: nil
                                                    repeats: true];
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
                self.score = [NSNumber numberWithInt: self.score.integerValue + 1];
                self.figures = [NSNumber numberWithInt: self.figures.integerValue + 1];
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
    self.level = @1;
    self.score = @0;
    self.figures = @0;
    self.lines = @0;
    [labelTitleScore setStringValue: @"Очки:"];

}

// остановка игры
- (IBAction) stopGame:(id)sender {
    self.inGame = @NO;
    NSMutableArray * scores = highScoresPreferencesController.highScores;
    [scores insertObject: [MVTetrisHighScore highScore: self.score] atIndex: 0];
    highScoresPreferencesController.highScores = scores;
    [timerGame invalidate];
    timerGame = nil;
}

// начало новой игры
- (IBAction) newGame:(id)sender {
    [self clearGame];
    [self newFigure];
    [labelTitleScore setStringValue: @"Очки:"];
    self.inGame = @YES;
    timerGame = [NSTimer scheduledTimerWithTimeInterval: 1.0f
                                                 target: self
                                               selector: @selector(tickGame:)
                                               userInfo: nil
                                                repeats: true];
}

// отображение / скрытие окна с результатами игр
- (IBAction) highScores:(id)sender {
    [highScoresDrawer toggle: self];
}

@end
