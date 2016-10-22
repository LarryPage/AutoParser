

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

///------------------------------
/// @LiXiangCheng 20150327
/// 实现 memoryDB->serializable files、sqlite3
///------------------------------

/**
 auto kvc :variable type

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
 
 and 自定义model类
 */
// notificationName (ClassName)CurRecordChanged
// userInfo = NSDictionary {"newRecord":record, "oldRecord":record, "action":"add"|"delete"}
// notificationName (ClassName)HistoryChanged
// userInfo = NSDictionary {"record":record,"action":"add"|"delete"|"update"}

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

@end
