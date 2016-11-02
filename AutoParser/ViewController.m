//
//  ViewController.m
//  AutoParser
//
//  Created by LiXiangCheng on 16/9/16.
//  Copyright © 2016年 LiXiangCheng. All rights reserved.
//

#import "ViewController.h"
#import "StatusResult.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Action

/**
 *  模型定义->属性字典
 */
- (IBAction)propertiesOfModelBtn:(id)sender{
    NSDictionary *userPpropertiesDic = [NSObject propertiesOfClass:[User class]];
    NSLog(@"%@", userPpropertiesDic);
    
    NSDictionary *StatusResultPropertiesDic = [NSObject propertiesOfClass:[StatusResult class]];
    NSLog(@"%@", StatusResultPropertiesDic);
}

/**
 *  复杂的字典 -> 模型 (模型的数组属性里面又装着模型)
 */
- (IBAction)dic2modelBtn:(id)sender{
    // 1.定义一个字典
    NSDictionary *dic  = @{
                           @"statuses" : @[
                                   @{
                                       @"text" : @"今天天气真不错！",
                                       
                                       @"user" : @{
                                               @"name" : @"Rose",
                                               @"avatar" : @"nami.png"
                                               }
                                       },
                                   
                                   @{
                                       @"text" : @"明天去旅游了",
                                       
                                       @"user" : @{
                                               @"name" : @"Jack",
                                               @"avatar" : @"lufy.png",
                                               @"age" : @20,
                                               @"height" : @1.55,
                                               @"money" : @"100.9",
                                               @"sex" : @(1),
                                               @"gay" : @"true"
                                               },
                                       @"retweetedStatus" : @{
                                               @"text" : @"今天天气真不错！",
                                               
                                               @"user" : @{
                                                       @"name" : @"Rose",
                                                       @"avatar" : @"nami.png"
                                                       }
                                               }
                                       }
                                   
                                   ],
                           
                           @"ads" : @[
                                   @{
                                       @"image" : @"ad01.png",
                                       @"url" : @"http://www.ad01.com"
                                       },
                                   @{
                                       @"image" : @"ad02.png",
                                       @"url" : @"http://www.ad02.com"
                                       }
                                   ],
                           
                           @"totalNumber" : @"2014",
                           @"previousCursor" : @"13476589",
                           @"nextCursor" : @"13476599"
                           };
    
    // 2.将字典转为StatusResult模型
    long long timestamp = [[NSDate date] timeIntervalSince1970];
    StatusResult *record = [[StatusResult alloc] initWithDic:dic];
//    StatusResult *record1 = [record copy];
//    for (int i=0; i++; i<=30) {
//        [[StatusResult alloc] initWithDic:dic];
//    }
    double gapTime = [[NSDate date] timeIntervalSince1970] - timestamp;
    NSLog(@"解析时长:%@",@(gapTime));
    
    // 3.打印StatusResult模型的简单属性
    NSLog(@"totalNumber=%@, previousCursor=%@, nextCursor=%@", record.totalNumber, @(record.previousCursor), @(record.nextCursor));
    
    // 4.打印statuses数组中的模型属性
    for (Status *status in record.statuses) {
        NSString *text = status.text;
        NSString *name = status.user.name;
        NSString *icon = status.user.icon;
        NSLog(@"text=%@, name=%@, icon=%@", text, name, icon);
    }
    
    // 5.打印ads数组中的模型属性
    for (Ad *ad in record.ads) {
        NSLog(@"image=%@, url=%@", ad.image, ad.url);
    }
}

/**
 *  模型 (模型的数组属性里面又装着模型) -> 复杂的字典
 */
- (IBAction)model2dicBtn:(id)sender{
    // 1.新建模型
    User *user = [[User alloc] init];
    user.name = @"Jack";
    user.icon = @"lufy.png";
    
    Status *status = [[Status alloc] init];
    status.user = user;
    status.text = @"今天的心情不错！";
    
    Ad *ad =[[Ad alloc] init];
    ad.image=@"ad.png";
    ad.url=@"http://www.ad.com";
    
    StatusResult *record=[[StatusResult alloc] init];
    [record.statuses addObject:status];
    [record.ads addObject:ad];
    record.totalNumber=@2016;
    record.previousCursor=13476589;
    record.nextCursor=13476599;
    
    // 2.将模型转为字典
    NSDictionary *recordDic = [record dic];
    NSLog(@"%@", recordDic);
}

/**
 *  模型 (模型的数组属性里面又装着模型) -> json字符串
 */
- (IBAction)model2jsonBtn:(id)sender{
    // 1.新建模型
    User *user = [[User alloc] init];
    user.name = @"Jack";
    user.icon = @"lufy.png";
    
    Status *status = [[Status alloc] init];
    status.user = user;
    status.text = @"今天的心情不错！";
    
    Ad *ad =[[Ad alloc] init];
    ad.image=@"ad.png";
    ad.url=@"http://www.ad.com";
    
    StatusResult *record=[[StatusResult alloc] init];
    [record.statuses addObject:status];
    [record.ads addObject:ad];
    record.totalNumber=@2016;
    record.previousCursor=13476589;
    record.nextCursor=13476599;
    
    // 2.将模型转为字符串
    NSString *json = [record json];
    NSLog(@"%@", json);
}

/**
 *  json文件 -> 模型 (模型的数组属性里面又装着模型)  用于mock
 */
- (IBAction)json2modelBtn:(id)sender{
    // 1.从文件mock数据
    NSString* filePath = [[NSBundle mainBundle] resourcePath];
    filePath=[filePath stringByAppendingPathComponent:@"mock.json"];
    NSString *json=[NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
    
    // 2.将字典转为StatusResult模型
    StatusResult *record = [[StatusResult alloc] initWithJson:json];
    
    // 3.打印StatusResult模型的简单属性
    NSLog(@"totalNumber=%@, previousCursor=%@, nextCursor=%@", record.totalNumber, @(record.previousCursor), @(record.nextCursor));
    
    // 4.打印statuses数组中的模型属性
    for (Status *status in record.statuses) {
        NSString *text = status.text;
        NSString *name = status.user.name;
        NSString *icon = status.user.icon;
        NSLog(@"text=%@, name=%@, icon=%@", text, name, icon);
    }
    
    // 5.打印ads数组中的模型属性
    for (Ad *ad in record.ads) {
        NSLog(@"image=%@, url=%@", ad.image, ad.url);
    }
}

- (IBAction)modelSaveBtn:(id)sender{
    // 1.新建模型
    User *user = [[User alloc] init];
    user.name = @"Jack";
    user.icon = @"lufy.png";
    
    Status *status = [[Status alloc] init];
    status.user = user;
    status.text = @"今天的心情不错！";
    
    Ad *ad =[[Ad alloc] init];
    ad.image=@"ad.png";
    ad.url=@"http://www.ad.com";
    
    StatusResult *record=[[StatusResult alloc] init];
    [record.statuses addObject:status];
    [record.ads addObject:ad];
    record.totalNumber=@2016;
    record.previousCursor=13476589;
    record.nextCursor=13476599;
    
    // 2.归档模型对象
    // 2.1.获得Documents的全路径
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    // 2.2.获得文件的全路径
    NSString *path = [doc stringByAppendingPathComponent:@"statusResult.data"];
    // 2.3.将对象归档
    [NSKeyedArchiver archiveRootObject:record toFile:path];
    NSLog(@"对象已归档!!!!!!!");
}

- (IBAction)modelReadBtn:(id)sender{
    // 1.获得Documents的全路径
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    // 2.获得文件的全路径
    NSString *path = [doc stringByAppendingPathComponent:@"statusResult.data"];
    
    // 3.从文件中读取MJStudent对象
    StatusResult *record = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    
    // 4.打印StatusResult模型的简单属性
    NSLog(@"totalNumber=%@, previousCursor=%@, nextCursor=%@", record.totalNumber, @(record.previousCursor), @(record.nextCursor));
    
    // 5.打印statuses数组中的模型属性
    for (Status *status in record.statuses) {
        NSString *text = status.text;
        NSString *name = status.user.name;
        NSString *icon = status.user.icon;
        NSLog(@"text=%@, name=%@, icon=%@", text, name, icon);
    }
    
    // 6.打印ads数组中的模型属性
    for (Ad *ad in record.ads) {
        NSLog(@"image=%@, url=%@", ad.image, ad.url);
    }
}

@end
