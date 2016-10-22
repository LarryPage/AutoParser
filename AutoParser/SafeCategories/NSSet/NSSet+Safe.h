//
//  NSSet+Safe.h
//  AutoParser
//
//  Created by LiXiangCheng on 16/10/22.
//  Copyright © 2016年 LiXiangCheng. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * 无序的集合
 */
@interface NSSet (Safe)

+ (NSSet *)safeSetFromObject:(id)obj;

@end
