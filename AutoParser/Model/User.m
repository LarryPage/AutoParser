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

/**
*  nativePropertyName and JosnKeyName are different ,replace them in initWithDic()
*/
- (id)initWithDic:(NSDictionary *)dic{
    self = [super initWithDic:dic];
    self.icon = [NSString safeStringFromObject:[dic objectForKey:@"avatar"]];//key替换
    return self;
}

/**
 *  nativePropertyName and JosnKeyName are different ,replace them in dic()
 */
- (NSDictionary *)dic{
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[super dic]];
    [dic removeObjectForKey:@"icon"];
    if(self.icon != nil){
        [dic safeSetObject:self.icon forKey:@"avatar"];//key替换
    }
    return dic;
}

@end
