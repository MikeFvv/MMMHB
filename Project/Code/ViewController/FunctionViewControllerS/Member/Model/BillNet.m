//
//  BillNet.m
//  Project
//
//  Created by mini on 2018/8/14.
//  Copyright © 2018年 CDJay. All rights reserved.
//

#import "BillNet.h"
#import "BillItem.h"
#import "NetRequestManager.h"

@implementation BillNet

- (instancetype)init{
    self = [super init];
    if (self) {
        _dataList = [[NSMutableArray alloc]init];
        _beginTime = dateString_date([NSDate date], CDDateDay);
        _endTime = dateString_date([NSDate date], CDDateDay);
    }
    return self;
}

-(void)getBillListWithSuccess:(void (^)(NSDictionary *))success
                      Failure:(void (^)(NSError *))failue{
    WEAK_OBJ(weakObj, self);
    [NET_REQUEST_MANAGER requestBillListWithType:self.type beginTime:timeStamp_string(self.beginTime, CDDateDay) endTime:timeStamp_string(self.endTime, CDDateDay) page:self.page pageSize:PAGE_SIZE orderField:@"bill_id" asc:NO success:^(id object) {
        [weakObj handleSuccess:object];
        success(object);
    } fail:^(id object) {
        failue(object);
    }];
}

//- (void)GetBillObj:(id)obj
//           Success:(void (^)(NSDictionary *))success
//           Failure:(void (^)(NSError *))failue{
//
//    CDBaseNet *net = [CDBaseNet normalNet];
//    net.param = obj;
//    net.path = Line_NEWBillSELF;
//    CDWeakSelf(self);
//    [net doGetSuccess:^(NSDictionary *dic) {
//        CDStrongSelf(self);
//        if (CD_Success([dic objectForKey:@"status"], 1)) {
//            NSDictionary *data = [dic objectForKey:@"data"];
//            if (data != NULL) {
//                if (self.page == 1) {
//                    [self.dataList removeAllObjects];
//                }
//                self.total = [[data objectForKey:@"total"]integerValue];
//                NSArray *list = [data objectForKey:@"data"];
//                for (id obj in list) {
//                    CDTableModel *model = [CDTableModel new];
//                    model.obj = obj;
//                    model.className = @"BillTableViewCell";
//                    [self.dataList addObject:model];
//                }
//                self.IsMost = ((self.dataList.count % PAGE_SIZE == 0)&(list.count>0))?NO:YES;
//            }
//            self.IsEmpty = (self.dataList.count == 0)?YES:NO;
//            success(nil);
//        }else{
//            failue(tipError(dic[@"data"][@"msg"], 0));
//        }
//    } failure:^(NSError *error) {
//        failue(error);
//    }];
//
//
//}

-(void)handleSuccess:(NSDictionary *)dic{
    NSDictionary *data = [dic objectForKey:@"data"];
    if (data != NULL) {
        self.page = [[data objectForKey:@"current"] integerValue];
        if (self.page == 1) {
            [self.dataList removeAllObjects];
        }
        self.total = [[data objectForKey:@"total"]integerValue];
        NSArray *list = [data objectForKey:@"records"];
        for (id obj in list) {
            CDTableModel *model = [CDTableModel new];
            model.obj = obj;
            model.className = @"BillTableViewCell";
            [self.dataList addObject:model];
        }
        self.isMost = ((self.dataList.count % PAGE_SIZE == 0)&(list.count>0))?NO:YES;
    }
    self.isEmpty = (self.dataList.count == 0)?YES:NO;
}
@end
