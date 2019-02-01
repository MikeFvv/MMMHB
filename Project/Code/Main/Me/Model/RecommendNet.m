//
//  RecommendNet.m
//  Project
//
//  Created by mini on 2018/8/2.
//  Copyright © 2018年 CDJay. All rights reserved.
//

#import "RecommendNet.h"
#import "RecommmendObj.h"

@implementation RecommendNet

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

- (void)getPlayerWithPage:(NSInteger)page success:(void (^)(NSDictionary *))success
             failure:(void (^)(NSError *))failue{
    WEAK_OBJ(weakSelf, self);
    [NET_REQUEST_MANAGER requestMyPlayerWithPage:page + 1 pageSize:self.pageSize orderField:@"id" asc:0 success:^(id object) {
        NSDictionary *data = [object objectForKey:@"data"];
        NSArray *list = data[@"records"];
        weakSelf.page = [data[@"current"] integerValue];
        if (list.count != 0) {
            if (weakSelf.page == 1) {
                [weakSelf.dataList removeAllObjects];
            }
            for (id obj in list) {
                CDTableModel *model = [CDTableModel new];
                model.obj = obj;
                model.className = @"RecommendCell";
                [weakSelf.dataList addObject:model];
            }
        }
        weakSelf.isEmpty = (weakSelf.dataList.count == 0)?YES:NO;
        weakSelf.isMost = ((weakSelf.dataList.count % weakSelf.pageSize == 0)&(list.count>0))?NO:YES;
        success(nil);
    } fail:^(id object) {
        failue(object);
    }];
}

@end
