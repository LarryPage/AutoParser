

#import "NSObjectHelper.h"

/** 缓存所有类的属性{"ClassName":propertiesDic}=Table scheme */
static NSMutableDictionary *gPropertiesOfClass = nil;

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
    NSError *error;
    NSData *data= [json dataUsingEncoding:NSUTF8StringEncoding];
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

+ (void)KeyValueDecoderForObject:(id)object dic:(NSDictionary *)dic{
    NSDictionary *propertysDic = [self propertiesOfObject:object];
    [propertysDic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([obj isEqualToString:NSStringFromClass([NSString class])]) {
            id value= [NSString safeStringFromObject:[dic valueForKey:key]];
            [object setValue:value forKeyPath:key];
        }
        else if ([obj isEqualToString:NSStringFromClass([NSMutableString class])]) {
            id value=[NSMutableString safeStringFromObject:[dic valueForKey:key]];
            //value=(NSMutableString *)[value stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [object setValue:value forKeyPath:key];
        }
        else if ([obj isEqualToString:NSStringFromClass([NSDictionary class])]) {
            id value=[NSDictionary safeDictionaryFromObject:[dic valueForKey:key]];
            [object setValue:value forKeyPath:key];
        }
        else if ([obj isEqualToString:NSStringFromClass([NSMutableDictionary class])]) {
            id value=[NSMutableDictionary safeDictionaryFromObject:[dic valueForKey:key]];
            [object setValue:value forKeyPath:key];
        }
        else if ([obj isEqualToString:NSStringFromClass([NSNumber class])]) {
            id value=[NSNumber safeNumberFromObject:[dic valueForKey:key]];
            [object setValue:value forKeyPath:key];
        }
        else if ([obj isEqualToString:[NSString stringWithFormat:@"%c",_C_LNG_LNG]]
                 || [obj isEqualToString:[NSString stringWithFormat:@"%c",_C_INT]]
                 || [obj isEqualToString:[NSString stringWithFormat:@"%c",_C_LNG]]) {//NSInteger
            NSInteger value=[[NSString safeStringFromObject:[dic valueForKey:key]] integerValue];
            [object setValue:@(value) forKeyPath:key];
        }
        else if ([obj isEqualToString:[NSString stringWithFormat:@"%c",_C_ULNG_LNG]]
                 || [obj isEqualToString:[NSString stringWithFormat:@"%c",_C_UINT]]
                 || [obj isEqualToString:[NSString stringWithFormat:@"%c",_C_ULNG]]) {//NSUInteger
            NSUInteger value=[[NSString safeStringFromObject:[dic valueForKey:key]] integerValue];
            [object setValue:@(value) forKeyPath:key];
        }
        else if ([obj isEqualToString:[NSString stringWithFormat:@"%c",_C_DBL]]) {//double
            double value=[[NSString safeStringFromObject:[dic valueForKey:key]] doubleValue];
            [object setValue:@(value) forKeyPath:key];
        }
        else if ([obj isEqualToString:[NSString stringWithFormat:@"%c",_C_FLT]]) {//float
            float value=[[NSString safeStringFromObject:[dic valueForKey:key]] floatValue];
            [object setValue:@(value) forKeyPath:key];
        }
        else if ([obj isEqualToString:[NSString stringWithFormat:@"%c",_C_INT]]) {//int
            int value=[[NSString safeStringFromObject:[dic valueForKey:key]] intValue];
            [object setValue:@(value) forKeyPath:key];
        }
        else if ([obj isEqualToString:[NSString stringWithFormat:@"%c",_C_BOOL]]) {//bool,BOOL
            bool value=[[NSString safeStringFromObject:[dic valueForKey:key]] boolValue];
            [object setValue:@(value) forKeyPath:key];
        }
        else if ([obj isEqualToString:NSStringFromClass([NSArray class])] || [obj isEqualToString:NSStringFromClass([NSMutableArray class])]) {
            NSMutableArray *value=[[NSMutableArray alloc] init];
            
            NSArray *records = [NSArray safeArrayFromObject:[dic valueForKey:key]];
            for (NSObject *record in records) {
                [value safeAddObject:record];
            }
            
            [object setValue:value forKeyPath:key];
        }
        else if ([obj isEqualToString:NSStringFromClass([NSSet class])] || [obj isEqualToString:NSStringFromClass([NSMutableSet class])]) {
            NSMutableSet *value=[[NSMutableSet alloc] init];
            
            NSSet *records = [NSSet safeSetFromObject:[dic valueForKey:key]];
            for (NSObject *record in records) {
                [value safeAddObject:record];
            }
            
            [object setValue:value forKeyPath:key];
        }
        else if ([obj isEqualToString:NSStringFromClass([NSOrderedSet class])] || [obj isEqualToString:NSStringFromClass([NSMutableOrderedSet class])]) {
            NSMutableOrderedSet *value=[[NSMutableOrderedSet alloc] init];
            
            NSOrderedSet *records = [NSOrderedSet safeOrderedSetFromObject:[dic valueForKey:key]];
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
                    
                    NSArray *records = [NSArray safeArrayFromObject:[dic valueForKey:key]];
                    for (NSDictionary *record in records) {
                        if (!record || ![record isKindOfClass:[NSDictionary class]]) {
                            continue;
                        }
                        if([recordClass instancesRespondToSelector:@selector(initWithDic:)]){
                            [value safeAddObject:[[recordClass alloc] initWithDic:record]];
                        }
                    }
                    
                    [object setValue:value forKeyPath:key];
                    return;
                }
                else if ([className isEqualToString:NSStringFromClass([NSSet class])] || [className isEqualToString:NSStringFromClass([NSMutableSet class])]) {
                    NSMutableSet *value=[[NSMutableSet alloc] init];
                    
                    NSSet *records = [NSSet safeSetFromObject:[dic valueForKey:key]];
                    for (NSDictionary *record in records) {
                        if (!record || ![record isKindOfClass:[NSDictionary class]]) {
                            continue;
                        }
                        if([recordClass instancesRespondToSelector:@selector(initWithDic:)]){
                            [value safeAddObject:[[recordClass alloc] initWithDic:record]];
                        }
                    }
                    
                    [object setValue:value forKeyPath:key];
                    return;
                }
                else if ([className isEqualToString:NSStringFromClass([NSOrderedSet class])] || [className isEqualToString:NSStringFromClass([NSMutableOrderedSet class])]) {
                    NSMutableOrderedSet *value=[[NSMutableOrderedSet alloc] init];
                    
                    NSOrderedSet *records = [NSOrderedSet safeOrderedSetFromObject:[dic valueForKey:key]];
                    for (NSDictionary *record in records) {
                        if (!record || ![record isKindOfClass:[NSDictionary class]]) {
                            continue;
                        }
                        if([recordClass instancesRespondToSelector:@selector(initWithDic:)]){
                            [value safeAddObject:[[recordClass alloc] initWithDic:record]];
                        }
                    }
                    
                    [object setValue:value forKeyPath:key];
                    return;
                }
            }
            
            id aClass = NSClassFromString(obj);
            if([aClass instancesRespondToSelector:@selector(initWithDic:)]){
                [object setValue:[[aClass alloc] initWithDic:[dic valueForKey:key]] forKeyPath:key];
            }
        }
    }];
}

+ (void)KeyValueEncoderForObject:(id)object dic:(NSDictionary *)dic{
    NSDictionary *propertysDic = [self propertiesOfObject:object];
    [propertysDic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([obj isEqualToString:NSStringFromClass([NSString class])] || [obj isEqualToString:NSStringFromClass([NSMutableString class])]) {
            id value=[object valueForKeyPath:key];
            [dic setValue:(value?value:@"") forKeyPath:key];
        }
        else if ([obj isEqualToString:NSStringFromClass([NSDictionary class])] || [obj isEqualToString:NSStringFromClass([NSMutableDictionary class])]) {
            id value=[object valueForKeyPath:key];
            [dic setValue:(value?value:[NSMutableDictionary dictionary]) forKeyPath:key];
        }
        else if ([obj isEqualToString:NSStringFromClass([NSNumber class])]) {
            id value=[object valueForKeyPath:key];
            [dic setValue:value forKeyPath:key];
        }
        else if ([obj isEqualToString:[NSString stringWithFormat:@"%c",_C_LNG_LNG]]
                 || [obj isEqualToString:[NSString stringWithFormat:@"%c",_C_INT]]
                 || [obj isEqualToString:[NSString stringWithFormat:@"%c",_C_LNG]]) {//NSInteger
            NSInteger value=[[object valueForKeyPath:key] integerValue];
            [dic setValue:@(value) forKeyPath:key];
        }
        else if ([obj isEqualToString:[NSString stringWithFormat:@"%c",_C_ULNG_LNG]]
                 || [obj isEqualToString:[NSString stringWithFormat:@"%c",_C_UINT]]
                 || [obj isEqualToString:[NSString stringWithFormat:@"%c",_C_ULNG]]) {//NSUInteger
            NSUInteger value=[[object valueForKeyPath:key] integerValue];
            [dic setValue:@(value) forKeyPath:key];
        }
        else if ([obj isEqualToString:[NSString stringWithFormat:@"%c",_C_DBL]]) {//double
            double value=[[object valueForKeyPath:key] doubleValue];
            [dic setValue:[NSString stringWithFormat:@"%0.6f", value] forKeyPath:key];
        }
        else if ([obj isEqualToString:[NSString stringWithFormat:@"%c",_C_FLT]]) {//float
            double value=[[object valueForKeyPath:key] floatValue];
            [dic setValue:[NSString stringWithFormat:@"%0.6f", value] forKeyPath:key];
        }
        else if ([obj isEqualToString:[NSString stringWithFormat:@"%c",_C_INT]]) {//int
            int value=[[object valueForKeyPath:key] intValue];
            [dic setValue:@(value) forKeyPath:key];
        }
        else if ([obj isEqualToString:[NSString stringWithFormat:@"%c",_C_BOOL]]) {//bool,BOOL
            bool value=[[object valueForKeyPath:key] boolValue];
            [dic setValue:@(value) forKeyPath:key];
        }
        else if ([obj isEqualToString:NSStringFromClass([NSArray class])] || [obj isEqualToString:NSStringFromClass([NSMutableArray class])]) {
            NSMutableArray *value=[NSMutableArray array];
            
            NSArray *records=[object valueForKeyPath:key];
            [records enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                NSObject *record = (NSObject *)obj;
                [value safeAddObject:record];
            }];
            [dic setValue:value forKey:key];
        }
        else if ([obj isEqualToString:NSStringFromClass([NSSet class])] || [obj isEqualToString:NSStringFromClass([NSMutableSet class])]) {
            NSMutableSet *value=[NSMutableSet set];
            
            NSSet *records=[object valueForKeyPath:key];
            [records enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
                NSObject *record = (NSObject *)obj;
                [value safeAddObject:record];
            }];
            [dic setValue:value forKey:key];
        }
        else if ([obj isEqualToString:NSStringFromClass([NSOrderedSet class])] || [obj isEqualToString:NSStringFromClass([NSMutableOrderedSet class])]) {
            NSMutableOrderedSet *value=[NSMutableOrderedSet orderedSet];
            
            NSOrderedSet *records=[object valueForKeyPath:key];
            [records enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                NSObject *record = (NSObject *)obj;
                [value safeAddObject:record];
            }];
            [dic setValue:value forKey:key];
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
                    NSMutableArray *value=[NSMutableArray array];
                    
                    NSArray *records=[object valueForKeyPath:key];
                    [records enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        if([recordClass instancesRespondToSelector:@selector(dic)]){
                            [value safeAddObject:[obj dic]];
                        }
                        
                    }];
                    
                    [dic setValue:value forKey:key];
                    return;
                }
                else if ([className isEqualToString:NSStringFromClass([NSSet class])] || [className isEqualToString:NSStringFromClass([NSMutableSet class])]) {
                    NSMutableSet *value=[NSMutableSet set];
                    
                    NSSet *records=[object valueForKeyPath:key];
                    [records enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
                        if([recordClass instancesRespondToSelector:@selector(dic)]){
                            [value safeAddObject:[obj dic]];
                        }
                        
                    }];
                    
                    [dic setValue:value forKey:key];
                    return;
                }
                else if ([className isEqualToString:NSStringFromClass([NSOrderedSet class])] || [className isEqualToString:NSStringFromClass([NSMutableOrderedSet class])]) {
                    NSMutableOrderedSet *value=[NSMutableOrderedSet orderedSet];
                    
                    NSOrderedSet *records=[object valueForKeyPath:key];
                    [records enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        if([recordClass instancesRespondToSelector:@selector(dic)]){
                            [value safeAddObject:[obj dic]];
                        }
                        
                    }];
                    
                    [dic setValue:value forKey:key];
                    return;
                }
            }
            
            id aClass = NSClassFromString(obj);
            if([aClass instancesRespondToSelector:@selector(dic)]){
                NSDictionary *value=[[object valueForKeyPath:key] dic];
                [dic setValue:value?value:[NSDictionary dictionary] forKey:key];
            }
        }
    }];
}

//http://stackoverflow.com/questions/754824/get-an-object-properties-list-in-objective-c
static const char *getPropertyType(objc_property_t property) {
    const char *attributes = property_getAttributes(property);
    //printf("attributes=%s\n", attributes);
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
        else if (attribute[0] == 'T' && attribute[1] == '@') {
            // it's another ObjC object type:
            //return (const char *)[[NSData dataWithBytes:(attribute + 3) length:strlen(attribute) - 4] bytes];
            NSString *name = [[NSString alloc] initWithBytes:attribute + 3 length:strlen(attribute) - 4 encoding:NSASCIIStringEncoding];
            return (const char *)[name cStringUsingEncoding:NSASCIIStringEncoding];
        }
    }
    return "";
}

+ (NSDictionary *)classPropsFor:(Class)klass
{
    if (klass == NULL) {
        return nil;
    }
    
    NSMutableDictionary *results = [NSMutableDictionary dictionary];
    
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList(klass, &outCount);
    for (i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        const char *propName = property_getName(property);
        if(propName) {
            const char *propType = getPropertyType(property);
            NSString *propertyName = [NSString stringWithUTF8String:propName];
            NSString *propertyType = [NSString stringWithUTF8String:propType];
            [results setObject:propertyType forKey:propertyName];
        }
    }
    free(properties);
    
    // returning a copy here to make sure the dictionary is immutable
    return [NSDictionary dictionaryWithDictionary:results];
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
        gPropertiesOfClass = [[NSMutableDictionary alloc] init];
    }
    NSMutableDictionary * properties=[gPropertiesOfClass valueForKey:NSStringFromClass(klass)];
    if (properties && properties.count>0) {
    }
    else{
        properties = [NSMutableDictionary dictionary];
        [self propertiesForHierarchyOfClass:klass onDictionary:properties];
        //CLog(@"%@:%@",NSStringFromClass(class),properties);
        [gPropertiesOfClass setValue:properties forKey:NSStringFromClass(klass)];
    }
    return properties;
    
//    NSMutableDictionary * properties = [NSMutableDictionary dictionary];
//    [self propertiesForHierarchyOfClass:class onDictionary:properties];
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
            const char *propType = getPropertyType(property);
            NSString *propertyName = [NSString stringWithUTF8String:propName];
            NSString *propertyType = [NSString stringWithUTF8String:propType];
            [properties setObject:propertyType forKey:propertyName];
        }
    }
    free(objcProperties);
    
    return properties;
}

#pragma mark override

/**
 * Implementation of NSCopying copyWithZone: method
 */
- (id)copyWithZone:(NSZone *)zone{
    id copy=[[self class] new];
    
    NSDictionary *propertysDic = [[self class] propertiesOfObject:copy];
    [propertysDic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([obj isEqualToString:NSStringFromClass([NSString class])] || [obj isEqualToString:NSStringFromClass([NSMutableString class])]) {
            id value=[self valueForKeyPath:key];
            [copy setValue:[value copy] forKeyPath:key];
        }
        else if ([obj isEqualToString:NSStringFromClass([NSDictionary class])] || [obj isEqualToString:NSStringFromClass([NSMutableDictionary class])]) {
            id value=[self valueForKeyPath:key];
            [copy setValue:[value copy] forKeyPath:key];
        }
        else if ([obj isEqualToString:NSStringFromClass([NSNumber class])]) {
            id value=[self valueForKeyPath:key];
            [copy setValue:[value copy] forKeyPath:key];
        }
        else if ([obj isEqualToString:[NSString stringWithFormat:@"%c",_C_ULNG_LNG]]
                 || [obj isEqualToString:[NSString stringWithFormat:@"%c",_C_UINT]]
                 || [obj isEqualToString:[NSString stringWithFormat:@"%c",_C_ULNG]]) {//NSUInteger
            id value=[self valueForKeyPath:key];
            [copy setValue:value forKeyPath:key];
        }
        else if ([obj isEqualToString:[NSString stringWithFormat:@"%c",_C_DBL]]) {//double
            id value=[self valueForKeyPath:key];
            [copy setValue:value forKeyPath:key];
        }
        else if ([obj isEqualToString:[NSString stringWithFormat:@"%c",_C_FLT]]) {//float
            id value=[self valueForKeyPath:key];
            [copy setValue:value forKeyPath:key];
        }
        else if ([obj isEqualToString:[NSString stringWithFormat:@"%c",_C_INT]]) {//int
            id value=[self valueForKeyPath:key];
            [copy setValue:value forKeyPath:key];
        }
        else if ([obj isEqualToString:[NSString stringWithFormat:@"%c",_C_BOOL]]) {//bool,BOOL
            id value=[self valueForKeyPath:key];
            [copy setValue:value forKeyPath:key];
        }
        else if ([obj isEqualToString:NSStringFromClass([NSArray class])] || [obj isEqualToString:NSStringFromClass([NSMutableArray class])]) {
            id value=[self valueForKeyPath:key];
            [copy setValue:[value copy] forKeyPath:key];
        }
        else if ([obj isEqualToString:NSStringFromClass([NSSet class])] || [obj isEqualToString:NSStringFromClass([NSMutableSet class])]) {
            id value=[self valueForKeyPath:key];
            [copy setValue:[value copy] forKeyPath:key];
        }
        else if ([obj isEqualToString:NSStringFromClass([NSOrderedSet class])] || [obj isEqualToString:NSStringFromClass([NSMutableOrderedSet class])]) {
            id value=[self valueForKeyPath:key];
            [copy setValue:[value copy] forKeyPath:key];
        }
        else{//自定义class
            id value=[self valueForKeyPath:key];
            [copy setValue:[value copy] forKeyPath:key];
        }
    }];
    
    return copy;
}

@end
