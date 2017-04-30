//
//  User.m
//  AutoParser
//
//  Created by LiXiangCheng on 16/9/16.
//  Copyright © 2016年 LiXiangCheng. All rights reserved.
//

#import "User.h"

@JSONImplementation(User)

#pragma mark override

-(id) init{
    self = [super init];
    if (self) {
        // Initialization code
        self.height=@"173";//默认值
    }
    return self;
}

+ (NSDictionary *)replacedKeyMap{
    NSMutableDictionary *map = [NSMutableDictionary dictionary];
    //[map safeSetObject:@"jsonKeyName" forKey:@"propertyName"];
    [map safeSetObject:@"avatar" forKey:@"icon"];
    return map;
    
//    return @{@"propertyName" : @"jsonKeyName",
//             @"icon" : @"avatar"
//             };

}

+ (NSArray *)ignoredParserPropertyNames{
    return [NSArray arrayWithObjects:@"fat", nil];
}

+ (NSArray *)ignoredCodingPropertyNames{
    return [NSArray arrayWithObjects:@"fat", nil];
}

@end
