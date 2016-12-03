//
//  StatusResult.h
//  AutoParser
//
//  Created by LiXiangCheng on 16/9/16.
//  Copyright © 2016年 LiXiangCheng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Status.h"
#import "Ad.h"

/** 微博结果（用来表示大批量的微博数据） */
@JSONInterface(StatusResult) : NSObject

/** 存放着某一页微博数据（里面都是Status模型） */
@property (nonatomic, strong) JSONMutableArray(Status) *statuses;
/** 存放着一堆的广告数据（里面都是Ad模型） */
@property (nonatomic, strong) JSONMutableArray(Ad) *ads;
/** 总数 */
@property (nonatomic, strong) NSNumber *totalNumber;
/** 上一页的游标 */
@property (nonatomic, assign) NSUInteger previousCursor;
/** 下一页的游标 */
@property (nonatomic, assign) NSUInteger nextCursor;

@end
