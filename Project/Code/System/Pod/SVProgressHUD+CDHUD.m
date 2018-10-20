//
//  SVProgressHUD+CDHUD.m
//  Project
//
//  Created by mini on 2018/8/3.
//  Copyright © 2018年 CDJay. All rights reserved.
//

#import "SVProgressHUD+CDHUD.h"

@implementation SVProgressHUD (CDHUD)

+ (void)showError:(NSError *)error{
    NSDictionary *dic = error.userInfo;
    NSString *msg = @"服务器出错，稍后尝试~";
    if ([dic objectForKey:@"msg"]) {
        msg = [dic objectForKey:@"msg"];
    }
    else if ([dic objectForKey:@"NSLocalizedDescriptionKey"]){
        msg = [dic objectForKey:@"NSLocalizedDescriptionKey"];
    }
    else if ([dic objectForKey:@"NSErrorUserInfoKey"]){
        msg = [dic objectForKey:@"NSErrorUserInfoKey"];
    }
    [SVProgressHUD showErrorWithStatus:msg];
}

@end
