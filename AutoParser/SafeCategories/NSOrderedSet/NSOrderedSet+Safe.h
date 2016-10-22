//
//  NSOrderedSet+Safe.h
//  AutoParser
//
//  Created by LiXiangCheng on 16/10/22.
//  Copyright © 2016年 LiXiangCheng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSOrderedSet (Safe)

+ (NSOrderedSet *)safeOrderedSetFromObject:(id)obj;

@end
