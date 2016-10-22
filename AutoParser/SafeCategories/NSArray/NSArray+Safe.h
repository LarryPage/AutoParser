//
//  NSArray+Safe.h
//  AutoParser
//
//  Created by LiXiangCheng on 16/10/22.
//  Copyright © 2016年 LiXiangCheng. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * 有序的集合
 */
@interface NSArray (Safe)

/**
 *  替换objectAtIndex | []
 */
- (id)safeObjectAtIndex:(NSUInteger)index;

+ (NSArray *)safeArrayFromObject:(id)obj;

@end
