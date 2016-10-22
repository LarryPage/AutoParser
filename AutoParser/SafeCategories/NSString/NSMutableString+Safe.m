//
//  NSMutableString+Safe.m
//  AutoParser
//
//  Created by LiXiangCheng on 16/10/22.
//  Copyright © 2016年 LiXiangCheng. All rights reserved.
//

#import "NSMutableString+Safe.h"
#import "NSString+Safe.h"

@implementation NSMutableString (Safe)

+ (NSMutableString *)safeStringFromObject:(id)obj
{
    NSString *ret=[NSString safeStringFromObject:obj];
    if (ret) {
        return [NSMutableString stringWithString:ret];
    }
    else{
        return nil;
    }
}

@end
