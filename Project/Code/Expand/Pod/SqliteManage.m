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
#import "FYMessage.h"

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
    NSString *query = [NSString stringWithFormat:@"sessionId='%@' AND userId='%@'",group,[AppModel shareInstance].userInfo.userId];
    PushMessageModel *oldModel = [[WHC_ModelSqlite query:[PushMessageModel class] where:query] firstObject];
    
    if (oldModel) {
        
        if (number == 0) {
            [AppModel shareInstance].unReadCount -= oldModel.number;
            oldModel.number = 0;
        } else {
            if (oldModel.number > 99) {
                return;
            }
            oldModel.number += 1;
            [AppModel shareInstance].unReadCount += 1;
        }
        
        if (last.length >0) {
            oldModel.lastMessage = last;
        }
         dispatch_async(dispatch_get_global_queue(0, 0), ^{
             [WHC_ModelSqlite update:oldModel where:query];
         });
    } else {
        if (number == 0) {
            return;
        }
        
        [AppModel shareInstance].unReadCount += 1;
        PushMessageModel *new = [PushMessageModel new];
        new.number = 1;
        new.lastMessage = last;
        new.sessionId = group;
        new.userId = [AppModel shareInstance].userInfo.userId;
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
           [WHC_ModelSqlite insert:new];
        });
        
    }
//    [[AppModel shareInstance] save];
    
    if (oldModel.number <= 99) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[NSNotificationCenter defaultCenter]postNotificationName:@"CDReadNumberChange" object:nil];
        });
    }
    
}

+ (void)removeGroupSql:(NSString *)groupId {
    NSString *query = [NSString stringWithFormat:@"sessionId='%@'",groupId];
    [WHC_ModelSqlite delete:[FYMessage class] where:query];
    
    NSString *queryWhere = [NSString stringWithFormat:@"sessionId='%@' AND userId='%@'",groupId,[AppModel shareInstance].userInfo.userId];
    [WHC_ModelSqlite delete:[PushMessageModel class] where:queryWhere];
}

+ (PushMessageModel *)queryById:(NSString *)groupId{
    NSString *queryWhere = [NSString stringWithFormat:@"sessionId='%@' AND userId='%@'",groupId,[AppModel shareInstance].userInfo.userId];
    return [[WHC_ModelSqlite query:[PushMessageModel class] where:queryWhere] firstObject];
}

+ (void)clean{
    [WHC_ModelSqlite removeModel:[PushMessageModel class]];
}

@end
