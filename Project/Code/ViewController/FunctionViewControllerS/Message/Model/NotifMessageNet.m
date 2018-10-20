//
//  NotifMessageNet.m
//  Project
//
//  Created by mini on 2018/8/15.
//  Copyright © 2018年 CDJay. All rights reserved.
//

#import "NotifMessageNet.h"

@implementation NotifMessageNet

- (instancetype)init{
    self = [super init];
    if (self) {
        _dataList = [[NSMutableArray alloc]init];
    }
    return self;
}


- (void)getNotifMessageObj:(id)obj
                   Success:(void (^)(NSDictionary *))success
                   Failure:(void (^)(NSError *))failue{
    CDBaseNet *net = [CDBaseNet normalNet];
    net.param = obj;
    net.path = Line_MessageList;
    CDWeakSelf(self);
    [net doGetSuccess:^(NSDictionary *dic) {
        CDStrongSelf(self);
        CDLog(@"%@",dic);
        if (CD_Success([dic objectForKey:@"status"], 1)) {
            NSDictionary *data = [dic objectForKey:@"data"];
            if (data != NULL) {
                self.page = [[data objectForKey:@"current_page"] integerValue];
                if (self.page == 1) {
                    [self.dataList removeAllObjects];
                }
                self.total = [[data objectForKey:@"total"]integerValue];
                NSArray *list = [data objectForKey:@"data"];
                for (id obj in list) {
                    CDTableModel *model = [CDTableModel new];
                    model.obj = obj;
                    model.className = @"NotifTableViewCell";
                    [self.dataList addObject:model];
                }
            }
            success(nil);
        }else{
            failue(tipError(dic[@"data"][@"msg"], 0));
        }
    } failure:^(NSError *error) {
        failue(error);
    }];
}

+ (void)getNotifDetailObj:(id)obj
                  Success:(void (^)(NSDictionary *))success
                  Failure:(void (^)(NSError *))failue{
    CDBaseNet *net = [CDBaseNet normalNet];
    net.param = obj;
    net.path = Line_MessageDetail;
    [net doGetSuccess:^(NSDictionary *dic) {
        NSLog(@"%@",dic);
        if (CD_Success([dic objectForKey:@"status"], 1)) {
            success(dic);
        }else{
            failue(tipError(dic[@"msg"], 0));
        }
    } failure:^(NSError *error) {
        NSLog(@"%@",[error debugDescription]);
        failue(error);
    }];
}

@end
