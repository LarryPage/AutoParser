//
//  NSMutableArray+Safe.h
//  AutoParser
//
//  Created by LiXiangCheng on 16/10/22.
//  Copyright © 2016年 LiXiangCheng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (Safe)

/**
 *  替换addObject:
 */
- (void)safeAddObject:(id)object;

- (NSMutableArray *) reverse;
@property (readonly, getter=reverse) NSMutableArray *reversed;

@end
