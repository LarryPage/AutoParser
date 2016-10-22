//
//  NSMutableArray+Safe.m
//  AutoParser
//
//  Created by LiXiangCheng on 16/10/22.
//  Copyright © 2016年 LiXiangCheng. All rights reserved.
//

#import "NSMutableArray+Safe.h"

@implementation NSMutableArray (Safe)

- (void)safeAddObject:(id)object
{
    if (object) {
        [self addObject:object];
    }
}

- (NSMutableArray *) reverse
{
    for (int i=0; i<(floor([self count]/2.0)); i++)
        [self exchangeObjectAtIndex:i withObjectAtIndex:([self count]-(i+1))];
    return self;
}

@end
