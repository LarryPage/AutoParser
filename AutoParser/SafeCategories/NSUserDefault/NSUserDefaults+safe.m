//
//  NSUserDefaults+safe.m
//  AutoParser
//
//  Created by LiXiangCheng on 16/10/22.
//  Copyright © 2016年 LiXiangCheng. All rights reserved.
//

#import "NSUserDefaults+safe.h"

@implementation NSUserDefaults (safe)

- (void)safeSetObject:(id)anObject forKey:(NSString *)aKey
{
    if ( aKey == nil)
    {
        return;
    }
    else if (anObject == nil )
    {
        [self removeObjectForKey:aKey];
    }
    else
    {
        [self setObject:anObject forKey:aKey];
    }
}

@end
