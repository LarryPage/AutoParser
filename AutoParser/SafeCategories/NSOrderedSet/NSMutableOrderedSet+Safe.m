//
//  NSMutableOrderedSet+Safe.m
//  AutoParser
//
//  Created by LiXiangCheng on 16/10/22.
//  Copyright © 2016年 LiXiangCheng. All rights reserved.
//

#import "NSMutableOrderedSet+Safe.h"

@implementation NSMutableOrderedSet (Safe)

- (void)safeAddObject:(id)object
{
    if (object) {
        [self addObject:object];
    }
}

@end
