//
//  main.m
//  Tetris
//
//  Created by Igor Smirnov on 20.06.12.
//  Copyright (c) 2012 megavolt605@gmail.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>

int main(int argc, char *argv[])
{
    time_t t;
    time(&t);
    srand(t);
    return NSApplicationMain(argc, (const char **)argv);
}
