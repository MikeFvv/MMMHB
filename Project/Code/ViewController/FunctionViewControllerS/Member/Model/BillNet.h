//
//  BillNet.h
//  Project
//
//  Created by mini on 2018/8/14.
//  Copyright © 2018年 CDJay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BillNet : NSObject

@property (nonatomic ,strong) NSMutableArray *dataList;
@property (nonatomic ,assign) NSInteger page;
@property (nonatomic ,assign) NSInteger total;
@property (nonatomic ,assign) NSInteger pageSize;
@property (nonatomic ,assign) NSInteger type;

@property (nonatomic ,copy) NSString *beginTime;
@property (nonatomic ,strong) NSString *endTime;

@property (nonatomic ,assign) BOOL IsEmpty;///<空
@property (nonatomic ,assign) BOOL IsMost;///<没有更多


//type 0全部 1-充值，2-转账，3-扣除，4-红包发布，5-提现
- (void)GetBillObj:(id)obj
           Success:(void (^)(NSDictionary *))success
           Failure:(void (^)(NSError *))failue;

@end
