//
//  NSManagedObject+Safe.h
//  AutoParser
//
//  Created by LiXiangCheng on 16/10/22.
//  Copyright © 2016年 LiXiangCheng. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (Safe)

- (void)safeSetObject:(id)anObject forKey:(NSString *)aKey;

@end
