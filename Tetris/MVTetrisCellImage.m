//
//  MVTetrisCellImage.m
//  Tetris
//
//  Created by Igor Smirnov on 31.01.13.
//  Copyright (c) 2013 megavolt605@gmail.com. All rights reserved.
//

#import "MVTetrisCellImage.h"

@implementation MVTetrisCellImage

- (NSRect) cellRect {
    return NSMakeRect(0, 0, self.size.width + 1, self.size.height + 1);
}

@end
