//
//  NetResponseManager.h
//  XM_12580
//
//  Created by mac on 12-7-10.
//  Copyright (c) 2012年 Neptune. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPSessionManager2.h"
#define NET_RESPONSE_MANAGER [NetResponseManager sharedInstance]

//通知字符串定义

@interface NetResponseManager : NSObject<UIAlertViewDelegate>
{
    NSString *_updateURL;//更新地址
}

+ (NetResponseManager *)sharedInstance;
+ (void)destroyInstance;

-(void)requestWithHTTPSessionManager:(AFHTTPSessionManager2 *)httpSessionManager block:(id)response;
-(void)requestWithHTTPSessionManager:(AFHTTPSessionManager2 *)httpSessionManager failed:(NSError *)error;
@end
