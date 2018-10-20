//
//  Config_Hongbao.h
//  Project
//
//  Created by mac on 2018/8/28.
//  Copyright © 2018年 CDJay. All rights reserved.
//

#ifndef Config_Hongbao_h
#define Config_Hongbao_h


/**
 ****   融云环境 0测试1生产
 ***/

typedef enum{
    RongYunModel_test = 0,//测试
    RongYunModel_public = 1,
}RongYunModel;
static int rongYunMode = RongYunModel_test;


/**
 ****   融云
 ***/
//static NSString* const RyTestKey = @"8luwapkv8j60l"; 8w7jv4qb82ury z3v5yqkbz1wp0
static NSString* const RyTestKey = @"8w7jv4qb82ury";
static NSString* const RyTestKeySecret = @"WHiY5t6MjT5ms";

//asong
//static NSString* const RyTestKey = @"qd46yzrfqi8wf";
//static NSString* const RyTestKeySecret = @"bHLPf2s0iDH0P";

static NSString* const RyKey = @"8brlm7uf8zos3";
static NSString* const RySecret = @"JzYmITZJaJP2";

/**
 ****   微信
 ***/
//static NSString* const RyTestKey = @"8luwapkv8j60l";
static NSString* const WXKey = @"wxb9a25b32bcf8449c";
static NSString* const WXSecret = @"2853774d619b53cef728d235874058ce";
static NSString* const UrlScheme  = @"wxb9a25b32bcf8449c";
static NSString* const WXShareTitle  = @"下载抢红包,每天签到领红包最高88.88，诚招代理0成本0门槛代理每天拉群抢最高8888元";
static NSString* const WXShareLink  = @"https://www.pgyer.com/wxs";
#define WXShareDescription [NSString stringWithFormat:@"我的推荐码是%@",APP_MODEL.user.userInvitecode]
//static NSString* const WXShareDescription  = @"下载抢红包,每天签到领红包最高88.88，诚招代理0成本0门槛代理每天拉群抢最高8888元";


/**
 ****   接口地址 var BaseImg_url = 'http://cp2.xmnet.xyz/api/'; http://lc.xmnet.xyz/api/
 ***/
static NSString* const url_preix  =  @"http://103.107.236.103:9999/";
//a song
//static NSString* const url_preix  =  @"http://172.20.208.87:9999/";

static NSString* const ServiceLink  =  @"http://api.pop800.com/chat/366223";

static NSString* const H_KEY  =  @"652e6f3c7dcf22227cc884ce9c5730b5";//临时请求，key固定 玩家接口i

#endif /* Config_Hongbao_h */
