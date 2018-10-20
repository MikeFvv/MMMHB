//
//  UserModel.m
//  Project
//
//  Created by mini on 2018/8/1.
//  Copyright © 2018年 CDJay. All rights reserved.
//

#import "UserModel.h"


@implementation UserModel

MJCodingImplementation

+ (NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{@"uid": @"id"};
}


//+ (void)getUserInfoObj:(id)obj
//               Success:(void (^)(NSDictionary *))success
//               Failure:(void (^)(NSError *))failue{
//    CDBaseNet *net = [CDBaseNet normalNet];
//    net.param = obj;
//    net.path = Line_UserInfo;
//    [net doGetSuccess:^(NSDictionary *dic) {
//        NSLog(@"%@",dic);
//        if (CD_Success([dic objectForKey:@"status"], 1)) {
//            success([dic objectForKey:@"data"]);
//        }else{
//            failue(nil);
//        }
//        
//    } failure:^(NSError *error) {
//        NSLog(@"%@",[error debugDescription]);
//        failue(error);
//    }];
//}

@end
