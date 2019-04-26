//
//  NetResponseManager.m
//  XM_12580
//
//  Created by mac on 12-7-10.
//  Copyright (c) 2012年 Neptune. All rights reserved.
//

#import "NetResponseManager.h"
#import "NetRequestManager.h"
#import "RongCloudManager.h"
#import "GTMBase64.h"
#import "NSData+AES.h"

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
        ResultCode code = [[dict objectForKey:@"code"] integerValue];
        if([dict objectForKey:@"code"] == nil)
            code = -1;
        if(httpManager.act == ActRequestToken || httpManager.act == ActRequestTokenBySMS){
            NSString *refreshToken = [dict objectForKey:@"refresh_token"];
            if(refreshToken.length > 10)
                code = ResultCodeSuccess;
            [self getTokenBack:dict];
        }else if(httpManager.act == ActRequestIMToken){
            if(code == ResultCodeSuccess){
                APP_MODEL.rongYunToken = [dict objectForKey:@"data"];
                [APP_MODEL saveAppModel];
                NSLog(@"融云token = %@",APP_MODEL.rongYunToken);
            }
        }else if(httpManager.act == ActRequestUserInfo){
            if(code == ResultCodeSuccess){
                [self updateUserInfo:dict[@"data"]];
            }
        }else if(httpManager.act == ActRequestCommonInfo){
            if(code == ResultCodeSuccess){
                [self getCommonInfoBack:dict[@"data"]];
            }
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
        [FUNCTION_MANAGER handleFailResponse:responseDic];
        return;
    }
    APP_MODEL.user.userId = responseDic[@"userId"];
    APP_MODEL.user.token = responseDic[@"access_token"];
    APP_MODEL.user.fullToken = [NSString stringWithFormat:@"Bearer %@",APP_MODEL.user.token];
    [NET_REQUEST_MANAGER requestUserInfoWithSuccess:^(id object) {
        [APP_MODEL reSetRootAnimation:YES];
    } fail:^(id object) {
        [FUNCTION_MANAGER handleFailResponse:object];
    }];
    [NET_REQUEST_MANAGER requestAppConfigWithSuccess:nil fail:nil];
}

-(void)updateUserInfo:(NSDictionary *)dict{
    UserModel *user = [UserModel mj_objectWithKeyValues:dict];
    user.token = APP_MODEL.user.token;
    user.fullToken = APP_MODEL.user.fullToken;
    user.groupowenFlag = [dict[@"groupowenFlag"] boolValue];
    APP_MODEL.user = user;
    APP_MODEL.user.isLogined = YES;
    [APP_MODEL saveAppModel];
    [NET_REQUEST_MANAGER requestIMTokenWithSuccess:nil fail:nil];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:user.userId forKey:@"userId"];
    [ud setObject:user.mobile forKey:@"mobile"];
    [ud synchronize];
}

-(void)getCommonInfoBack:(NSDictionary *)dict{
    if([dict isKindOfClass:[NSString class]]){
        NSString *s = (NSString *)dict;
        NSData *data = [GTMBase64 decodeString:s];
        NSString *key = @"1234567887654321";
        data = [data AES128DecryptWithKey:key gIv:key];
        NSString *json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        dict = [json mj_JSONObject];
    }
    APP_MODEL.commonInfo = dict;
    NSString *authKey = APP_MODEL.commonInfo[@"app_client_id"];
    if(authKey)
        APP_MODEL.authKey = authKey;
}

-(void)getSystemNoticeBack:(NSDictionary *)dict{
    APP_MODEL.noticeArray = dict[@"records"];
    [APP_MODEL saveAppModel];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateScrollBarView" object:nil];
}
@end
