//
//  EnvelopeNet.m
//  Project
//
//  Created by mac on 2018/8/20.
//  Copyright © 2018年 CDJay. All rights reserved.
//

#import "EnvelopeNet.h"

@implementation EnvelopeNet

+ (EnvelopeNet *)shareInstance{
    static EnvelopeNet *instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[[self class] alloc] init];
    });
    return instance;
}

- (instancetype)init{
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


- (void)getListObj:(id)obj
           Success:(void (^)(NSDictionary *))success
           Failure:(void (^)(NSError *))failue{
    CDBaseNet *net = [CDBaseNet normalNet];
    net.param = obj;
    net.path = Line_PacketInfo;
    CDWeakSelf(self);
    [net doGetSuccess:^(NSDictionary *dic) {
        CDStrongSelf(self);
        CDLog(@"%@",dic);
        if (CD_Success([dic objectForKey:@"status"], 1)) {
            NSDictionary *data = [dic objectForKey:@"data"][@"list"];
            if (data != NULL) {
                self.page = [[data objectForKey:@"current_page"] integerValue];
                if (self.page == 1) {
                    self.user = [dic objectForKey:@"data"][@"user"];
                    [self.dataList removeAllObjects];
                    self.mids = [NSString stringWithFormat:@"%@",[dic objectForKey:@"data"][@"mids"]];
                }
                self.total = [[data objectForKey:@"total"]integerValue];
                self.pageSize = [[data objectForKeyedSubscript:@"per_page"] integerValue];
                self.IsEnd = (self.total == self.pageSize)?YES:NO;
                NSArray *list = [data objectForKey:@"data"];
                self.maxMoney = 0.00;
                for (id obj in list) {
                    CDTableModel *model = [CDTableModel new];
                    model.obj = obj;
                    model.className = @"EnvelopTableViewCell";
                    CGFloat money = [[obj objectForKey:@"grap_money"] floatValue];
                    self.maxMoney = (money > self.maxMoney)?money:self.maxMoney;
                    [self.dataList addObject:model];
                }
                self.IsEmpty = (self.dataList.count == 0)?YES:NO;
                self.IsMost = ((self.dataList.count % self.pageSize == 0)&(list.count>0))?NO:YES;
            }
            success(dic[@"send"]);
        }else{
            failue(tipError(dic[@"data"][@"msg"], 0));
        }
        
    } failure:^(NSError *error) {
        NSLog(@"%@",[error debugDescription]);
        failue(error);
    }];
}

+ (void)sendEnvelop:(id)obj
            Success:(void (^)(NSDictionary *))success
            Failure:(void (^)(NSError *))failue{
    CDBaseNet *net = [CDBaseNet normalNet];
    net.param = obj;
    net.path = Line_Packet;
    [net doGetSuccess:^(NSDictionary *dic) {
        NSLog(@"%@",dic);
        if (CD_Success([dic objectForKey:@"status"], 1)) {
            NSDictionary *data = [dic objectForKey:@"data"];
            if (data != NULL) {
                success(data);
            }
        }else{
            failue(tipError(dic[@"msg"], 0));
        }
    } failure:^(NSError *error) {
        failue(error);
    }];
}


+ (void)getEnvelop:(id)obj
           Success:(void (^)(NSDictionary *))success
           Failure:(void (^)(NSError *))failue{
    CDBaseNet *net = [CDBaseNet normalNet];
    net.param = obj;
    net.path = Line_GetPacket;
    [net doGetSuccess:^(NSDictionary *dic) {
        NSLog(@"%@",dic);
        if (CD_Success([dic objectForKey:@"status"], 1)) {
            NSDictionary *data = [dic objectForKey:@"data"];
            if (data != NULL) {
                success(data);
            }
        }else{
            failue(tipError(dic[@"msg"], 0));
        }
        
    } failure:^(NSError *error) {
        NSLog(@"%@",[error debugDescription]);
        failue(error);
    }];
}


+ (void)getEnvelopInfo:(id)obj
               Success:(void (^)(NSDictionary *))success
               Failure:(void (^)(NSError *))failue{
    CDBaseNet *net = [CDBaseNet normalNet];
    net.param = obj;
    net.path = Line_PacketState;
    [net doGetSuccess:^(NSDictionary *dic) {
        NSLog(@"%@",dic);
        if (CD_Success([dic objectForKey:@"status"], 1)) {
            NSDictionary *data = [dic objectForKey:@"data"];
            if (data != NULL) {
                success(data);
            }
        }else{
            failue(tipError(dic[@"msg"], 0));
        }
    } failure:^(NSError *error){
        failue(error);
    }];
}

@end
