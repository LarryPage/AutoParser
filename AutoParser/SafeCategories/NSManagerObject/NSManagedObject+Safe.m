//
//  NSManagedObject+Safe.m
//  AutoParser
//
//  Created by LiXiangCheng on 16/10/22.
//  Copyright © 2016年 LiXiangCheng. All rights reserved.
//

#import "NSManagedObject+Safe.h"

@implementation NSManagedObject (Safe)

- (void)safeSetObject:(id)anObject forKey:(NSString *)aKey
{
    if (anObject == nil || aKey == nil)
    {
        return;
    }
    
    [self setValue:anObject forKey:aKey];
}
@end
