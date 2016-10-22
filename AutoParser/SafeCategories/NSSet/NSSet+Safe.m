//
//  NSSet+Safe.m
//  AutoParser
//
//  Created by LiXiangCheng on 16/10/22.
//  Copyright © 2016年 LiXiangCheng. All rights reserved.
//

#import "NSSet+Safe.h"
#import "SafeCategories.h"

@implementation NSSet (Safe)

+ (NSSet *)safeSetFromObject:(id)obj
{
    if ([obj isKindOfClass:[NSSet class]]) {
        return obj;
    } else if ([obj respondsToSelector:@selector(jsonValueDecoded)]) {
        id ret = [obj jsonValueDecoded];
        if ([ret isKindOfClass:[NSSet class]]) {
            return ret;
        }
    }
    else if([obj isKindOfClass:[NSNull class]]) {
        return nil;
    }
    return nil;
}

@end
