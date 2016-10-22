//
//  NSDictionary+Safe.m
//  AutoParser
//
//  Created by LiXiangCheng on 16/10/22.
//  Copyright © 2016年 LiXiangCheng. All rights reserved.
//

#import "NSDictionary+Safe.h"
#import "SafeCategories.h"

@implementation NSDictionary (Safe)

- (void)safeSetObject:(id)anObject forKey:(NSString *)aKey
{
    if (anObject == nil || aKey == nil)
    {
        return;
    } 

    [self setValue:anObject forKey:aKey];
}

+ (NSDictionary *)safeDictionaryFromObject:(id)obj
{
    if ([obj isKindOfClass:[NSDictionary class]]) {
        return obj;
    } else if ([obj respondsToSelector:@selector(jsonValueDecoded)]) {
        id ret = [obj jsonValueDecoded];
        if ([ret isKindOfClass:[NSDictionary class]]) {
            return ret;
        }
    }
    else if([obj isKindOfClass:[NSNull class]]) {
        return nil;
    }
    return nil;
}
@end
