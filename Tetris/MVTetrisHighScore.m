//
//  MVHighScore.m
//  Tetris
//
//  Created by Igor Smirnov on 10.01.13.
//  Copyright (c) 2013 megavolt605@gmail.com. All rights reserved.
//

#import "MVTetrisHighScore.h"

@implementation MVTetrisHighScore

- (MVTetrisHighScore *) init {
    if (self = [super init]) {
        _date = [NSDate date];
        _score = 0;
    }
    return self;
}

@end
