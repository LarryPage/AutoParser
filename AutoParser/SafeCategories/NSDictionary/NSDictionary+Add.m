//
//  NSDictionary+Add.m
//  AFNetworking
//
//  Created by LiXiangCheng on 2018/8/27.
//

#import "NSDictionary+Add.h"

@implementation NSDictionary (Add)

/**
 NSDictionary转换为JSON
 
 @return NSString
 */

- (NSString *)jsonStringEncoded {
    if ([NSJSONSerialization isValidJSONObject:self]) {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:0 error:&error];
        if(!error){
            NSString *json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            return json;
        }
    }
    return nil;
}

@end
