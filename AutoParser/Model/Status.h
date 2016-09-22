//
//  Status.h
//  AutoParser
//
//  Created by LiXiangCheng on 16/9/16.
//  Copyright © 2016年 LiXiangCheng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@protocol Status <NSObject>
@end

/** 微博模型 */
@interface Status : NSObject

/** 微博文本内容 */
@property (nonatomic, strong) NSString *text;
/** 微博作者 */
@property (nonatomic, strong) User *user;
/** 转发的微博 */
@property (nonatomic, strong) Status *retweetedStatus;

@end
