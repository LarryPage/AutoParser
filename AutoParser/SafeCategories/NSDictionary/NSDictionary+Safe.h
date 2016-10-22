//
//  NSDictionary+Safe.h
//  AutoParser
//
//  Created by LiXiangCheng on 16/10/22.
//  Copyright © 2016年 LiXiangCheng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Safe)

- (void)safeSetObject:(id)anObject forKey:(NSString *)aKey;
+ (NSDictionary *)safeDictionaryFromObject:(id)obj;

@end
