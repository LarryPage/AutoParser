//
//  NSNumber+Safe.m
//  AutoParser
//
//  Created by LiXiangCheng on 16/10/22.
//  Copyright © 2016年 LiXiangCheng. All rights reserved.
//

#import "NSNumber+Safe.h"

@implementation NSNumber (Safe)

+ (NSNumber *)safeNumberFromObject:(id)obj
{
    if ([obj isKindOfClass:[NSNumber class]]) {
        return obj;
    }
    if ([obj respondsToSelector:@selector(doubleValue)]) {
        return [NSNumber numberWithDouble:[obj doubleValue]];
    }
    if([obj isKindOfClass:[NSNull class]]) {
#if DEBUG == 1
        NSAssert(NO, @"属性为null,查一下吧");
        return obj;
#else
        return nil;
#endif
    }
    return nil;
}

+ (NSNumber *)safeDoubleNumberFromObject:(id)obj
{
    if ([obj isKindOfClass:[NSNumber class]]) {
        return obj;
    }
    if ([obj respondsToSelector:@selector(doubleValue)]) {
        return [NSNumber numberWithDouble:[obj doubleValue]];
    }
    return nil;
}

@end
