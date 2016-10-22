//
//  NSObject+Safe.h
//  AutoParser
//
//  Created by LiXiangCheng on 16/10/22.
//  Copyright © 2016年 LiXiangCheng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Safe)

/**
 *  主要作用是去除NSNull:当obj为NSNull的时候，返回nil
 */
+ (id)safeObjectFromObject:(id)obj;

@end
