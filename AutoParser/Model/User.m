//
//  User.m
//  AutoParser
//
//  Created by LiXiangCheng on 16/9/16.
//  Copyright © 2016年 LiXiangCheng. All rights reserved.
//

#import "User.h"

@implementation User

#pragma mark override

+ (NSDictionary *)replacedKeyMap{
    NSMutableDictionary *map = [NSMutableDictionary dictionary];
    //[map safeSetObject:@"jsonKeyName" forKey:@"propertyName"];
    [map safeSetObject:@"avatar" forKey:@"icon"];
    return map;
    
//    return @{@"propertyName" : @"jsonKeyName",
//             @"desc" : @"desciption"
//             };

}

@end
