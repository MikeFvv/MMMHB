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

            NSDictionary *serializedData = [NSJSONSerialization JSONObjectWithData: dic[@"com.alamofire.serialization.response.error.data"] options:kNilOptions error:nil];
            
            if([serializedData isKindOfClass:[NSDictionary class]]){
                if (code == 403 && [[serializedData objectForKey:@"code"] integerValue] == 1) {
                    msg = [serializedData objectForKey:@"msg"];
                } else if (code == 500) {
                    msg = @"内部服务器错误，请稍后重试-500";
                }
            }
            
        }
    }
    
    [SVProgressHUD showErrorWithStatus:msg];
}


@end
