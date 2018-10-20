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
        _IsMost = NO;
        _IsEmpty = NO;
    }
    return self;
}

- (void)getPlayerObj:(id)obj
             Success:(void (^)(NSDictionary *))success
             Failure:(void (^)(NSError *))failue{
    CDBaseNet *net = [CDBaseNet normalNet];
    net.path = Line_Recommended;
    NSString *uid = [obj objectForKey:@"uid"];
//    NSString *md5str = [NSString stringWithFormat:@"p=%ld&uid=%@&key=%@",_page,uid,H_KEY];
//    NSString *md =
    NSMutableDictionary *param = [[NSMutableDictionary alloc]init];
    [param setObject:uid forKey:@"uid"];
    [param setObject:@(_page) forKey:@"p"];
//    [param setObject:[md5str MD5ForLower32Bate] forKey:@"token"];
    net.param = param;
    CDWeakSelf(self);
    [net doGetSuccess:^(NSDictionary *dic) {
        CDLog(@"%@",dic);
        CDStrongSelf(self);
        if (CD_Success([dic objectForKey:@"status"], 1)) {
            NSArray *list = [dic objectForKey:@"data"];
            if (list.count != 0) {
                if (self.page == 1) {
                    [self.dataList removeAllObjects];
                }
                for (id obj in list) {
                    CDTableModel *model = [CDTableModel new];
                    model.obj = obj;
                    model.className = @"RecommendCell";
                    [self.dataList addObject:model];
                }
            }
            self.IsEmpty = (self.dataList.count == 0)?YES:NO;
            self.IsMost = ((self.dataList.count % self.pageSize == 0)&(list.count>0))?NO:YES;
            success(nil);
        }else{
            failue(tipError(dic[@"data"][@"msg"], 0));
        }
    } failure:^(NSError *error) {
        failue(error);
    }];
}

@end
