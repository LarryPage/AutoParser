//
//  NSData+Add.m
//  AutoParser
//
//  Created by LiXiangCheng on 16/10/22.
//  Copyright © 2016年 LiXiangCheng. All rights reserved.
//

#import "NSData+Add.h"

@implementation NSData (Add)

- (id)jsonValueDecoded {
    NSError *error = nil;
    id value = [NSJSONSerialization JSONObjectWithData:self options:kNilOptions error:&error];
    if (error) {
        NSLog(@"jsonValueDecoded error:%@", error);
    }
    return value;
}

@end
