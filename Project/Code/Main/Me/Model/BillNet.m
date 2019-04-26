//
//  BillNet.m
//  Project
//
//  Created by mini on 2018/8/14.
//  Copyright © 2018年 CDJay. All rights reserved.
//

#import "BillNet.h"
#import "BillItem.h"

@implementation BillNet

- (instancetype)init{
    self = [super init];
    if (self) {
        _dataList = [[NSMutableArray alloc]init];
        _pageSize = 15;
        _page = 0;
        _beginTime = dateString_date([NSDate date], CDDateDay);
        _endTime = dateString_date([NSDate date], CDDateDay);
    }
    return self;
}

- (void)getBillListWithPage:(NSInteger)page
           success:(void (^)(NSDictionary *))success
           failure:(void (^)(NSError *))failue{
    CDWeakSelf(self);
    [NET_REQUEST_MANAGER requestBillListWithName:self.billName categoryStr:self.categoryStr beginTime:self.beginTime endTime:self.endTime page:page+1 pageSize:self.pageSize success:^(id object) {
        NSDictionary *dic = (NSDictionary *)object;
        CDStrongSelf(self);
        if (dic[@"code"] && [dic[@"code"] integerValue] == ResultCodeSuccess) {
            NSDictionary *data = [dic objectForKey:@"data"];
            if (data != NULL) {
                self.page = [data[@"current"] integerValue];
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
                
                if (self.dataList.count > 0) {
                    self.isMost = ((self.dataList.count % self.pageSize == 0)&(list.count>0))?NO:YES;
                } else {
                    self.isMost = NO;
                }
                
            }
            self.isEmpty = (self.dataList.count == 0)?YES:NO;
            success(nil);
        }else{
            failue(object);
        }
    } fail:^(id object) {
        failue(object);
    }];
}
@end
