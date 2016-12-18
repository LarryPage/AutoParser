//
//  StatusResult.m
//  AutoParser
//
//  Created by LiXiangCheng on 16/9/16.
//  Copyright © 2016年 LiXiangCheng. All rights reserved.
//

#import "StatusResult.h"

@JSONImplementation(StatusResult)

#pragma mark override

-(id) init{
    self = [super init];
    if (self) {
        // Initialization code
        self.statuses=(JSONMutableArray(Status) *)[NSMutableArray array];
        self.ads=(JSONMutableArray(Ad) *)[NSMutableArray array];
        //self.numberList=[NSMutableArray array];
        self.numberList=(JSONMutableArray(NSNumber) *)[NSMutableArray array];
        //self.stringList=[NSMutableArray array];
        self.stringList=(JSONMutableArray(NSString) *)[NSMutableArray array];
    }
    return self;
}

@end
