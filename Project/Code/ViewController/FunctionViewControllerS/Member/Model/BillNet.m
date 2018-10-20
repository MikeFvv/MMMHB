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
        _beginTime = dateString_stamp(APP_MODEL.user.jointime, CDDateDay);
        _endTime = dateString_date([NSDate date], CDDateDay);
    }
    return self;
}


- (void)GetBillObj:(id)obj
           Success:(void (^)(NSDictionary *))success
           Failure:(void (^)(NSError *))failue{
    
    CDBaseNet *net = [CDBaseNet normalNet];
    net.param = obj;
    net.path = Line_NEWBillSELF;
    CDWeakSelf(self);
    [net doGetSuccess:^(NSDictionary *dic) {
        CDStrongSelf(self);
        if (CD_Success([dic objectForKey:@"status"], 1)) {
            NSDictionary *data = [dic objectForKey:@"data"];
            if (data != NULL) {
                if (self.page == 1) {
                    [self.dataList removeAllObjects];
                }
                self.total = [[data objectForKey:@"total"]integerValue];
                NSArray *list = [data objectForKey:@"data"];
                for (id obj in list) {
                    CDTableModel *model = [CDTableModel new];
                    model.obj = obj;
                    model.className = @"BillTableViewCell";
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
@end
