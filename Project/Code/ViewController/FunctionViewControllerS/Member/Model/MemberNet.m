//
//  MemberNet.m
//  Project
//
//  Created by mini on 2018/8/1.
//  Copyright © 2018年 CDJay. All rights reserved.
//

#import "MemberNet.h"
#import "MemberRow.h"

@implementation MemberNet

- (instancetype)init{
    self = [super init];
    if (self) {
        _dataList = [[NSMutableArray alloc]init];
        [self initRows];
    }
    return self;
}

- (void)initRows{
    NSArray *titles = @[@"签到领红包",@"推荐码",@"我要赚钱",@"我的账单",@"我要充值",@"我要提现",@"我的玩家",@"版本",@"设置"];
    NSArray *images = @[@"my-sign",@"my-code",@"my-money",@"my-bill",@"my-recharge",@"my-withdrawals",@"my-player",@"my-version",@"my-option"];
    NSString *referralCode = (APP_MODEL.user.userInvitecode.length>0)?APP_MODEL.user.userInvitecode:@"";
    NSArray *rights = @[referralCode,@"推荐",[NSString appVersion]];
    NSArray *vcs = @[@"",@"",@"MakeMoneyViewController",@"BillViewController",@"TopupViewController",@"WithdrawalViewController",@"RecommendedViewController",@"",@"SettingViewController"];
    NSMutableArray *section1 = [[NSMutableArray alloc]init];
    for (int i = 0; i<titles.count; i++) {
        CDTableModel *model = [CDTableModel new];
        model.className = @"MemberCell";
        MemberRow *item = [MemberRow new];
        item.imageName = (images[i])?images[i]:@"";
        item.title = (titles[i])?titles[i]:@"";
        item.type = (i == 1 || i == 7)?0:1;
        item.vcName = vcs[i];
        if (i == 1) {
            item.subValue = rights[0];
        }
        if (i == 6) {
            item.subValue = rights[1];
        }
        if (i == 7) {
            item.subValue = rights[2];
        }
        model.obj = item;
        [section1 addObject:model];
    }
    CDTableModel *model = [CDTableModel new];
    model.className = @"MemberCell";
    MemberRow *logout = [[MemberRow alloc]init];
    logout.title = @"退出";
    logout.imageName = @"my-exit";
    logout.type = 1;
    model.obj = logout;
    NSArray *section2 = @[model];
    [_dataList addObject:section1];
    [_dataList addObject:section2];
}

+ (void)TopupObj:(id)obj
         Success:(void (^)(NSDictionary *))success
         Failure:(void (^)(NSError *))failue{
    CDBaseNet *net = [CDBaseNet normalNet];
    net.param = obj;
    net.path = Line_TopupNew;
    [net doGetSuccess:^(NSDictionary *dic) {
        NSLog(@"%@",dic);
        if (CD_Success([dic objectForKey:@"status"], 1)) {
            success(dic);
        }
        else{
            failue(tipError(dic[@"msg"], 0));
        }
    } failure:^(NSError *error) {
        failue(error);
    }];
}

+ (void)WithdrawalObj:(id)obj
              Success:(void (^)(NSDictionary *))success
              Failure:(void (^)(NSError *))failue{
    
}


+ (void)SignObj:(id)obj
        Success:(void (^)(NSDictionary *))success
        Failure:(void (^)(NSError *))failue{
    CDBaseNet *net = [CDBaseNet normalNet];
    net.param = obj;
    net.path = Line_SIGN;
    [net doGetSuccess:^(NSDictionary *dic) {
        NSLog(@"%@",dic);
        if (CD_Success([dic objectForKey:@"status"], 1)) {
            success(dic);
        }
        else{
            failue(tipError(dic[@"msg"], 0));
        }
    } failure:^(NSError *error) {
        failue(error);
    }];
}
@end
