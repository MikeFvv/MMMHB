//
//  GroupNet.m
//  Project
//
//  Created by mini on 2018/8/16.
//  Copyright © 2018年 CDJay. All rights reserved.
//

#import "GroupNet.h"

@implementation GroupNet

-(instancetype)init{
    self = [super init];
    if (self) {
        _dataList = [[NSMutableArray alloc]init];
        _page = 0;
        _pageSize = 15;
        _IsMost = NO;
        _IsEmpty = NO;
    }
    return self;
}

- (void)queryUserObj:(id)obj
             Success:(void (^)(NSDictionary *))success
             Failure:(void (^)(NSError *))failue{
    CDBaseNet *net = [CDBaseNet normalNet];
    net.param = obj;
    net.path = Line_GetGroupInfo;
    CDWeakSelf(self);
    [net doGetSuccess:^(NSDictionary *dic) {
        CDLog(@"%@",dic);
        CDStrongSelf(self);
        if (CD_Success([dic objectForKey:@"status"], 1)) {
            NSDictionary *data = [dic objectForKey:@"data"][@"list"];
            if (data != NULL) {
                self.page = [[data objectForKey:@"current_page"] integerValue];
                if (self.page == 1) {
                        [self.dataList removeAllObjects];
                }
                self.total = [[data objectForKey:@"total"]integerValue];
                NSArray *list = [data objectForKey:@"data"];
                for (id obj in list) {
                    [self.dataList addObject:obj];
                }
                self.IsEmpty = (self.dataList.count == 0)?YES:NO;
                self.IsMost = ((self.dataList.count % self.pageSize == 0)&(list.count>0))?NO:YES;
            }
            success(dic);
        }else{
            failue(tipError(dic[@"data"][@"msg"], 0));
        }
    } failure:^(NSError *error) {
        failue(error);
    }];
}

@end
