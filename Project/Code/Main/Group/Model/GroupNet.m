//
//  GroupNet.m
//  Project
//
//  Created by mini on 2018/8/16.
//  Copyright © 2018年 CDJay. All rights reserved.
//

#import "GroupNet.h"
#import "BANetManager_OC.h"

@implementation GroupNet

-(instancetype)init {
    self = [super init];
    if (self) {
        _dataList = [[NSMutableArray alloc]init];
        _page = 1;
        _pageSize = 15;
        _isMost = NO;
        _isEmpty = NO;
    }
    return self;
}



/**
 查询群成员
 
 @param groupId 群ID
 @param successBlock 成功block
 @param failureBlock 失败block
 */
- (void)queryGroupUserGroupId:(NSString *)groupId
                 successBlock:(void (^)(NSDictionary *))successBlock
                 failureBlock:(void (^)(NSError *))failureBlock {

    BADataEntity *entity = [BADataEntity new];
    entity.urlString = [NSString stringWithFormat:@"%@%@?page=%zd&limit=%zd&orderByField=id&isAsc=false&groupId=%@",APP_MODEL.serverUrl,@"social/skChatGroup/groupUsers", self.page,self.pageSize,groupId];
    entity.needCache = NO;
    __weak __typeof(self)weakSelf = self;
    [BANetManager ba_request_GETWithEntity:entity successBlock:^(id response) {
         __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf processingData:response];
        successBlock(response);
        
    } failureBlock:^(NSError *error) {
        failureBlock(error);
    } progressBlock:nil];

}

- (void)processingData:(NSDictionary *)response {
    if (CD_Success([response objectForKey:@"code"], 0)) {
        NSDictionary *data = [response objectForKey:@"data"];
        if (data != NULL) {
            self.page = [[data objectForKey:@"current"] integerValue];
            if (self.page == 1) {
                [self.dataList removeAllObjects];
            }
            self.total = [[data objectForKey:@"total"]integerValue];
            NSArray *list = [data objectForKey:@"records"];
            for (id obj in list) {
                [self.dataList addObject:obj];
            }
            self.isEmpty = (self.dataList.count == 0)?YES:NO;
            self.isMost = ((self.dataList.count % self.pageSize == 0)&(list.count>0))?NO:YES;
        }
        
    }
}

@end
