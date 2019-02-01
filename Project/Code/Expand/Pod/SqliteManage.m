//
//  SqliteManage.m
//  Project
//
//  Created by mini on 2018/8/9.
//  Copyright © 2018年 CDJay. All rights reserved.
//

#import "SqliteManage.h"
#import "WHC_ModelSqlite.h"
#import "PushMessageModel.h"

@implementation SqliteManage
+ (SqliteManage *)shareInstance {
    static SqliteManage *instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[[self class] alloc] init];
    });
    return instance;
}

+ (void)updateGroup:(NSString *)group number:(int)number lastMessage:(NSString *)last {
    NSString *query = [NSString stringWithFormat:@"groupId='%@' AND userId='%@'",group,APP_MODEL.user.userId];
    PushMessageModel *oldModel = [[WHC_ModelSqlite query:[PushMessageModel class] where:query] firstObject];
    if (oldModel) {
        if (number == 0) {
            [AppModel shareInstance].unReadCount -= oldModel.number;
            oldModel.number = 0;
        } else {
            oldModel.number += 1;
            [AppModel shareInstance].unReadCount += 1;
        }
        
        if (last.length >0) {
            oldModel.lastMessage = last;
        }
        [WHC_ModelSqlite update:oldModel where:query];
    } else {
        [AppModel shareInstance].unReadCount += 1;
        PushMessageModel *new = [PushMessageModel new];
        new.number = 1;
        new.lastMessage = last;
        new.groupId = group;
        new.userId = [AppModel shareInstance].user.userId;
        [WHC_ModelSqlite insert:new];
    }
//    [[AppModel shareInstance] save];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"CDReadNumberChange" object:nil];
}

+ (void)removeGroup:(NSString *)group{
    NSString *path = [NSString stringWithFormat:@"%@",APP_MODEL.user.userId];
    NSString *query = [NSString stringWithFormat:@"groupId='%@'AND userId='%@'",group,path];
    [WHC_ModelSqlite delete:[PushMessageModel class] where:query];
}

+ (PushMessageModel *)queryById:(NSString *)groupId{
    NSString *path = [NSString stringWithFormat:@"%@",APP_MODEL.user.userId];
    NSString *query = [NSString stringWithFormat:@"groupId='%@' AND userId='%@'",groupId,path];
    return [[WHC_ModelSqlite query:[PushMessageModel class] where:query] firstObject];
}

+ (void)clean{
    [WHC_ModelSqlite removeModel:[PushMessageModel class]];
}

@end
