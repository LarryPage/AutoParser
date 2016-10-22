//
//  NSMutableSet+Safe.m
//  AutoParser
//
//  Created by LiXiangCheng on 16/10/22.
//  Copyright © 2016年 LiXiangCheng. All rights reserved.
//

#import "NSMutableSet+Safe.h"

@implementation NSMutableSet (Safe)

- (void)safeAddObject:(id)object
{
    if (object) {
        [self addObject:object];
    }
}

@end
