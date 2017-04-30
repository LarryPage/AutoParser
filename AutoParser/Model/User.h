//
//  User.h
//  AutoParser
//
//  Created by LiXiangCheng on 16/9/16.
//  Copyright © 2016年 LiXiangCheng. All rights reserved.
//

#import <Foundation/Foundation.h>

/** 用户模型 */
@JSONInterface(User) : NSObject

/** 名称 */
@property (nonatomic, strong) NSString *name;
/** 头像 */
@property (nonatomic, strong) NSString *icon;
/** 年龄 */
@property (nonatomic, assign) NSInteger age;
/** 身高 */
@property (nonatomic, strong) NSString *height;
/** 财富 */
@property (nonatomic, strong) NSNumber *money;
/** 性别:0:男 1:女 */
@property (nonatomic, assign) NSInteger sex;
/** 同性恋 */
@property (nonatomic, assign) BOOL gay;
/** 此属性名将会被忽略：不进行字典和模型的转换 */
@property (nonatomic, assign) BOOL fat;

@end
