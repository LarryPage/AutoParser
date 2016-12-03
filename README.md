# AutoParser
基于ObjC Runtime,SafeCategory,NSCache实现自动解析<br>
自动化Jons数据与Model互相解析 <br>
一个NSObject Category类，only一个方法即可实现 <br>
Josn与model互相转换，涉及到 <br>
Josn与model数据：字典<-->模型 <br>
Model层级嵌套：Model中属性为数组，NSArray中每个元素为另一model（字典数组<-->模型数组） <br>
Josn层级嵌套，Mode对象josn化 <br>
最大缓存500个Model定义,1个model按10个左右属性，大约0.1K，500个model点内存50K <br>
实现 模型序列化存储、读取、copy 【NSCoding NSCopying】 <br>
使用 WDSafeCategories保证每条数据安全解析 <br>

Screenshot shows AutoParser used for a snippet
![alt tag](https://github.com/LarryPage/AutoParser/blob/master/screen003.png)

项目用例： <br>
1.model定义->属性字典 <br>
2.复杂的字典 -> 模型 (模型的数组属性里面又装着模型) <br>
3.模型 (模型的数组属性里面又装着模型) -> 复杂的字典 <br>
4.模型 (模型的数组属性里面又装着模型) -> json字符串 <br>
5.json文件 -> 模型 (模型的数组属性里面又装着模型)  用于mock <br>
6.model存储序列化文件 <br>
7.序列化文件读取model <br>


AutoParser + JOSN2MODEL实现自动化解析流程
==========
* [AutoParser](https://github.com/LarryPage/AutoParser)
* [JOSN2MODEL](https://github.com/LarryPage/JOSN2Model)
* 1.项目引入AutoParser目录下的NSObjectHelper.h，NSObjectHelper.m 主要用到其中的 initWithDic() & dic() 两个方法，若propertyName与josnKeyName不一致时，用到replacedKeyMap（）方法
* 2.JOSN2Model.app 桌面app，将api返回的josn数据转成model.h,model.m，保存.h.m，并引入到项目中
* 3.使用:
```
ModelClass *record=[[ModelClass alloc] initWithDic:response[@"data"]];//dic转model
NSDictionary *dic=[record dic];//model转dic

ModelClass *record=[[ModelClass alloc] initWithJson:jsonString];//json字符串转model
NSString *jsonString=[record json];//model转json字符串

/**
 在propertyName与josnKeyName不一致时，要在model.m实现的类方法
 返回replacedKeyMap：{propertyName:jsonKeyName}
 建议使用 JOSN2Model.app 自动生成
 */
+ (NSDictionary *)replacedKeyMap{ 
    NSMutableDictionary *map = [NSMutableDictionary dictionary];
    //[map safeSetObject:@"jsonKeyName" forKey:@"propertyName"];
    [map safeSetObject:@"avatar" forKey:@"icon"];
    return map;
}
//or
+ (NSDictionary *)replacedKeyMap{ 
    return @{@"propertyName" : @"jsonKeyName",
             @"icon" : @"avatar"
             };
}

NSDictionary *userPpropertiesDic = [NSObject propertiesOfClass:[ModelClass class]];//model定义->属性字典
ModelClass *copy=[record copy];//支持model NSCoding
[NSKeyedArchiver archiveRootObject:copy toFile:path];//model存储序列化文件
ModelClass *read=[NSKeyedUnarchiver unarchiveObjectWithFile:path];//序列化文件读取model
```
