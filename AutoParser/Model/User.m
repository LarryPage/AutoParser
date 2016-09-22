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

//-(id) init{
//    self = [super init];
//    if (self) {
//        // Initialization code
//    }
//    return self;
//}

- (id)initWithDic:(NSDictionary *)dic{
    self = [super initWithDic:dic];
    self.icon = RKMapping(dic[@"avatar"]);//key替换
    return self;
}

- (NSDictionary *)dic{
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[super dic]];
    [dic removeObjectForKey:@"icon"];
    [dic setValue:self.icon forKey:@"avatar"];//key替换
    return dic;
}

@end
