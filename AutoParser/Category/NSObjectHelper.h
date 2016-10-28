

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <objc/message.h>

///------------------------------
/// @LiXiangCheng 20161022
/// 实现 dictionary<->model josn<->model
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

+ (NSDictionary *)classPropsFor:(Class)klass;
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
