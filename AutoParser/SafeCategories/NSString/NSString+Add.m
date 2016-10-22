//
//  NSString+Add.m
//  AutoParser
//
//  Created by LiXiangCheng on 16/10/22.
//  Copyright © 2016年 LiXiangCheng. All rights reserved.
//

#import "NSString+Add.h"
#import "NSData+Add.h"

@implementation NSString (Add)

- (id)jsonValueDecoded {
    return [[self dataValue] jsonValueDecoded];
}

- (NSData *)dataValue {
    return [self dataUsingEncoding:NSUTF8StringEncoding];
}

@end
