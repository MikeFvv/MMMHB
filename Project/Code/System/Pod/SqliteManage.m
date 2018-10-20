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

+ (void)updateGroup:(NSString *)group number:(int)number lastMessage:(NSString *)last{
    NSString *path = [NSString stringWithFormat:@"%@_%@_%d",Line_pre,APP_MODEL.user.userId,isLine];
    NSString *query = [NSString stringWithFormat:@"groupId='%@'AND path='%@'",group,path];
    MessageItem *old = [[WHC_ModelSqlite query:[MessageItem class] where:query] firstObject];
    if (old) {
        if (number == 0) {
            APP_MODEL.unReadNumber -= old.number;
            old.number = 0;
        }else{
            old.number += 1;
            APP_MODEL.unReadNumber += 1;
        }
        
        if (last.length >0) {
            old.lastMessage = last;
        }
        [WHC_ModelSqlite update:old where:query];
    }else{
        APP_MODEL.unReadNumber += 1;
        MessageItem *new = [MessageItem new];
        new.number = 1;
        new.lastMessage = last;
        new.groupId = group;
        [WHC_ModelSqlite insert:new];
    }
    [APP_MODEL saveToDisk];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"CDReadNumberChange" object:nil];
}

+ (void)removeGroup:(NSString *)group{
    NSString *path = [NSString stringWithFormat:@"%@_%@_%d",Line_pre,APP_MODEL.user.userId,isLine];
    NSString *query = [NSString stringWithFormat:@"groupId='%@'AND path='%@'",group,path];
    [WHC_ModelSqlite delete:[MessageItem class] where:query];
}

+ (MessageItem *)queryById:(NSString *)groupId{
    NSString *path = [NSString stringWithFormat:@"%@_%@_%d",Line_pre,APP_MODEL.user.userId,isLine];
    NSString *query = [NSString stringWithFormat:@"groupId='%@'AND path='%@'",groupId,path];
    return [[WHC_ModelSqlite query:[MessageItem class] where:query] firstObject];
}

+ (void)clean{
    [WHC_ModelSqlite removeModel:[MessageItem class]]; 
}

@end
