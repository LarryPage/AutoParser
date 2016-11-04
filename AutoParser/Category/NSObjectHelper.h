//
//  NSObject+AutoParser.h
//  AutoParser
//
//  Created by LiXiangCheng on 16/9/16.
//  Copyright (c) 2016年 Wanda Inc All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

///------------------------------
/// @LiXiangCheng 20161022
/// GitHub:https://github.com/LarryPage/AutoParser
/// 最大缓存500个Model定义,1个model按10个左右属性，大约0.1K，500个model点内存50K
/// 实现 dictionary<->model json<->model
/// 实现 模型序列化存储、读取、copy 【NSCoding NSCopying】
/// 使用 WDSafeCategories保证每条数据安全解析
///------------------------------

/**
 support :variable type
 
 double
 float
 int
 bool
 BOOL
 NSInteger
 NSUInteger
 NSNumber *
 NSString * NSMutableString *
 NSDictionary * NSMutableDictionary *
 NSArray * NSMutableArray *
 NSSet * NSMutableSet *
 NSOrderedSet * NSMutableOrderedSet *
 ...
 and 自定义model类
 */
@interface NSObject (KVC)

- (id)initWithDic:(NSDictionary *)dic;
- (NSDictionary *)dic;
- (id)initWithJson:(NSString *)json;
- (NSString *)json;

+ (void)KeyValueDecoderForObject:(id)object dic:(NSDictionary *)dic;
+ (void)KeyValueEncoderForObject:(id)object dic:(NSDictionary *)dic;

//recursive
+ (NSDictionary *) propertiesOfObject:(id)object;
+ (NSDictionary *) propertiesOfClass:(Class)klass;
+ (NSDictionary *) propertiesOfSubclass:(Class)klass;

#pragma mark NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder;
- (id)initWithCoder:(NSCoder *)aDecoder;

#pragma mark NSCopying
- (id)copyWithZone:(NSZone *)zone;
@end
