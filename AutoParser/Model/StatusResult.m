//
//  StatusResult.m
//  AutoParser
//
//  Created by LiXiangCheng on 16/9/16.
//  Copyright © 2016年 LiXiangCheng. All rights reserved.
//

#import "StatusResult.h"

@implementation StatusResult

#pragma mark override

-(id) init{
    self = [super init];
    if (self) {
        // Initialization code
        self.statuses=(NSMutableArray<Status> *)[NSMutableArray array];
        self.ads=(NSMutableArray<Ad> *)[NSMutableArray array];
    }
    return self;
}

@end
