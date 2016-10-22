//
//  NSOrderedSet+Safe.m
//  AutoParser
//
//  Created by LiXiangCheng on 16/10/22.
//  Copyright © 2016年 LiXiangCheng. All rights reserved.
//

#import "NSOrderedSet+Safe.h"
#import "SafeCategories.h"

@implementation NSOrderedSet (Safe)

+ (NSOrderedSet *)safeOrderedSetFromObject:(id)obj;
{
    if ([obj isKindOfClass:[NSOrderedSet class]]) {
        return obj;
    } else if ([obj respondsToSelector:@selector(jsonValueDecoded)]) {
        id ret = [obj jsonValueDecoded];
        if ([ret isKindOfClass:[NSOrderedSet class]]) {
            return ret;
        }
    }
    else if([obj isKindOfClass:[NSNull class]]) {
        return nil;
    }
    return nil;
}

@end
