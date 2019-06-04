

//
//  MessageNet.m
//  Project
//
//  Created by mini on 2018/8/1.
//  Copyright © 2018年 CDJay. All rights reserved.
//

#import "MessageNet.h"
#import "MessageItem.h"
#import "NetRequestManager.h"
#import "BANetManager_OC.h"
#import "PushMessageModel.h"
#import "SqliteManage.h"
#import "MessageSingle.h"

@implementation MessageNet

+ (MessageNet *)shareInstance {
    static MessageNet *instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[[self class] alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _dataList = [[NSMutableArray alloc]init];
        _page = 0;
        _pageSize = 15;
        _isMost = YES;
        _isEmpty = YES;
        _isMostMyJoin = YES;
        _isEmptyMyJoin = YES;
        _isOnce = YES;
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self getMyJoinedGroupListSuccessBlock:nil failureBlock:nil];
        });
    }
    return self;
}

- (NSArray *)localList {
    CDTableModel *service = [CDTableModel new];
    MessageItem *service_model = [MessageItem new];
    service.className = @"MessageTableViewCell";
    service_model.localImg = @"msg4";   // 图片名称
    service_model.chatgName = @"在线客服";
    service_model.groupId = @"";
    service_model.notice = @"有问题，找客服";
    service.obj = service_model;
    
    //    return @[notif,service];
    return @[service];
}


/**
 加入群组
 
 @param groupId 群ID
 @param successBlock 成功block
 @param failureBlock 失败block
 */
- (void)joinGroup:(NSString *)groupId
         password:(NSString *)password
     successBlock:(void (^)(NSDictionary *))successBlock
     failureBlock:(void (^)(NSError *))failureBlock {
    
    NSDictionary *parameters = @{
                                 @"id":groupId,
                                 @"pwd":password == nil ? @"" :password
                                 };
    
    BADataEntity *entity = [BADataEntity new];
    entity.urlString = [NSString stringWithFormat:@"%@%@",[AppModel shareInstance].serverUrl,@"social/skChatGroup/join"];
    entity.parameters = parameters;
    entity.needCache = NO;
    
    __weak __typeof(self)weakSelf = self;
    [BANetManager ba_request_POSTWithEntity:entity successBlock:^(id response) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        if ([[response objectForKey:@"code"] integerValue] == 0) {
            [strongSelf queryMyJoinGroup];
        }
        successBlock(response);
    } failureBlock:^(NSError *error) {
        failureBlock(error);
    } progressBlock:nil];
}

/**
 获取我加入的群组
 
 @param successBlock 成功block
 @param failureBlock 失败block
 */
-(void)getMyJoinedGroupListSuccessBlock:(void (^)(NSDictionary *))successBlock
                           failureBlock:(void (^)(NSError *))failureBlock {
    
    BADataEntity *entity = [BADataEntity new];
    entity.urlString = [NSString stringWithFormat:@"%@%@?page=1&limit=100&orderByField=id&isAsc=false",[AppModel shareInstance].serverUrl,@"social/skChatGroup/joinGroupPage"];
    
    entity.needCache = NO;
    
    __weak __typeof(self)weakSelf = self;
    [BANetManager ba_request_GETWithEntity:entity successBlock:^(id response) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        //        NSLog(@"get 请求数据结果： *** %@", response);
        
        if ([response[@"status"] integerValue] >= 1) {
            
        } else {
            [strongSelf handleGroupListData:response[@"data"] andIsMyJoined:YES];
        }
        if (successBlock) {
            successBlock(response);
        }
    } failureBlock:^(NSError *error) {
        if (failureBlock) {
            failureBlock(error);
        }
    } progressBlock:nil];
}


/**
 获取所有群组列表
 
 @param successBlock 成功block
 @param failureBlock 失败block
 */
-(void)getGroupListWithSuccessBlock:(void (^)(NSDictionary *))successBlock
                       failureBlock:(void (^)(NSError *))failureBlock {
    
    BADataEntity *entity = [BADataEntity new];
    entity.urlString = [NSString stringWithFormat:@"%@%@?page=1&limit=100&orderByField=id&isAsc=false",[AppModel shareInstance].serverUrl,@"social/skChatGroup/page"];;
    
    entity.needCache = NO;
    
    __weak __typeof(self)weakSelf = self;
    [BANetManager ba_request_GETWithEntity:entity successBlock:^(id response) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        //        NSLog(@"get 请求数据结果： *** %@", response);
        [strongSelf handleGroupListData:response[@"data"] andIsMyJoined:NO];
        successBlock(response);
        
    } failureBlock:^(NSError *error) {
        failureBlock(error);
    } progressBlock:nil];
}

-(void)handleGroupListData:(NSDictionary *)data andIsMyJoined:(BOOL)isMyJoined {
    if (data != NULL && [data isKindOfClass:[NSDictionary class]]) {
        self.page = [[data objectForKey:@"current"] integerValue];
        if (self.page == 1) {
            if(isMyJoined) {
                self.myJoinDataList = [[NSMutableArray alloc]initWithArray:self.localList];
                //                [self.myJoinDataList removeAllObjects];
            } else {
                self.dataList = [[NSMutableArray alloc] init];
                //                self.dataList = [[NSMutableArray alloc]initWithArray:self.localList];
            }
        }
        self.total = [[data objectForKey:@"size"]integerValue];
        NSArray *list = [data objectForKey:@"records"];
        if (isMyJoined) {
            [AppModel shareInstance].unReadCount = 0;
            NSMutableArray *marray = [NSMutableArray array];
            for (id item in list) {
                
                NSString *queryId = [NSString stringWithFormat:@"%@-%@",[item objectForKey:@"id"],[AppModel shareInstance].userInfo.userId];
                PushMessageModel *pmModel = (PushMessageModel *)[MessageSingle shareInstance].myJoinGroupMessage[queryId];
                [AppModel shareInstance].unReadCount += pmModel.number;
                
                
                CDTableModel *model = [CDTableModel new];
                NSMutableDictionary *group = [[NSMutableDictionary alloc]initWithDictionary:item];
                [group setObject:@(YES) forKey:@"isMyJoined"];
                model.obj = group;
                model.className = @"MessageTableViewCell";
                [self.myJoinDataList addObject:model];
                // 保存群ID
                [marray addObject:[[item objectForKey:@"id"] stringValue]];
                
            }
            
            [AppModel shareInstance].myGroupArray = marray;
            
            if (self.isOnce) {
                self.isOnce = NO;
                [[NSNotificationCenter defaultCenter] postNotificationName:kDoneGetMyJoinedGroupsNotification object:nil];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:kUnreadMessageNumberChange object:nil];
            
            self.isEmptyMyJoin = (self.myJoinDataList.count == 0)?YES:NO;
            self.isMostMyJoin = ((self.myJoinDataList.count % self.pageSize == 0)&(list.count>0))?NO:YES;
        }else{
            for (id item in list) {
                CDTableModel *model = [CDTableModel new];
                model.obj = item;
                model.className = @"MessageTableViewCell";
                [self.dataList addObject:model];
            }
            self.isEmpty = (self.dataList.count == 0)?YES:NO;
            self.isMost = ((self.dataList.count % self.pageSize == 0)&(list.count>0))?NO:YES;
        }
        
    } else {
        // 没有数据
        if ([AppModel shareInstance].unReadCount > 0) {
            [AppModel shareInstance].unReadCount = 0;
            [[NSNotificationCenter defaultCenter] postNotificationName:kUnreadMessageNumberChange object:nil];
        }
        
    }
}

- (void)checkGroupId:(NSString *)groupId
           Completed:(void (^)(BOOL complete))completed {
    
    if (self.myJoinDataList.count == 0) {
        
        __weak __typeof(self)weakSelf = self;
        [self getMyJoinedGroupListSuccessBlock:^(NSDictionary *info) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            completed([strongSelf isContainGroup:groupId]);
        } failureBlock:^(NSError *error) {
            [[FunctionManager sharedInstance] handleFailResponse:error];
        }];
        
    } else {
        completed([self isContainGroup:groupId]);
    }
    
    
}

- (BOOL)isContainGroup:(NSString *)groupId {
    BOOL b = NO;
    for (CDTableModel *item in self.myJoinDataList) {
        
        NSString *gid = [NSString stringWithFormat:@"%ld",([item.obj isKindOfClass:[NSDictionary class]] ? [item.obj[@"id"] integerValue] : -1)];
        if ([groupId isEqualToString:gid]) {
            b = YES;
            break;
        }
    }
    return b;
}



- (void)removeGroup:(NSString *)groupId {
    for (CDTableModel *item in self.myJoinDataList) {
        NSString *gid = [NSString stringWithFormat:@"%ld",[item.obj[@"id"] integerValue]];//;
        if ([groupId isEqualToString:gid]) {
            [self.dataList removeObject:item];
            break;
        }
    }
}




- (void)queryMyJoinGroup {
    
    [self getMyJoinedGroupListSuccessBlock:^(NSDictionary *dict) {
    } failureBlock:^(NSError *error) {
    }];
    
}



/**********************************暂无使用到***********************************/

/**
 查询群组详情
 
 @param groupId 群ID
 @param successBlock 成功block
 @param failureBlock 失败block
 */
- (void)queryGroupDetails:(NSString *)groupId
             successBlock:(void (^)(NSDictionary *))successBlock
             failureBlock:(void (^)(NSError *))failureBlock {
    
    BADataEntity *entity = [BADataEntity new];
    entity.urlString = [NSString stringWithFormat:@"%@%@/%@",[AppModel shareInstance].serverUrl,@"social/skChatGroup", groupId];
    
    entity.needCache = NO;
    __weak __typeof(self)weakSelf = self;
    [BANetManager ba_request_GETWithEntity:entity successBlock:^(id response) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        //        NSLog(@"get 请求数据结果： *** %@", response);
        [strongSelf handleGroupListData:response[@"data"] andIsMyJoined:NO];
        successBlock(response);
        
    } failureBlock:^(NSError *error) {
        failureBlock(error);
    } progressBlock:nil];
    
}


@end
