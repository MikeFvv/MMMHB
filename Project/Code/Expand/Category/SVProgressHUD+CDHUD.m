//
//  SVProgressHUD+CDHUD.m
//  Project
//
//  Created by mini on 2018/8/3.
//  Copyright © 2018年 CDJay. All rights reserved.
//

#import "SVProgressHUD+CDHUD.h"

@implementation SVProgressHUD (CDHUD)

+ (void)showError:(NSError *)error {
    NSDictionary *dic = error.userInfo;
    NSString *msg = @"服务器连接失败,请稍后再试";
    if ([dic objectForKey:@"msg"]) {
        msg = [dic objectForKey:@"msg"];
    }
    else if ([dic objectForKey:@"NSLocalizedDescriptionKey"]){
        msg = [dic objectForKey:@"NSLocalizedDescriptionKey"];
    }
    else if ([dic objectForKey:@"NSErrorUserInfoKey"]){
        msg = [dic objectForKey:@"NSErrorUserInfoKey"];
    }
    
    
    if ([dic isKindOfClass:[NSDictionary class]]) {
        NSLog(@"请求地址:%@", dic[@"NSErrorFailingURLKey"]);
        NSLog(@"错误原因:%@", dic[@"NSLocalizedDescription"]);
        msg = [dic objectForKey:@"NSLocalizedDescription"] == nil ? msg : [dic objectForKey:@"NSLocalizedDescription"];
        
        if ([dic[@"com.alamofire.serialization.response.error.response"] isKindOfClass:[NSHTTPURLResponse class]]) {
            NSHTTPURLResponse *http = (NSHTTPURLResponse *)dic[@"com.alamofire.serialization.response.error.response"];
            NSInteger code = http.statusCode;
            NSLog(@"错误状态:%zd", code);
            if (code == 401 || code == 400) {
                msg = kAccountOrPasswordErrorMessage;
            } else if (code == 403) {
                msg = @"403-授权失败，禁止访问";
            }
        }
    }
    
    [SVProgressHUD showErrorWithStatus:msg];
}


@end
