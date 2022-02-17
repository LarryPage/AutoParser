//
//  NSObject+AutoParser.m
//  AutoParser
//
//  Created by LiXiangCheng on 16/9/16.
//  Copyright (c) 2016年 Wanda Inc All rights reserved.
//

#import "NSObjectHelper.h"

/**
 缓存要解析的类的属性{"ClassName":propertiesDic}=Table scheme
 countLimit=500
 最大缓存500个Model定义
 */
static NSCache *gPropertiesOfClass = nil;
/**
 缓存要解析的类中不一致的propertyName与josnKeyName
 countLimit=500
 最大缓存500个Model定义（同上）
 */
static NSCache *gReplacedKeyMapsOfClass = nil;
/**
 缓存不要处理(解析或归档)的的类的propertyName
 countLimit=500
 最大缓存500个Model定义（同上）
 */
static NSCache *gIgnoredPropertyNamesOfClass = nil;

@implementation NSObject (KVC)

- (id)initWithDic:(NSDictionary *)dic{
    self = [self init];
    if (self) {
        if (!dic || ![dic isKindOfClass:[NSDictionary class]]) {
            return nil;
        }
        
        [NSObject KeyValueDecoderForObject:self dic:dic];
    }
    return self;
}

- (NSDictionary *)dic{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    [NSObject KeyValueEncoderForObject:self dic:dic];
    
    return dic;
}

- (id)initWithJson:(NSString *)json{
    NSData *data= [json dataUsingEncoding:NSUTF8StringEncoding];
    if (!data) {
        return nil;
    }
    
    NSError *error;
    id jsonData = [NSJSONSerialization
                   JSONObjectWithData:data
                   options:NSJSONReadingMutableContainers
                   error:&error];
    if (error) {
        return nil;
    }
    
    if (![jsonData isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    NSDictionary *dic = (NSDictionary *)jsonData;
    return [self initWithDic:dic];
}

- (NSString *)json{
    NSDictionary *dic=[self dic];

    if ([NSJSONSerialization isValidJSONObject:dic]) {
        NSError *error = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:0 error:&error];
        NSString *json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        if (!error) return json;
    }
    return nil;
}

+ (NSDictionary *)replacedKeyMap{
    return nil;
}

+ (NSDictionary *)replacedKeyMapOfClass:(Class)klass{
    //memory缓存
    if (!gReplacedKeyMapsOfClass) {
        gReplacedKeyMapsOfClass = [[NSCache alloc] init];
        gReplacedKeyMapsOfClass.name=@"AutuParser.ReplacedKeyMapsOfClass";
        gReplacedKeyMapsOfClass.countLimit=500;
    }
    NSMutableDictionary * map=[gReplacedKeyMapsOfClass objectForKey:NSStringFromClass(klass)];
    if (map) {
    }
    else{
        map = [NSMutableDictionary dictionary];
        [self replacedKeyMapForHierarchyOfClass:klass onDictionary:map];
        //CLog(@"%@:%@",NSStringFromClass(klass),map);
        [gReplacedKeyMapsOfClass setObject:map forKey:NSStringFromClass(klass)];
    }
    return map;
    
//    NSMutableDictionary *map = [NSMutableDictionary dictionary];
//    [self replacedKeyMapForHierarchyOfClass:klass onDictionary:map];
//    return [NSDictionary dictionaryWithDictionary:map];
}

+ (void)replacedKeyMapForHierarchyOfClass:(Class)class onDictionary:(NSMutableDictionary *)map{
    if (class == NULL) {
        return;
    }
    
    if (class == [NSObject class]) {
    }
    
    [self replacedKeyMapForHierarchyOfClass:[class superclass] onDictionary:map];
    
    [[class replacedKeyMap] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [map safeSetObject:obj forKey:key];
    }];
}

+ (NSArray *)ignoredParserPropertyNames{
    return nil;
}

+ (NSArray *)ignoredCodingPropertyNames{
    return nil;
}

+ (NSDictionary *)ignoredPropertyNamesOfClass:(Class)klass{
    //memory缓存
    if (!gIgnoredPropertyNamesOfClass) {
        gIgnoredPropertyNamesOfClass = [[NSCache alloc] init];
        gIgnoredPropertyNamesOfClass.name=@"AutuParser.IgnoredPropertyNamesOfClass";
        gIgnoredPropertyNamesOfClass.countLimit=500;
    }
    NSMutableDictionary * map=[gIgnoredPropertyNamesOfClass objectForKey:NSStringFromClass(klass)];
    if (map) {
    }
    else{
        map = [NSMutableDictionary dictionary];
        [self ignoredPropertyNamesForHierarchyOfClass:klass onDictionary:map];
        [gIgnoredPropertyNamesOfClass setObject:map forKey:NSStringFromClass(klass)];
    }
    return map;
}

+ (void)ignoredPropertyNamesForHierarchyOfClass:(Class)class onDictionary:(NSMutableDictionary *)map{
    if (class == NULL) {
        return;
    }
    
    if (class == [NSObject class]) {
    }
    
    [self ignoredPropertyNamesForHierarchyOfClass:[class superclass] onDictionary:map];
    
    [[class ignoredParserPropertyNames] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [map safeSetObject:@(PropertyNameStateIgnoredParser) forKey:obj];
    }];
    [[class ignoredCodingPropertyNames] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        PropertyNameState propertyNameState=[[map valueForKey:obj] integerValue];
        propertyNameState |= PropertyNameStateIgnoredCoding;
        [map safeSetObject:@(propertyNameState) forKey:obj];
    }];
}

//recursive
+ (id)getValueFromDic:(NSDictionary *)dic key:(NSString *)key{
    NSMutableArray *keys=[NSMutableArray arrayWithArray:[key componentsSeparatedByString:@"."]];
    if (keys.count>1) {
        id jsonValue=[dic valueForKey:keys[0]];
        id value=[NSDictionary safeDictionaryFromObject:jsonValue];
        [keys removeObjectAtIndex:0];
        return [self getValueFromDic:value key:[keys componentsJoinedByString:@"."]];
    }
    else{
        return [dic valueForKey:key];;
    }
}

+ (void)KeyValueDecoderForObject:(id)object dic:(NSDictionary *)dic{
    NSDictionary *propertysDic = [self propertiesOfObject:object];
    NSDictionary *keyMap = [self replacedKeyMapOfClass:[object class]];
    NSDictionary *ignoredPropertyNames = [self ignoredPropertyNamesOfClass:[object class]];
    [propertysDic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        PropertyNameState propertyNameState=[[ignoredPropertyNames valueForKey:key] integerValue];
        if (!(propertyNameState & PropertyNameStateIgnoredParser)) {
            NSString *jsonKeyName=(keyMap && [keyMap valueForKey:key])?[keyMap valueForKey:key]:key;
            //id jsonValue=[dic valueForKey:jsonKeyName];
            //jsonKeyName支持education.teacherResume 多层级使用
            id jsonValue=[self getValueFromDic:dic key:jsonKeyName];
            
            if (jsonValue && jsonValue!=[NSNull null]) {
                if ([obj isEqualToString:NSStringFromClass([NSString class])]) {
                    id value= [NSString safeStringFromObject:jsonValue];
                    [object setValue:value forKeyPath:key];
                }
                else if ([obj isEqualToString:NSStringFromClass([NSMutableString class])]) {
                    id value=[NSMutableString safeStringFromObject:jsonValue];
                    //value=(NSMutableString *)[value stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                    [object setValue:value forKeyPath:key];
                }
                else if ([obj isEqualToString:NSStringFromClass([NSDictionary class])]) {
                    id value=[NSDictionary safeDictionaryFromObject:jsonValue];
                    [object setValue:value forKeyPath:key];
                }
                else if ([obj isEqualToString:NSStringFromClass([NSMutableDictionary class])]) {
                    id value=[NSMutableDictionary safeDictionaryFromObject:jsonValue];
                    [object setValue:value forKeyPath:key];
                }
                else if ([obj isEqualToString:NSStringFromClass([NSNumber class])]) {
                    id value=[NSNumber safeNumberFromObject:jsonValue];
                    [object setValue:value forKeyPath:key];
                }
                else if ([obj isEqualToString:[NSString stringWithFormat:@"%c",_C_LNG_LNG]]
                         || [obj isEqualToString:[NSString stringWithFormat:@"%c",_C_INT]]
                         || [obj isEqualToString:[NSString stringWithFormat:@"%c",_C_LNG]]) {//NSInteger
                    NSInteger value=[[NSString safeStringFromObject:jsonValue] integerValue];
                    [object setValue:@(value) forKeyPath:key];
                }
                else if ([obj isEqualToString:[NSString stringWithFormat:@"%c",_C_ULNG_LNG]]
                         || [obj isEqualToString:[NSString stringWithFormat:@"%c",_C_UINT]]
                         || [obj isEqualToString:[NSString stringWithFormat:@"%c",_C_ULNG]]) {//NSUInteger
                    NSUInteger value=[[NSString safeStringFromObject:jsonValue] integerValue];
                    [object setValue:@(value) forKeyPath:key];
                }
                else if ([obj isEqualToString:[NSString stringWithFormat:@"%c",_C_DBL]]) {//double
                    double value=[[NSString safeStringFromObject:jsonValue] doubleValue];
                    [object setValue:@(value) forKeyPath:key];
                }
                else if ([obj isEqualToString:[NSString stringWithFormat:@"%c",_C_FLT]]) {//float
                    float value=[[NSString safeStringFromObject:jsonValue] floatValue];
                    [object setValue:@(value) forKeyPath:key];
                }
                else if ([obj isEqualToString:[NSString stringWithFormat:@"%c",_C_INT]]) {//int
                    int value=[[NSString safeStringFromObject:jsonValue] intValue];
                    [object setValue:@(value) forKeyPath:key];
                }
                else if ([obj isEqualToString:[NSString stringWithFormat:@"%c",_C_BOOL]]) {//bool,BOOL
                    bool value=[[NSString safeStringFromObject:jsonValue] boolValue];
                    [object setValue:@(value) forKeyPath:key];
                }
                else if ([obj isEqualToString:NSStringFromClass([NSArray class])] || [obj isEqualToString:NSStringFromClass([NSMutableArray class])]) {
                    NSMutableArray *value=[[NSMutableArray alloc] init];
                    
                    NSArray *records = [NSArray safeArrayFromObject:jsonValue];
                    for (NSObject *record in records) {
                        [value safeAddObject:record];
                    }
                    
                    [object setValue:value forKeyPath:key];
                }
                else if ([obj isEqualToString:NSStringFromClass([NSSet class])] || [obj isEqualToString:NSStringFromClass([NSMutableSet class])]) {
                    NSMutableSet *value=[[NSMutableSet alloc] init];
                    
                    NSSet *records = [NSSet safeSetFromObject:jsonValue];
                    for (NSObject *record in records) {
                        [value safeAddObject:record];
                    }
                    
                    [object setValue:value forKeyPath:key];
                }
                else if ([obj isEqualToString:NSStringFromClass([NSOrderedSet class])] || [obj isEqualToString:NSStringFromClass([NSMutableOrderedSet class])]) {
                    NSMutableOrderedSet *value=[[NSMutableOrderedSet alloc] init];
                    
                    NSOrderedSet *records = [NSOrderedSet safeOrderedSetFromObject:jsonValue];
                    for (NSObject *record in records) {
                        [value safeAddObject:record];
                    }
                    
                    [object setValue:value forKeyPath:key];
                }
                else{//自定义class
                    NSRegularExpression *arrayRegExp=[[NSRegularExpression alloc] initWithPattern:@"(?<=\\<).*?(?=\\>)" options:NSRegularExpressionCaseInsensitive error:nil];
                    NSArray *results=[arrayRegExp matchesInString:obj options:NSMatchingWithTransparentBounds range:NSMakeRange(0, [obj length])];
                    if (results.count>0) {
                        NSTextCheckingResult *result=[results safeObjectAtIndex:0];
                        NSRange range = result.range;
                        NSString *className = [[obj substringToIndex:range.location-1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                        NSString *recordClassName = [[obj substringWithRange:range] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                        id recordClass = NSClassFromString(recordClassName);
                        if ([className isEqualToString:NSStringFromClass([NSArray class])] || [className isEqualToString:NSStringFromClass([NSMutableArray class])]) {
                            NSMutableArray *value=[[NSMutableArray alloc] init];
                            
                            NSArray *records = [NSArray safeArrayFromObject:jsonValue];
                            for (NSObject *record in records) {
                                if (!record) {
                                    continue;
                                }
                                if ([recordClassName isEqualToString:NSStringFromClass([NSNumber class])]) {
                                    [value safeAddObject:[NSNumber safeNumberFromObject:record]];
                                }
                                else if ([recordClassName isEqualToString:NSStringFromClass([NSString class])]) {
                                    [value safeAddObject:[NSString safeStringFromObject:record]];
                                }
                                else if ([recordClassName isEqualToString:NSStringFromClass([NSMutableString class])]) {
                                    [value safeAddObject:[NSMutableString safeStringFromObject:record]];
                                }
                                else if ([recordClassName isEqualToString:NSStringFromClass([NSDictionary class])]) {
                                    [value safeAddObject:[NSDictionary safeDictionaryFromObject:record]];
                                }
                                else if ([recordClassName isEqualToString:NSStringFromClass([NSMutableDictionary class])]) {
                                    [value safeAddObject:[NSMutableDictionary safeDictionaryFromObject:record]];
                                }
                                else{
                                    if ([record isKindOfClass:[NSDictionary class]]) {
                                        if([recordClass instancesRespondToSelector:@selector(initWithDic:)]){
                                            [value safeAddObject:[[recordClass alloc] initWithDic:(NSDictionary *)record]];
                                        }
                                    }
                                }
                            }
                            
                            [object setValue:value forKeyPath:key];
                            return;
                        }
                        else if ([className isEqualToString:NSStringFromClass([NSSet class])] || [className isEqualToString:NSStringFromClass([NSMutableSet class])]) {
                            NSMutableSet *value=[[NSMutableSet alloc] init];
                            
                            NSSet *records = [NSSet safeSetFromObject:jsonValue];
                            for (NSObject *record in records) {
                                if (!record) {
                                    continue;
                                }
                                if ([recordClassName isEqualToString:NSStringFromClass([NSNumber class])]) {
                                    [value safeAddObject:[NSNumber safeNumberFromObject:record]];
                                }
                                else if ([recordClassName isEqualToString:NSStringFromClass([NSString class])]) {
                                    [value safeAddObject:[NSString safeStringFromObject:record]];
                                }
                                else if ([recordClassName isEqualToString:NSStringFromClass([NSMutableString class])]) {
                                    [value safeAddObject:[NSMutableString safeStringFromObject:record]];
                                }
                                else if ([recordClassName isEqualToString:NSStringFromClass([NSDictionary class])]) {
                                    [value safeAddObject:[NSDictionary safeDictionaryFromObject:record]];
                                }
                                else if ([recordClassName isEqualToString:NSStringFromClass([NSMutableDictionary class])]) {
                                    [value safeAddObject:[NSMutableDictionary safeDictionaryFromObject:record]];
                                }
                                else{
                                    if ([record isKindOfClass:[NSDictionary class]]) {
                                        if([recordClass instancesRespondToSelector:@selector(initWithDic:)]){
                                            [value safeAddObject:[[recordClass alloc] initWithDic:(NSDictionary *)record]];
                                        }
                                    }
                                }
                            }
                            
                            [object setValue:value forKeyPath:key];
                            return;
                        }
                        else if ([className isEqualToString:NSStringFromClass([NSOrderedSet class])] || [className isEqualToString:NSStringFromClass([NSMutableOrderedSet class])]) {
                            NSMutableOrderedSet *value=[[NSMutableOrderedSet alloc] init];
                            
                            NSOrderedSet *records = [NSOrderedSet safeOrderedSetFromObject:jsonValue];
                            for (NSObject *record in records) {
                                if (!record) {
                                    continue;
                                }
                                if ([recordClassName isEqualToString:NSStringFromClass([NSNumber class])]) {
                                    [value safeAddObject:[NSNumber safeNumberFromObject:record]];
                                }
                                else if ([recordClassName isEqualToString:NSStringFromClass([NSString class])]) {
                                    [value safeAddObject:[NSString safeStringFromObject:record]];
                                }
                                else if ([recordClassName isEqualToString:NSStringFromClass([NSMutableString class])]) {
                                    [value safeAddObject:[NSMutableString safeStringFromObject:record]];
                                }
                                else if ([recordClassName isEqualToString:NSStringFromClass([NSDictionary class])]) {
                                    [value safeAddObject:[NSDictionary safeDictionaryFromObject:record]];
                                }
                                else if ([recordClassName isEqualToString:NSStringFromClass([NSMutableDictionary class])]) {
                                    [value safeAddObject:[NSMutableDictionary safeDictionaryFromObject:record]];
                                }
                                else{
                                    if ([record isKindOfClass:[NSDictionary class]]) {
                                        if([recordClass instancesRespondToSelector:@selector(initWithDic:)]){
                                            [value safeAddObject:[[recordClass alloc] initWithDic:(NSDictionary *)record]];
                                        }
                                    }
                                }
                            }
                            
                            [object setValue:value forKeyPath:key];
                            return;
                        }
                    }
                    
                    id aClass = NSClassFromString(obj);
                    if([aClass instancesRespondToSelector:@selector(initWithDic:)]){
                        id value=[[aClass alloc] initWithDic:jsonValue];
                        if (value) {
                            [object setValue:value forKeyPath:key];
                        }
                    }
                }
            }
        }
    }];
}

//recursive
+ (void)setValue:(id)value forKey:(NSString *)key toDic:(NSMutableDictionary *)dic{
    NSMutableArray *keys=[NSMutableArray arrayWithArray:[key componentsSeparatedByString:@"."]];
    if (keys.count>1) {
        if (![dic valueForKey:keys[0]]) {
            [dic setValue:[NSMutableDictionary dictionary] forKey:keys[0]];
        }
        NSMutableDictionary *subDic=[dic valueForKey:keys[0]];
        
        [keys removeObjectAtIndex:0];
        [self setValue:value forKey:[keys componentsJoinedByString:@"."] toDic:subDic];
    }
    else{
        [dic setValue:value forKey:key];
    }
}

+ (void)KeyValueEncoderForObject:(id)object dic:(NSMutableDictionary *)dic{
    NSDictionary *propertysDic = [self propertiesOfObject:object];
    NSDictionary *keyMap = [self replacedKeyMapOfClass:[object class]];
    NSDictionary *ignoredPropertyNames = [self ignoredPropertyNamesOfClass:[object class]];
    [propertysDic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        PropertyNameState propertyNameState=[[ignoredPropertyNames valueForKey:key] integerValue];
        if (!(propertyNameState & PropertyNameStateIgnoredParser)) {
            NSString *jsonKeyName=(keyMap && [keyMap valueForKey:key])?[keyMap valueForKey:key]:key;
            id value=[object valueForKeyPath:key];
            
            if (value) {
                if ([obj isEqualToString:NSStringFromClass([NSString class])] || [obj isEqualToString:NSStringFromClass([NSMutableString class])]) {
                    //[dic setValue:value forKey:jsonKeyName];
                    //jsonKeyName支持education.teacherResume 多层级使用
                    [self setValue:value forKey:jsonKeyName toDic:dic];
                }
                else if ([obj isEqualToString:NSStringFromClass([NSDictionary class])] || [obj isEqualToString:NSStringFromClass([NSMutableDictionary class])]) {
                    //[dic setValue:value forKey:jsonKeyName];
                    //jsonKeyName支持education.teacherResume 多层级使用
                    [self setValue:value forKey:jsonKeyName toDic:dic];
                }
                else if ([obj isEqualToString:NSStringFromClass([NSNumber class])]) {
                    //[dic setValue:value forKey:jsonKeyName];
                    //jsonKeyName支持education.teacherResume 多层级使用
                    [self setValue:value forKey:jsonKeyName toDic:dic];
                }
                else if ([obj isEqualToString:[NSString stringWithFormat:@"%c",_C_LNG_LNG]]
                         || [obj isEqualToString:[NSString stringWithFormat:@"%c",_C_INT]]
                         || [obj isEqualToString:[NSString stringWithFormat:@"%c",_C_LNG]]) {//NSInteger
                    NSInteger jsonValue=[value integerValue];
                    //[dic setValue:@(jsonValue) forKey:jsonKeyName];
                    //jsonKeyName支持education.teacherResume 多层级使用
                    [self setValue:@(jsonValue) forKey:jsonKeyName toDic:dic];
                }
                else if ([obj isEqualToString:[NSString stringWithFormat:@"%c",_C_ULNG_LNG]]
                         || [obj isEqualToString:[NSString stringWithFormat:@"%c",_C_UINT]]
                         || [obj isEqualToString:[NSString stringWithFormat:@"%c",_C_ULNG]]) {//NSUInteger
                    NSUInteger jsonValue=[value integerValue];
                    //[dic setValue:@(jsonValue) forKey:jsonKeyName];
                    //jsonKeyName支持education.teacherResume 多层级使用
                    [self setValue:@(jsonValue) forKey:jsonKeyName toDic:dic];
                }
                else if ([obj isEqualToString:[NSString stringWithFormat:@"%c",_C_DBL]]) {//double
                    double jsonValue=[value doubleValue];
                    //[dic setValue:[NSString stringWithFormat:@"%0.6f", jsonValue] forKey:jsonKeyName];
                    //jsonKeyName支持education.teacherResume 多层级使用
                    [self setValue:[NSString stringWithFormat:@"%0.6f", jsonValue] forKey:jsonKeyName toDic:dic];
                }
                else if ([obj isEqualToString:[NSString stringWithFormat:@"%c",_C_FLT]]) {//float
                    float jsonValue=[value floatValue];
                    //[dic setValue:[NSString stringWithFormat:@"%0.6f", jsonValue] forKey:jsonKeyName];
                    //jsonKeyName支持education.teacherResume 多层级使用
                    [self setValue:[NSString stringWithFormat:@"%0.6f", jsonValue] forKey:jsonKeyName toDic:dic];
                }
                else if ([obj isEqualToString:[NSString stringWithFormat:@"%c",_C_INT]]) {//int
                    int jsonValue=[value intValue];
                    //[dic setValue:@(jsonValue) forKey:jsonKeyName];
                    //jsonKeyName支持education.teacherResume 多层级使用
                    [self setValue:@(jsonValue) forKey:jsonKeyName toDic:dic];
                }
                else if ([obj isEqualToString:[NSString stringWithFormat:@"%c",_C_BOOL]]) {//bool,BOOL
                    bool jsonValue=[value boolValue];
                    //[dic setValue:@(jsonValue) forKey:jsonKeyName];
                    //jsonKeyName支持education.teacherResume 多层级使用
                    [self setValue:@(jsonValue) forKey:jsonKeyName toDic:dic];
                }
                else if ([obj isEqualToString:NSStringFromClass([NSArray class])] || [obj isEqualToString:NSStringFromClass([NSMutableArray class])]) {
                    NSMutableArray *jsonValue=[NSMutableArray array];
                    
                    NSArray *records=value;
                    [records enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        NSObject *record = (NSObject *)obj;
                        [jsonValue safeAddObject:record];
                    }];
                    //[dic setValue:jsonValue forKey:jsonKeyName];
                    //jsonKeyName支持education.teacherResume 多层级使用
                    [self setValue:jsonValue forKey:jsonKeyName toDic:dic];
                }
                else if ([obj isEqualToString:NSStringFromClass([NSSet class])] || [obj isEqualToString:NSStringFromClass([NSMutableSet class])]) {
                    NSMutableSet *jsonValue=[NSMutableSet set];
                    
                    NSSet *records=value;
                    [records enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
                        NSObject *record = (NSObject *)obj;
                        [jsonValue safeAddObject:record];
                    }];
                    //[dic setValue:jsonValue forKey:jsonKeyName];
                    //jsonKeyName支持education.teacherResume 多层级使用
                    [self setValue:jsonValue forKey:jsonKeyName toDic:dic];
                }
                else if ([obj isEqualToString:NSStringFromClass([NSOrderedSet class])] || [obj isEqualToString:NSStringFromClass([NSMutableOrderedSet class])]) {
                    NSMutableOrderedSet *jsonValue=[NSMutableOrderedSet orderedSet];
                    
                    NSOrderedSet *records=value;
                    [records enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        NSObject *record = (NSObject *)obj;
                        [jsonValue safeAddObject:record];
                    }];
                    //[dic setValue:jsonValue forKey:jsonKeyName];
                    //jsonKeyName支持education.teacherResume 多层级使用
                    [self setValue:jsonValue forKey:jsonKeyName toDic:dic];
                }
                else{//自定义class
                    NSRegularExpression *arrayRegExp=[[NSRegularExpression alloc] initWithPattern:@"(?<=\\<).*?(?=\\>)" options:NSRegularExpressionCaseInsensitive error:nil];
                    NSArray *results=[arrayRegExp matchesInString:obj options:NSMatchingWithTransparentBounds range:NSMakeRange(0, [obj length])];
                    if (results.count>0) {
                        NSTextCheckingResult *result=[results safeObjectAtIndex:0];
                        NSRange range = result.range;
                        NSString *className = [[obj substringToIndex:range.location-1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                        NSString *recordClassName = [[obj substringWithRange:range] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                        id recordClass = NSClassFromString(recordClassName);
                        if ([className isEqualToString:NSStringFromClass([NSArray class])] || [className isEqualToString:NSStringFromClass([NSMutableArray class])]) {
                            NSMutableArray *jsonValue=[NSMutableArray array];
                            
                            NSArray *records=value;
                            [records enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                if ([recordClassName isEqualToString:NSStringFromClass([NSNumber class])]) {
                                    [jsonValue safeAddObject:obj];
                                }
                                else if ([recordClassName isEqualToString:NSStringFromClass([NSString class])]) {
                                    [jsonValue safeAddObject:obj?obj:@""];
                                }
                                else if ([recordClassName isEqualToString:NSStringFromClass([NSMutableString class])]) {
                                    [jsonValue safeAddObject:obj?obj:@""];
                                }
                                else if ([recordClassName isEqualToString:NSStringFromClass([NSDictionary class])]) {
                                    [jsonValue safeAddObject:obj?obj:[NSMutableDictionary dictionary]];
                                }
                                else if ([recordClassName isEqualToString:NSStringFromClass([NSMutableDictionary class])]) {
                                    [jsonValue safeAddObject:obj?obj:[NSMutableDictionary dictionary]];
                                }
                                else{
                                    if([recordClass instancesRespondToSelector:@selector(dic)]){
                                        [jsonValue safeAddObject:[obj dic]];
                                    }
                                }
                            }];
                            
                            //[dic setValue:jsonValue forKey:jsonKeyName];
                            //jsonKeyName支持education.teacherResume 多层级使用
                            [self setValue:jsonValue forKey:jsonKeyName toDic:dic];
                            return;
                        }
                        else if ([className isEqualToString:NSStringFromClass([NSSet class])] || [className isEqualToString:NSStringFromClass([NSMutableSet class])]) {
                            NSMutableSet *jsonValue=[NSMutableSet set];
                            
                            NSSet *records=value;
                            [records enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
                                if ([recordClassName isEqualToString:NSStringFromClass([NSNumber class])]) {
                                    [jsonValue safeAddObject:obj];
                                }
                                else if ([recordClassName isEqualToString:NSStringFromClass([NSString class])]) {
                                    [jsonValue safeAddObject:obj?obj:@""];
                                }
                                else if ([recordClassName isEqualToString:NSStringFromClass([NSMutableString class])]) {
                                    [jsonValue safeAddObject:obj?obj:@""];
                                }
                                else if ([recordClassName isEqualToString:NSStringFromClass([NSDictionary class])]) {
                                    [jsonValue safeAddObject:obj?obj:[NSMutableDictionary dictionary]];
                                }
                                else if ([recordClassName isEqualToString:NSStringFromClass([NSMutableDictionary class])]) {
                                    [jsonValue safeAddObject:obj?obj:[NSMutableDictionary dictionary]];
                                }
                                else{
                                    if([recordClass instancesRespondToSelector:@selector(dic)]){
                                        [jsonValue safeAddObject:[obj dic]];
                                    }
                                }
                            }];
                            
                            //[dic setValue:jsonValue forKey:jsonKeyName];
                            //jsonKeyName支持education.teacherResume 多层级使用
                            [self setValue:jsonValue forKey:jsonKeyName toDic:dic];
                            return;
                        }
                        else if ([className isEqualToString:NSStringFromClass([NSOrderedSet class])] || [className isEqualToString:NSStringFromClass([NSMutableOrderedSet class])]) {
                            NSMutableOrderedSet *jsonValue=[NSMutableOrderedSet orderedSet];
                            
                            NSOrderedSet *records=value;
                            [records enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                if ([recordClassName isEqualToString:NSStringFromClass([NSNumber class])]) {
                                    [jsonValue safeAddObject:obj];
                                }
                                else if ([recordClassName isEqualToString:NSStringFromClass([NSString class])]) {
                                    [jsonValue safeAddObject:obj?obj:@""];
                                }
                                else if ([recordClassName isEqualToString:NSStringFromClass([NSMutableString class])]) {
                                    [jsonValue safeAddObject:obj?obj:@""];
                                }
                                else if ([recordClassName isEqualToString:NSStringFromClass([NSDictionary class])]) {
                                    [jsonValue safeAddObject:obj?obj:[NSMutableDictionary dictionary]];
                                }
                                else if ([recordClassName isEqualToString:NSStringFromClass([NSMutableDictionary class])]) {
                                    [jsonValue safeAddObject:obj?obj:[NSMutableDictionary dictionary]];
                                }
                                else{
                                    if([recordClass instancesRespondToSelector:@selector(dic)]){
                                        [jsonValue safeAddObject:[obj dic]];
                                    }
                                }
                            }];
                            
                            //[dic setValue:jsonValue forKey:jsonKeyName];
                            //jsonKeyName支持education.teacherResume 多层级使用
                            [self setValue:jsonValue forKey:jsonKeyName toDic:dic];
                            return;
                        }
                    }
                    
                    id aClass = NSClassFromString(obj);
                    if([aClass instancesRespondToSelector:@selector(dic)]){
                        NSDictionary *jsonValue=[value dic];
                        //[dic setValue:jsonValue?jsonValue:[NSDictionary dictionary] forKey:jsonKeyName];
                        //jsonKeyName支持education.teacherResume 多层级使用
                        [self setValue:jsonValue?jsonValue:[NSDictionary dictionary] forKey:jsonKeyName toDic:dic];
                    }
                }
            }
        }
    }];
}

//http://stackoverflow.com/questions/754824/get-an-object-properties-list-in-objective-c
static const char *getPropertyType(const char *attributes) {
    char buffer[1 + strlen(attributes)];
    strcpy(buffer, attributes);
    char *state = buffer, *attribute;
    while ((attribute = strsep(&state, ",")) != NULL) {//strsep:分解字符串为一组字符串
        if (attribute[0] == 'T' && attribute[1] != '@') {
            // it's a C primitive type:
            /*
             if you want a list of what will be returned for these primitives, search online for
             "objective-c" "Property Attribute Description Examples"
             apple docs list plenty of examples of what you get for int "i", long "l", unsigned "I", struct, etc.
             */
            //return (const char *)[[NSData dataWithBytes:(attribute + 1) length:strlen(attribute) - 1] bytes];
            NSString *name = [[NSString alloc] initWithBytes:attribute + 1 length:strlen(attribute) - 1 encoding:NSASCIIStringEncoding];
            return (const char *)[name cStringUsingEncoding:NSASCIIStringEncoding];
        }
        else if (attribute[0] == 'T' && attribute[1] == '@' && strlen(attribute) == 2) {
            // it's an ObjC id type:
            return "id";
        }
        else if (attribute[0] == 'T' && attribute[1] == '@' && attribute[2] == '?' && strlen(attribute) == 3) {
            // it's a block type:
            return "block";
        }
        else if (attribute[0] == 'T' && attribute[1] == '@') {
            // it's another ObjC object type:
            //return (const char *)[[NSData dataWithBytes:(attribute + 3) length:strlen(attribute) - 4] bytes];
            NSString *name = [[NSString alloc] initWithBytes:attribute + 3 length:strlen(attribute) - 4 encoding:NSASCIIStringEncoding];
            return (const char *)[name cStringUsingEncoding:NSASCIIStringEncoding];
        }
    }
    return "";
}

//recursive
+ (NSDictionary *) propertiesOfObject:(id)object
{
    Class class = [object class];
    return [self propertiesOfClass:class];
}

+ (NSDictionary *) propertiesOfClass:(Class)klass
{
    //memory缓存
    if (!gPropertiesOfClass) {
        gPropertiesOfClass = [[NSCache alloc] init];
        gPropertiesOfClass.name=@"AutuParser.PropertiesOfClass";
        gPropertiesOfClass.countLimit=500;
    }
    NSMutableDictionary * properties=[gPropertiesOfClass objectForKey:NSStringFromClass(klass)];
    if (properties && properties.count>0) {
    }
    else{
        properties = [NSMutableDictionary dictionary];
        [self propertiesForHierarchyOfClass:klass onDictionary:properties];
        //CLog(@"%@:%@",NSStringFromClass(klass),properties);
        [gPropertiesOfClass setObject:properties forKey:NSStringFromClass(klass)];
    }
    return properties;
    
//    NSMutableDictionary * properties = [NSMutableDictionary dictionary];
//    [self propertiesForHierarchyOfClass:klass onDictionary:properties];
//    return [NSDictionary dictionaryWithDictionary:properties];
}

+ (NSDictionary *) propertiesOfSubclass:(Class)klass
{
    if (klass == NULL) {
        return nil;
    }
    
    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
    return [self propertiesForSubclass:klass onDictionary:properties];
}

+ (NSMutableDictionary *)propertiesForHierarchyOfClass:(Class)class onDictionary:(NSMutableDictionary *)properties
{
    if (class == NULL) {
        return nil;
    }
    
    if (class == [NSObject class]) {
        // On reaching the NSObject base class, return all properties collected.
        return properties;
    }
    
    // Collect properties from the current class.
    [self propertiesForSubclass:class onDictionary:properties];
    
    // Collect properties from the superclass.
    return [self propertiesForHierarchyOfClass:[class superclass] onDictionary:properties];
}

+ (NSMutableDictionary *) propertiesForSubclass:(Class)class onDictionary:(NSMutableDictionary *)properties
{
    unsigned int outCount, i;
    objc_property_t *objcProperties = class_copyPropertyList(class, &outCount);
    for (i = 0; i < outCount; i++) {
        objc_property_t property = objcProperties[i];
        const char *propName = property_getName(property);
        if(propName) {
            const char *attributes = property_getAttributes(property);
            //printf("attributes=%s\n", attributes);
            NSArray *attrs = [@(attributes) componentsSeparatedByString:@","];
            if (attrs.count>1) {
                NSString *propRight=attrs[1];
                /*
                 C:copy
                 &:retain|readWrite 
                 R:readonly 
                 N:nonatomic 
                 D:@dynamic 
                 W:__weak 
                 Gname:以 G 开头是的自定义的 Getter 方法名。(如：GcustomGetter 名字是:customGetter)
                 Sname:以 S 开头是的自定义的 Setter 方法名。(如：ScustoSetter: 名字是: ScustoSetter:)
                 */
                if (![propRight isEqualToString:@"R"]) {
                    const char *propType = getPropertyType(attributes);
                    NSString *propertyName = [NSString stringWithUTF8String:propName];
                    NSString *propertyType = [NSString stringWithUTF8String:propType];
                    [properties setObject:propertyType forKey:propertyName];
                }
            }
            
        }
    }
    free(objcProperties);
    
    return properties;
}

+ (NSMutableArray *)modelsFromDics:(NSArray *)dics
{
    if (!dics || [dics isKindOfClass:[NSNull class]]) return nil;
    
    NSMutableArray* list = [[NSMutableArray alloc] init];
    for (id dic in dics) {
        if ([dic isKindOfClass:[NSNull class]]) {
            continue;
        }
        else if ([dic isKindOfClass:[NSDictionary class]]) {
            [list safeAddObject:[[self alloc] initWithDic:dic]];
        }
    }
    return list;
}

+ (NSMutableArray *)dicsFromModels:(NSArray *)models
{
    if (!models || [models isKindOfClass:[NSNull class]]) return nil;
    
    NSMutableArray* list = [[NSMutableArray alloc] init];
    for (id model in models) {
        if ([model isKindOfClass:[NSNull class]]) {
            continue;
        }
        else if([self instancesRespondToSelector:@selector(dic)]){
            [list safeAddObject:[model dic]];
        }
    }
    return list;
}

@end
