

#import "NSObjectHelper.h"

/** 缓存所有类的属性{"ClassName":propertiesDic}=Table scheme */
static NSMutableDictionary *gPropertiesOfClass = nil;

@implementation NSObject (Helper)

/** NSObject提供 的performSelector最多只支持两个参数,针对NSObject增加了如下扩展 */
- (id)performSelector:(SEL)selector withObjects:(NSArray *)objects {
    NSMethodSignature *signature = [self methodSignatureForSelector:selector];
    if (signature) {
        NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:signature];
        [invocation setTarget:self];
        [invocation setSelector:selector];
        for(int i = 0; i < [objects count]; i++){
            id object = [objects objectAtIndex:i];
            [invocation setArgument:&object atIndex: (i + 2)];
        }
        [invocation invoke];
        if (signature.methodReturnLength) {
            id anObject;
            [invocation getReturnValue:&anObject];
            return anObject;
        } else {
            return nil;
        }
    } else {
        return nil;
    }
}

@end

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
        if ([obj isEqualToString:NSStringFromClass([NSString class])] || [obj isEqualToString:NSStringFromClass([NSMutableString class])]) {
            id value=RKMapping([dic valueForKey:key]);
            if ([value isKindOfClass:[NSString class]]) {
                //value=(NSMutableString *)[value stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                [object setValue:value forKeyPath:key];
            }
            else if ([value isKindOfClass:[NSNumber class]]) {
                [object setValue:[value stringValue] forKeyPath:key];
            }
        }
        else if ([obj isEqualToString:NSStringFromClass([NSDictionary class])] || [obj isEqualToString:NSStringFromClass([NSMutableDictionary class])]) {
            NSMutableDictionary *value=RKMapping([dic valueForKey:key]);
            [object setValue:value forKeyPath:key];
        }
        else if ([obj isEqualToString:NSStringFromClass([NSNumber class])]) {
            id value=RKMapping([dic valueForKey:key]);
            if ([value isKindOfClass:[NSNumber class]]) {
                [object setValue:value forKeyPath:key];
            }
            else if ([value respondsToSelector:@selector(doubleValue)]) {
                [object setValue:[NSNumber numberWithDouble:[value doubleValue]] forKeyPath:key];
            }
        }
        else if ([obj isEqualToString:[NSString stringWithFormat:@"%c",_C_LNG_LNG]]
                 || [obj isEqualToString:[NSString stringWithFormat:@"%c",_C_INT]]
                 || [obj isEqualToString:[NSString stringWithFormat:@"%c",_C_LNG]]) {//NSInteger
            NSInteger value=[RKMapping([dic valueForKey:key]) integerValue];
            [object setValue:@(value) forKeyPath:key];
        }
        else if ([obj isEqualToString:[NSString stringWithFormat:@"%c",_C_ULNG_LNG]]
                 || [obj isEqualToString:[NSString stringWithFormat:@"%c",_C_UINT]]
                 || [obj isEqualToString:[NSString stringWithFormat:@"%c",_C_ULNG]]) {//NSUInteger
            NSUInteger value=[RKMapping([dic valueForKey:key]) integerValue];
            [object setValue:@(value) forKeyPath:key];
        }
        else if ([obj isEqualToString:[NSString stringWithFormat:@"%c",_C_DBL]]) {//double
            double value=[RKMapping([dic valueForKey:key]) doubleValue];
            [object setValue:@(value) forKeyPath:key];
        }
        else if ([obj isEqualToString:[NSString stringWithFormat:@"%c",_C_FLT]]) {//float
            float value=[RKMapping([dic valueForKey:key]) floatValue];
            [object setValue:@(value) forKeyPath:key];
        }
        else if ([obj isEqualToString:[NSString stringWithFormat:@"%c",_C_INT]]) {//int
            int value=[RKMapping([dic valueForKey:key]) intValue];
            [object setValue:@(value) forKeyPath:key];
        }
        else if ([obj isEqualToString:[NSString stringWithFormat:@"%c",_C_BOOL]]) {//bool,BOOL
            bool value=[RKMapping([dic valueForKey:key]) boolValue];
            [object setValue:@(value) forKeyPath:key];
        }
        else if ([obj isEqualToString:NSStringFromClass([NSSet class])] || [obj isEqualToString:NSStringFromClass([NSMutableSet class])]) {
        }
        else if ([obj isEqualToString:NSStringFromClass([NSArray class])] || [obj isEqualToString:NSStringFromClass([NSMutableArray class])]) {
            NSMutableArray *value=[[NSMutableArray alloc] init];
            
            NSMutableArray *records = RKMapping([dic valueForKey:key]);
            for (NSObject *record in records) {
                if (!record || ![record isKindOfClass:[NSObject class]]) {
                    continue;
                }
                [value addObject:record];
            }
            
            [object setValue:value forKeyPath:key];
        }
        else if ([obj isEqualToString:NSStringFromClass([NSOrderedSet class])] || [obj isEqualToString:NSStringFromClass([NSMutableOrderedSet class])]) {
        }
        else{//自定义class
            NSRegularExpression *arrayRegExp=[[NSRegularExpression alloc] initWithPattern:@"(?<=\\<).*?(?=\\>)" options:NSRegularExpressionCaseInsensitive error:nil];
            NSArray *results=[arrayRegExp matchesInString:obj options:NSMatchingWithTransparentBounds range:NSMakeRange(0, [obj length])];
            if (results.count>0) {
                NSTextCheckingResult *result=results[0];
                NSRange range = result.range;
                NSString *className = [[obj substringToIndex:range.location-1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                NSString *recordClassName = [[obj substringWithRange:range] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                if ([className isEqualToString:NSStringFromClass([NSArray class])] || [className isEqualToString:NSStringFromClass([NSMutableArray class])]) {
                    id recordClass = NSClassFromString(recordClassName);
                    
                    NSMutableArray *value=[[NSMutableArray alloc] init];
                    
                    NSMutableArray *records = RKMapping([dic valueForKey:key]);
                    for (NSDictionary *record in records) {
                        if (!record || ![record isKindOfClass:[NSDictionary class]]) {
                            continue;
                        }
                        if([recordClass instancesRespondToSelector:@selector(initWithDic:)]){
                            [value addObject:[[recordClass alloc] initWithDic:record]];
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
            NSMutableString *value=[object valueForKeyPath:key];
            [dic setValue:(value?value:@"") forKeyPath:key];
        }
        else if ([obj isEqualToString:NSStringFromClass([NSDictionary class])] || [obj isEqualToString:NSStringFromClass([NSMutableDictionary class])]) {
            NSMutableDictionary *value=[object valueForKeyPath:key];
            [dic setValue:(value?value:[NSMutableDictionary dictionary]) forKeyPath:key];
        }
        else if ([obj isEqualToString:NSStringFromClass([NSNumber class])]) {
            NSNumber *value=[object valueForKeyPath:key];
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
        else if ([obj isEqualToString:NSStringFromClass([NSSet class])] || [obj isEqualToString:NSStringFromClass([NSMutableSet class])]) {
        }
        else if ([obj isEqualToString:NSStringFromClass([NSArray class])] || [obj isEqualToString:NSStringFromClass([NSMutableArray class])]) {
            NSMutableArray *value=[NSMutableArray array];
            
            NSMutableArray *records=[object valueForKeyPath:key];
            [records enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                NSObject *record = (NSObject *)obj;
                [value addObject:record];
            }];
            [dic setValue:value forKey:key];
        }
        else if ([obj isEqualToString:NSStringFromClass([NSOrderedSet class])] || [obj isEqualToString:NSStringFromClass([NSMutableOrderedSet class])]) {
        }
        else{//自定义class
            NSRegularExpression *arrayRegExp=[[NSRegularExpression alloc] initWithPattern:@"(?<=\\<).*?(?=\\>)" options:NSRegularExpressionCaseInsensitive error:nil];
            NSArray *results=[arrayRegExp matchesInString:obj options:NSMatchingWithTransparentBounds range:NSMakeRange(0, [obj length])];
            if (results.count>0) {
                NSTextCheckingResult *result=results[0];
                NSRange range = result.range;
                NSString *className = [[obj substringToIndex:range.location-1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                NSString *recordClassName = [[obj substringWithRange:range] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                if ([className isEqualToString:NSStringFromClass([NSArray class])] || [className isEqualToString:NSStringFromClass([NSMutableArray class])]) {
                    id recordClass = NSClassFromString(recordClassName);
                    
                    NSMutableArray *value=[NSMutableArray array];
                    
                    NSMutableArray *records=[object valueForKeyPath:key];
                    [records enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        if([recordClass instancesRespondToSelector:@selector(dic)]){
                            [value addObject:[obj dic]];
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

@end
