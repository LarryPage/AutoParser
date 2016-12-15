//
//  NSObject+AutoParser.h
//  AutoParser
//
//  Created by LiXiangCheng on 16/9/16.
//  Copyright (c) 2016年 Wanda Inc All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

#define JSONInterface(class) protocol class <NSObject> @end\
@interface AutuParser(class)<class> @end\
@implementation AutuParser(class) @end\
@interface class

#define JSONArray(type) NSArray<type>
#define JSONMutableArray(type) NSMutableArray<type>

#define JSONSet(type) NSSet<type>
#define JSONMutableSet(type) NSMutableSet<type>

#define JSONOrderedSet(type) NSOrderedSet<type>
#define JSONMutableOrderedSet(type) NSMutableOrderedSet<type>

@protocol NSNumber <NSObject> @end
@protocol NSString <NSObject> @end
@protocol NSMutableString <NSObject> @end
@protocol NSDictionary <NSObject> @end
@protocol NSMutableDictionary <NSObject> @end

///------------------------------
/// @LiXiangCheng 20161022
/// readme:http://adhoc.qiniudn.com/README.html
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

/*!
*  @brief dic转model
*  readme:http://adhoc.qiniudn.com/README.html
*
*  @param dic  字典
*
*  @return model对象
*
*  @since 1.0
*/
- (id)initWithDic:(NSDictionary *)dic;


/*!
 *  @brief model转dic
 *  readme:http://adhoc.qiniudn.com/README.html
 *
 *  @return 字典
 *
 *  @since 1.0
 */
- (NSDictionary *)dic;


/*!
 *  @brief json字符串转model
 *
 *  @param json  json字符串
 *
 *  @return model对象
 *
 *  @since 1.0
 */
- (id)initWithJson:(NSString *)json;


/*!
 *  @brief model转json字符串
 *
 *  @return json字符串
 *
 *  @since 1.0
 */
- (NSString *)json;


/*!
 *  @brief 在propertyName与josnKeyName不一致时，要设置此类函数
 *
 *  @return 字典映射replacedKeyMap：{propertyName:jsonKeyName}
 *
 *  @since 1.0
 */
+ (NSDictionary *)replacedKeyMap;


/*!
 *  @brief model对象转属性字典
 *
 *  @param object  model对象
 *
 *  @return model属性字典
 *
 *  @since 1.0
 */
+ (NSDictionary *) propertiesOfObject:(id)object;


/*!
 *  @brief model类转属性字典
 *
 *  @param klass  model类
 *
 *  @return model属性字典
 *
 *  @since 1.0
 */
+ (NSDictionary *) propertiesOfClass:(Class)klass;


/*!
 *  @brief model类的子类转属性字典，支持递归(recursive)
 *
 *  @param klass  model类
 *
 *  @return model的子类属性字典
 *
 *  @since 1.0
 */
+ (NSDictionary *) propertiesOfSubclass:(Class)klass;


#pragma mark NSCoding
/*!
 *  @brief 支持model存储序列化文件
 *
 *  @param aCoder  An archiver object.
 *
 *  @since 1.0
 */
- (void)encodeWithCoder:(NSCoder *)aCoder;


/*!
 *  @brief 支持序列化文件读取转为model
 *
 *  @param aDecoder  An unarchiver object.
 *
 *  @return self, initialized using the data in decoder.
 *
 *  @since 1.0
 */
- (id)initWithCoder:(NSCoder *)aDecoder;


#pragma mark NSCopying
/*!
 *  @brief 支持model copy
 *
 *  @param zone  This parameter is ignored. Memory zones are no longer used by Objective-C.
 *
 *  @return Returns a new instance that’s a copy of the receiver.
 *
 *  @since 1.0
 */
- (id)copyWithZone:(NSZone *)zone;
@end

@interface AutuParser:NSObject @end
