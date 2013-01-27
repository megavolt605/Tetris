//
//  MVHighScore.m
//  Tetris
//
//  Created by Igor Smirnov on 10.01.13.
//  Copyright (c) 2013 megavolt605@gmail.com. All rights reserved.
//

#import "MVTetrisHighScore.h"

@implementation MVTetrisHighScore

+ (MVTetrisHighScore *) highScore: (NSNumber *) aScore {
    return [MVTetrisHighScore highScore: aScore forDate: [NSDate date]];
}

+ (MVTetrisHighScore *) highScore: (NSNumber *) aScore forDate: (NSDate *) date {
    MVTetrisHighScore * result = [[MVTetrisHighScore alloc] init];
    result.score = aScore;
    result.date = date;
    return result;
}

- (MVTetrisHighScore *) init {
    if (self = [super init]) {
        self.date = [NSDate date];
        self.score = [NSNumber numberWithInt: 0];
    }
    return self;
}

@end
