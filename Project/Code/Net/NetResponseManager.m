//
//  NetResponseManager.m
//  XM_12580
//
//  Created by mac on 12-7-10.
//  Copyright (c) 2012年 Neptune. All rights reserved.
//

#import "NetResponseManager.h"
#import "NetRequestManager.h"

static NetResponseManager *instance = nil;

@implementation NetResponseManager

+(NetResponseManager *)sharedInstance{
    static dispatch_once_t instResp;
    dispatch_once(&instResp, ^{
        if(instance == nil)
            instance = [[NetResponseManager alloc] init];
    });
    return instance;
}

+(void)destroyInstance{
    if(instance){
        instance = nil;
    }
}

-(instancetype)init{
    if(self == [super init]){
    }
    return self;
}

-(void)requestWithHTTPSessionManager:(AFHTTPSessionManager2 *)httpSessionManager block:(id)response{
    NSMutableDictionary *newDic = [[NSMutableDictionary alloc] initWithDictionary:response];
    if(httpSessionManager.requestParameters)
        [newDic setObject:httpSessionManager.requestParameters forKey:@"requestParameters"];
    if(httpSessionManager.action == ActionGetUserInfo)
        [self handleUserInfo:newDic];
    else if(httpSessionManager.action == ActionGetToken)
        [self handleGetToken:newDic];
    else if(httpSessionManager.action == ActionGetIMToken)
        [self handleRongYunToken:newDic];
    ResultCode code = (ResultCode)[[newDic objectForKey:@"code"] integerValue];
    if(([newDic objectForKey:@"code"] && code == ResultCodeSuccess) || [newDic objectForKey:@"access_token"]){
        if(httpSessionManager.successBlock){
            httpSessionManager.successBlock(newDic);
        }
    }else{
        if(httpSessionManager.failBlock){
            httpSessionManager.failBlock(newDic);
        }
    }
}
-(void)requestWithHTTPSessionManager:(AFHTTPSessionManager2 *)httpSessionManager failed:(NSError *)error;{
    SV_ERROR_STATUS([error description]);
}
#pragma mark 这边可以做数据处理

-(void)handleGetToken:(NSDictionary *)data{
    if(data){
        ResultCode code = (ResultCode)[[data objectForKey:@"code"] integerValue];
        if(([data objectForKey:@"code"] && code == ResultCodeSuccess) || [data objectForKey:@"access_token"]){
            NSString *token = data[@"access_token"];
            APP_MODEL.user.token = token;
            APP_MODEL.user.tokenType = @"Bearer";//data[@"token_type"];
            APP_MODEL.user.userId = [NSString stringWithFormat:@"%ld",[data[@"userId"] integerValue]];
            APP_MODEL.user.fullToken = [NSString stringWithFormat:@"%@ %@",APP_MODEL.user.tokenType,APP_MODEL.user.token];
            [APP_MODEL saveToDisk];
        }
    }
}

-(void)handleUserInfo:(NSDictionary *)data{
    if(data){
        ResultCode code = (ResultCode)[[data objectForKey:@"code"] integerValue];
        if(([data objectForKey:@"code"] && code == ResultCodeSuccess) || [data objectForKey:@"access_token"]){
            UserModel *user = [UserModel mj_objectWithKeyValues:data[@"data"]];
            user.tokenType = APP_MODEL.user.tokenType;
            user.token = APP_MODEL.user.token;
            user.fullToken = APP_MODEL.user.fullToken;
            user.userId = APP_MODEL.user.userId;
            user.isLogined = YES;
            APP_MODEL.rongYunToken = nil;
            APP_MODEL.user = user;
            [APP_MODEL saveToDisk];
        }
    }
}

-(void)handleRongYunToken:(NSDictionary *)data{
    if(data){
        ResultCode code = (ResultCode)[[data objectForKey:@"code"] integerValue];
        if(([data objectForKey:@"code"] && code == ResultCodeSuccess) || [data objectForKey:@"access_token"]){
            APP_MODEL.rongYunToken = data[@"data"];
            [APP_MODEL saveToDisk];
        }
    }
}
@end
