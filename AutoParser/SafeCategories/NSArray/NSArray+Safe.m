//
//  NSArray+Safe.m
//  AutoParser
//
//  Created by LiXiangCheng on 16/10/22.
//  Copyright © 2016年 LiXiangCheng. All rights reserved.
//

#import "NSArray+Safe.h"
#import "SafeCategories.h"

@implementation NSArray (Safe)

- (id)safeObjectAtIndex:(NSUInteger)index
{
    if (index < self.count) {
        return self[index];
    }
    return nil;
}

+ (NSArray *)safeArrayFromObject:(id)obj
{
    if ([obj isKindOfClass:[NSArray class]]) {
        return obj;
    } else if ([obj respondsToSelector:@selector(jsonValueDecoded)]) {
        id ret = [obj jsonValueDecoded];
        if ([ret isKindOfClass:[NSArray class]]) {
            return ret;
        }
    }
    else if([obj isKindOfClass:[NSNull class]]) {
        return nil;
    }
    return nil;
}

@end
