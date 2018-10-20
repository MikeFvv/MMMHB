//
//  MessageNet.m
//  Project
//
//  Created by mini on 2018/8/1.
//  Copyright © 2018年 CDJay. All rights reserved.
//

#import "MessageNet.h"
#import "MessageItem.h"
#import "SqliteManage.h"
#import "NetRequestManager.h"

@implementation MessageNet

+ (MessageNet *)shareInstance{
    static MessageNet *instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[[self class] alloc] init];
    });
    return instance;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        _dataList = [[NSMutableArray alloc]init];
        _page = 0;
        _pageSize = 15;
        _isMost = NO;
        _isEmpty = NO;
    }
    return self;
}

- (NSArray *)localList{
    CDTableModel *notif = [CDTableModel new];
    notif.className = @"MessageTableViewCell";
    MessageItem *notif_model = [MessageItem new];
    notif_model.localImg = @"msg1";
    notif_model.groupName = @"通知消息";
    notif_model.groupId = @"";
    notif_model.notice = @"活动最新消息（点击查看）";
    notif_model.dateline = 0;
    notif.obj = notif_model;
    
    CDTableModel *service = [CDTableModel new];
    MessageItem *service_model = [MessageItem new];
    service.className = @"MessageTableViewCell";
    service_model.localImg = @"msg4";
    service_model.groupName = @"在线客服";
    service_model.groupId = @"";
    service_model.notice = @"有问题，找客服。（点击查看）";
    service_model.dateline = 0;
    service.obj = service_model;
    
    return @[notif,service];
}

-(void)requestGroupListWithSuccess:(void (^)(NSDictionary *))success
                          Failure:(void (^)(NSError *))failue{
    WEAK_OBJ(weakSelf, self)
    [NET_REQUEST_MANAGER requestGroupListWithPage:self.page pageSize:PAGE_SIZE orderField:@"id" asc:NO success:^(id object) {
        [weakSelf handleGroupListData:object[@"data"] andIsMyJoined:NO];
        success(object);
    } fail:^(id object) {
        failue(object);
    }];
}

-(void)requestMyJoinedGroupListWithSuccess:(void (^)(NSDictionary *))success
                        Failure:(void (^)(NSError *))failue{
    WEAK_OBJ(weakSelf, self)
    [NET_REQUEST_MANAGER requestGroupListMyJoinedWithPage:self.page pageSize:PAGE_SIZE orderField:@"id" asc:NO success:^(id object) {
        [weakSelf handleGroupListData:object[@"data"] andIsMyJoined:YES];
        if(success)
            success(object);
        else
            [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadMyGroupList" object:nil];
    } fail:^(id object) {
        failue(object);
    }];
}

//- (void)getGroupObj:(id)obj
//            Success:(void (^)(NSDictionary *))success
//            Failure:(void (^)(NSError *))failue{
//    CDBaseNet *net = [CDBaseNet normalNet];
//    net.param = obj;
//    net.path = Line_ChatGroup;
//    CDWeakSelf(self);
//    [net doGetSuccess:^(NSDictionary *dic) {
//        CDLog(@"%@",dic);
//        if (CD_Success([dic objectForKey:@"status"], 1)) {
//            NSDictionary *data = [dic objectForKey:@"data"];
//            CDStrongSelf(self);
//            [self handleGroupListData:data andIsMyJoined:YES];
//            success(nil);
//        }else{
//            failue(tipError(dic[@"data"][@"msg"], 0));
//        }
//    } failure:^(NSError *error) {
//        failue(error);
//    }];
//}

-(void)handleGroupListData:(NSDictionary *)data andIsMyJoined:(BOOL)isMyJoined{
    if (data != NULL) {
        self.page = [[data objectForKey:@"current"] integerValue];
        if (self.page == 1) {
            if(!isMyJoined) {
                self.dataList = [[NSMutableArray alloc]initWithArray:self.localList];
            }else{
                [self.dataList removeAllObjects];
            }
        }
        self.total = [[data objectForKey:@"size"]integerValue];
        NSArray *list = [data objectForKey:@"records"];
        if (isMyJoined) {
            for (id item in list) {
                CDTableModel *model = [CDTableModel new];
                NSMutableDictionary *group = [[NSMutableDictionary alloc]initWithDictionary:item];
                [group setObject:@(1) forKey:@"localType"];
                model.obj = group;
                model.className = @"MessageTableViewCell";
                [self.dataList addObject:model];
            }
        }else{
            for (id item in list) {
                CDTableModel *model = [CDTableModel new];
                model.obj = item;
                model.className = @"MessageTableViewCell";
                [self.dataList addObject:model];
            }
        }
        self.isEmpty = (self.dataList.count == 0)?YES:NO;
        self.isMost = ((self.dataList.count % self.pageSize == 0)&(list.count>0))?NO:YES;
    }
}

- (void)checkGroupId:(NSString *)groupId
           Completed:(void (^)(BOOL complete))completed{
    if (self.dataList.count == 0) {
        WEAK_OBJ(weakSelf, self);
        [self requestMyJoinedGroupListWithSuccess:^(NSDictionary *info) {
            completed([weakSelf isContainGroup:groupId]);
        } Failure:^(NSError *error) {
            [FUNCTION_MANAGER handleFailResponse:error];
        }];
//        [self getGroupObj:@{@"uid":APP_MODEL.user.userId} Success:^(NSDictionary *info) {
//            completed([self isContainGroup:groupId]);
//        } Failure:^(NSError *error) {
//            SV_ERROR(error);
//            completed(NO);
//        }];
    }else
        completed([self isContainGroup:groupId]);
}

- (BOOL)isContainGroup:(NSString *)groupId{
    BOOL b = NO;
    for (CDTableModel *item in self.dataList) {
        NSString *gid = [NSString stringWithFormat:@"%ld",[item.obj[@"detail"][@"id"] integerValue]];//;
        if ([groupId isEqualToString:gid]) {
            b = YES;
            break;
        }
    }
    return b;
}

- (void)removeGroup:(NSString *)groupId{
    for (CDTableModel *item in self.dataList) {
        NSString *gid = [NSString stringWithFormat:@"%ld",[item.obj[@"detail"][@"id"] integerValue]];//;
        if ([groupId isEqualToString:gid]) {
            [self.dataList removeObject:item];
            break;
        }
    }
}


- (void)joinGroup:(NSString *)groupId
          success:(void (^)(NSDictionary *))success
          failure:(void (^)(NSError *))failue{
    WEAK_OBJ(weakSelf, self);
    [NET_REQUEST_MANAGER joinGroupWithId:groupId success:^(id object) {
        [weakSelf requestMyJoinedGroupListWithSuccess:^(NSDictionary *info) {
            
        } Failure:^(NSError *error) {
            
        }];
        success(nil);
    } fail:^(id object) {
        failue(object);
    }];
}

- (void)quitGroup:(NSString *)groupId
          success:(void (^)(NSDictionary *))success
          failure:(void (^)(NSError *))failue{
    WEAK_OBJ(weakSelf, self);
    [NET_REQUEST_MANAGER quitGroupWithId:groupId success:^(id object) {
        [weakSelf requestMyJoinedGroupListWithSuccess:^(NSDictionary *info) {
            
        } Failure:^(NSError *error) {
            
        }];
        success(nil);
    } fail:^(id object) {
        failue(object);
    }];
}




@end
