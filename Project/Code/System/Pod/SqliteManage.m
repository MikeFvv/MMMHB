//
//  SqliteManage.m
//  Project
//
//  Created by mini on 2018/8/9.
//  Copyright © 2018年 CDJay. All rights reserved.
//

#import "SqliteManage.h"
#import "WHC_ModelSqlite.h"
#import "MessageItem.h"

@implementation SqliteManage
+ (SqliteManage *)shareInstance{
    static SqliteManage *instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[[self class] alloc] init];
    });
    return instance;
}

+ (void)updateGroup:(NSString *)groupId number:(int)number lastMessage:(NSString *)message{
    //NSString *path = [NSString stringWithFormat:@"%@_%@_%d",url_preix,APP_MODEL.user.userId,rongYunMode];
    NSString *query = [NSString stringWithFormat:@"groupId='%@'",groupId];
    MessageItem *old = [[WHC_ModelSqlite query:[MessageItem class] where:query] firstObject];
    if (old) {
        if(number == -1)
            old.number = 0;
        else
            old.number += number;
        old.lastMessage = message;
        [WHC_ModelSqlite update:old where:query];
    }else{
        if(number > 0){
            MessageItem *new = [MessageItem new];
            new.number = number;
            new.lastMessage = message;
            new.groupId = groupId;
            //new.path = path;
            [WHC_ModelSqlite insert:new];
        }
    }
    [APP_MODEL saveToDisk];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CDReadNumberChange" object:nil];
}

//+ (void)removeGroup:(NSString *)group{
//    NSString *path = [NSString stringWithFormat:@"%@_%@_%d",url_preix,APP_MODEL.user.userId,rongYunMode];
//    NSString *query = [NSString stringWithFormat:@"groupId='%@'AND path='%@'",group,path];
//    [WHC_ModelSqlite delete:[MessageItem class] where:query];
//}

+ (MessageItem *)queryById:(NSString *)groupId{
    NSString *path = [NSString stringWithFormat:@"%@_%@_%d",url_preix,APP_MODEL.user.userId,rongYunMode];
    NSString *query = [NSString stringWithFormat:@"groupId='%@'AND path='%@'",groupId,path];
    return [[WHC_ModelSqlite query:[MessageItem class] where:query] firstObject];
}

+ (void)clean{
    [WHC_ModelSqlite removeModel:[MessageItem class]]; 
}

@end
