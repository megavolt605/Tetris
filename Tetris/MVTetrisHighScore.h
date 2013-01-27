//
//  MVHighScore.h
//  Tetris
//
//  Created by Igor Smirnov on 10.01.13.
//  Copyright (c) 2013 megavolt605@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MVTetrisHighScore : NSObject

+ (MVTetrisHighScore *) highScore: (NSNumber *) aScore;
+ (MVTetrisHighScore *) highScore: (NSNumber *) aScore forDate: (NSDate *) date;

@property NSDate * date;
@property NSNumber * score;

@end
