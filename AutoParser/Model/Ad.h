//
//  Ad.h
//  AutoParser
//
//  Created by LiXiangCheng on 16/9/16.
//  Copyright © 2016年 LiXiangCheng. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol Ad <NSObject>
@end

/** 广告模型 */
@interface Ad : NSObject

/** 广告图片 */
@property (nonatomic, strong) NSString *image;
/** 广告url */
@property (nonatomic, strong) NSString *url;

@end
