//
//  WithdrawalNet.m
//  Project
//
//  Created by mini on 2018/8/15.
//  Copyright © 2018年 CDJay. All rights reserved.
//

#import "WithdrawalNet.h"

@implementation WithdrawalNet
- (instancetype)init{
    self = [super init];
    if (self) {
        _dataList = [[NSMutableArray alloc]init];
        _pageSize = 15;
    }
    return self;
}

- (void)WithdrawalListObj:(id)obj
                  Success:(void (^)(NSDictionary *))success
                  Failure:(void (^)(NSError *))failue{
    
    CDBaseNet *net = [CDBaseNet normalNet];
    net.param = obj;
    net.path = Line_BankList;
    CDWeakSelf(self);
    [net doGetSuccess:^(NSDictionary *dic) {
        CDLog(@"%@",dic);
        CDStrongSelf(self);
        if (CD_Success([dic objectForKey:@"status"], 1)) {
            NSDictionary *data = [dic objectForKey:@"data"];
            if (data != NULL) {
                self.page = [[data objectForKey:@"current_page"] integerValue];
                if (self.page == 1) {
                    self.dataList = [[NSMutableArray alloc]init];
                }
                self.total = [[data objectForKey:@"total"]integerValue];
                NSArray *list = [data objectForKey:@"data"];
                for (id obj in list) {
                    CDTableModel *model = [CDTableModel new];
                    model.obj = obj;
                    model.className = @"WithHisListTableViewCell";
                    [self.dataList addObject:model];
                }
                 self.IsMost = ((self.dataList.count % self.pageSize == 0)&(list.count>0))?NO:YES;
            }
            self.IsEmpty = (self.dataList.count == 0)?YES:NO;
            success(nil);
        }else{
            failue(tipError(dic[@"data"][@"msg"], 0));
        }
    } failure:^(NSError *error) {
        failue(error);
    }];
}


+ (void)WithdrawalObj:(id)obj
              Success:(void (^)(NSDictionary *))success
              Failure:(void (^)(NSError *))failue{
    CDBaseNet *net = [CDBaseNet normalNet];
    net.param = obj;
    net.path = Line_Withdrawal;
    [net doGetSuccess:^(NSDictionary *dic) {
        NSLog(@"%@",dic);
        if (CD_Success([dic objectForKey:@"status"], 1)) {
            SV_SUCCESS_STATUS([dic objectForKey:@"msg"]);
            success(nil);
        }else{
            failue(tipError(dic[@"msg"], 0));
        }
    } failure:^(NSError *error) {
        failue(error);
    }];
}


@end
