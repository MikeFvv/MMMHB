//
//  ModelHelper.m
//  Project
//
//  Created by mac on 2018/10/15.
//  Copyright © 2018年 CDJay. All rights reserved.
//

#import "ModelHelper.h"

static ModelHelper *instance = nil;

@implementation ModelHelper
+(instancetype)sharedInstance{
    static dispatch_once_t instFun;
    dispatch_once(&instFun, ^{
        if(instance == nil){
            instance = [[ModelHelper alloc] init];
        }
    });
    return instance;
}

+(void)destroyInstance{
    if(instance){
        instance = nil;
    }
}

-(MessageItem *)getMessageItem:(NSDictionary *)dict{
    MessageItem *item = [[MessageItem alloc] init];
    if(dict){
        NSDictionary *detail = dict[@"detail"];
        NSDictionary *ruleBomb = dict[@"ruleBomb"];
        item.groupId = [NSString stringWithFormat:@"%ld",[detail[@"id"] integerValue]];
        item.groupName = detail[@"name"];
        item.img = detail[@"img"];
        item.joinMoney = detail[@"joinMoney"];
        item.know = detail[@"know"];
        item.rule = detail[@"rule"];
        item.notice = detail[@"notice"];
        item.localType = [dict[@"localType"] integerValue];
        item.status = [detail[@"active"] integerValue];
        if([ruleBomb isKindOfClass:[NSDictionary class]]){
            // 判断是否扫雷群 Mike
            item.type = 1;
            
            item.maxMoney = ruleBomb[@"maxMoney"];
            item.minMoney = ruleBomb[@"minMoney"];
            
            item.count = ruleBomb[@"count"];
            item.handicap = ruleBomb[@"handicap"];
            item.ruleBombId = ruleBomb[@"id"];
            item.name = ruleBomb[@"name"];
        }
    }
    return item;
}
@end
