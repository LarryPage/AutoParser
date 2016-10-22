//
//  NSObject+Safe.m
//  AutoParser
//
//  Created by LiXiangCheng on 16/10/22.
//  Copyright © 2016年 LiXiangCheng. All rights reserved.
//

#import "NSObject+Safe.h"

@implementation NSObject (Safe)

+ (id)safeObjectFromObject:(id)obj
{
    if ([obj isKindOfClass:[NSNull class]]) {
#if DEBUG == 1
        NSAssert(NO, @"属性为null,查一下吧");
        return obj;
#else
        return nil;
#endif
    }
    return obj;
}

@end
