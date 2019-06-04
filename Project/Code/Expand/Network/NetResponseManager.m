//
//  NetResponseManager.m
//  XM_12580
//
//  Created by mac on 12-7-10.
//  Copyright (c) 2012年 Neptune. All rights reserved.
//

#import "NetResponseManager.h"
#import "NetRequestManager.h"
#import "GTMBase64.h"
#import "NSData+AES.h"
#import "SAMKeychain.h"

@implementation NetResponseManager

+(NetResponseManager *)sharedInstance{
    static NetResponseManager *instance = nil;
    static dispatch_once_t onceNetRes;
    dispatch_once(&onceNetRes, ^{
        if(instance == nil)
            instance = [[NetResponseManager alloc] init];
    });
    return instance;
}
                  
-(instancetype)init{
    if(self == [super init]){
    }
    return self;
}

-(void)responseWithHttpManager:(AFHTTPSessionManager2 *)httpManager responseData:(id)data{
    if([data isKindOfClass:[NSError class]]){
        NSError *error = (NSError *)data;
        if(httpManager.failBlock)
            httpManager.failBlock(error);
    }else if([data isKindOfClass:[NSDictionary class]]){
        NSDictionary *dict = (NSDictionary *)data;
        //dict = [[FunctionManager sharedInstance] removeNull:dict];
        ResultCode code = [[dict objectForKey:@"code"] integerValue];
        if([dict objectForKey:@"code"] == nil) {
            code = -1;
        }
        
        if(httpManager.act == ActRequestToken || httpManager.act == ActRequestTokenBySMS){
            NSString *refreshToken = [dict objectForKey:@"refresh_token"];
            if(refreshToken.length > 10) {
                code = ResultCodeSuccess;
            }
            [self getTokenBack:dict];
            [[NSNotificationCenter defaultCenter] postNotificationName:kOnConnectSocketNotification object: nil];
        }else if(httpManager.act == ActRequestIMToken){
            if(code == ResultCodeSuccess){
                [[AppModel shareInstance] saveAppModel];
            }
        }else if(httpManager.act == ActRequestUserInfo){
            if(code == ResultCodeSuccess){
                [self updateUserInfo:dict[@"data"]];
            }
        }else if(httpManager.act == ActRequestCommonInfo){
            if(code == ResultCodeSuccess){
                [self getCommonInfoBack:dict[@"data"]];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:kOnConnectSocketNotification object: nil];
        }else if(httpManager.act == ActRequestSystemNotice){
            if(code == ResultCodeSuccess){
                [self getSystemNoticeBack:dict[@"data"]];
            }
        }
        if(code == ResultCodeSuccess){
            if(httpManager.successBlock)
                httpManager.successBlock(data);
        }else{
            if(httpManager.failBlock)
                httpManager.failBlock(data);
        }
    }
}

-(void)getTokenBack:(NSDictionary *)responseDic{
    if(responseDic[@"error"] != nil){
        SVP_ERROR_STATUS(responseDic[@"error_description"]);
        return;
    }
    if(responseDic[@"code"] && [responseDic[@"code"] integerValue] != ResultCodeSuccess){
        [[FunctionManager sharedInstance] handleFailResponse:responseDic];
        return;
    }
    [AppModel shareInstance].userInfo.userId = responseDic[@"userId"];
    [AppModel shareInstance].userInfo.token = responseDic[@"access_token"];
    [AppModel shareInstance].userInfo.fullToken = [NSString stringWithFormat:@"Bearer %@",[AppModel shareInstance].userInfo.token];
}

-(void)updateUserInfo:(NSDictionary *)dict{
    UserInfo *user = [UserInfo mj_objectWithKeyValues:dict];
    if([user.userId isKindOfClass:[NSNumber class]]){
        user.userId = [(NSNumber *)user.userId stringValue];
    }
    user.token = [AppModel shareInstance].userInfo.token;
    user.fullToken = [AppModel shareInstance].userInfo.fullToken;
    user.groupowenFlag = [dict[@"groupowenFlag"] boolValue];
    [AppModel shareInstance].userInfo = user;
    [AppModel shareInstance].userInfo.isLogined = YES;
    [[AppModel shareInstance] saveAppModel];
    [NET_REQUEST_MANAGER requestIMTokenWithSuccess:nil fail:nil];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:user.userId forKey:@"userId"];
    [ud setObject:user.mobile forKey:@"mobile"];
    [ud synchronize];
    
    [SAMKeychain setPassword:@"1" forService:@"com.fy.ser" account:user.mobile];
}


/**
 获取配置

 @param dict dict
 */
-(void)getCommonInfoBack:(NSDictionary *)dict{
    if([dict isKindOfClass:[NSString class]]){
        NSString *s = (NSString *)dict;
        NSData *data = [GTMBase64 decodeString:s];
        NSString *key = @"1234567887654321";
        data = [data AES128DecryptWithKey:key gIv:key];
        NSString *json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        dict = [json mj_JSONObject];
    }
    [AppModel shareInstance].commonInfo = dict;
    NSString *authKey = [AppModel shareInstance].commonInfo[@"app_client_id"];
    
    if(authKey){
        [AppModel shareInstance].appClientIdInCommonInfo = authKey;
        [AppModel shareInstance].authKey = [NSString stringWithFormat:@"Basic %@",authKey];
    }
}

-(void)getSystemNoticeBack:(NSDictionary *)dict{
    [AppModel shareInstance].noticeArray = dict[@"records"];
    [[AppModel shareInstance] saveAppModel];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateScrollBarView" object:nil];
}
@end
