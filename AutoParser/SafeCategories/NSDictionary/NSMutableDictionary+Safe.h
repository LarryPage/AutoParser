//
//  NSMutableDictionary+Safe.h
//  AutoParser
//
//  Created by LiXiangCheng on 16/10/22.
//  Copyright © 2016年 LiXiangCheng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (Safe)

/**
 *  替换setObject:forKey | safeSetObject:ForKey:
 */
- (void)safeSetObject:(id)anObject forKey:(id<NSCopying>)aKey;

- (void)setObject:(id)anObject defaultObject:(id)defaultObject forKey:(id <NSCopying>)aKey;

- (void)safeSetObject:(id)value defaultValue:(id)defaultValue forKey:(NSString *)key;

+ (NSMutableDictionary *)safeDictionaryFromObject:(id)obj;
@end
