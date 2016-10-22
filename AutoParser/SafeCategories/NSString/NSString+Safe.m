//
//  NSString+Safe.m
//  AutoParser
//
//  Created by LiXiangCheng on 16/10/22.
//  Copyright © 2016年 LiXiangCheng. All rights reserved.
//

#import "NSString+Safe.h"
#import "SafeCategories.h"

@implementation NSString (Safe)

+ (NSString *)safeStringFromObject:(id)obj
{
    if (obj == nil) {
        return @"";
    }
    if ([obj isKindOfClass:[NSString class]]) {
        return obj;
    } else if ([obj isKindOfClass:[NSNumber class]]) {
        return [obj stringValue];
    }
    else if([obj isKindOfClass:[NSNull class]]) {
#if DEBUG == 1
        NSAssert(NO, @"属性为null,查一下吧");
        return obj;
#else
        return nil;
#endif
    }else if ([obj isKindOfClass:[NSArray class]] ||
              [obj isKindOfClass:[NSDictionary class]]) {
        return [obj performSelector:@selector(jsonStringEncoded)];
    } else {
        return [obj description];
    }
}

@end
