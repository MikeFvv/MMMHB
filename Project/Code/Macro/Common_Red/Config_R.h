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
static int isLine = 0;


/**
 ****   融云  e0x9wycfe4imq   x18ywvqfxbsoc
 ***/
//static NSString* const RyTestKey = @"8luwapkv8j60l";
static NSString* const RyTestKey = @"z3v5yqkbz1wp0";
static NSString* const RyTestKeySecret = @"6OK3ehwG6a9";
static NSString* const RyKey = @"8brlm7uf8zos3";
static NSString* const RySecret = @"JzYmITZJaJP2";

/**
 ****   微信
 ***/
//static NSString* const RyTestKey = @"8luwapkv8j60l";
static NSString* const WXKey = @"wxc76350e56fafd5dd";
static NSString* const WXSecret = @"443f377f18b7416386ee871cb8d0f1e0";
static NSString* const UrlScheme  = @"wxc76350e56fafd5dd";
static NSString* const WXShareTitle  = @"下载抢红包,每天签到领红包最高88.88，诚招代理0成本0门槛代理每天拉群抢最高8888元";
static NSString* const WXShareLink  = @"https://www.pgyer.com/wxs";
#define WXShareDescription [NSString stringWithFormat:@"我的推荐码是%@",[AppModel shareInstance].User.referralCode]
//static NSString* const WXShareDescription  = @"下载抢红包,每天签到领红包最高88.88，诚招代理0成本0门槛代理每天拉群抢最高8888元";


/**
 ****   接口地址 var BaseImg_url = 'http://cp2.xmnet.xyz/api/'; http://lc.xmnet.xyz/api/
 ***/
static NSString* const Line_pre  =  @"http://cp2.xmnet.xyz/api/";
static NSString* const Img_pre  =  @"http://lc.xmnet.xyz";
static NSString* const ServiceLink  =  @"http://api.pop800.com/chat/366223";

static NSString* const H_KEY  =  @"652e6f3c7dcf22227cc884ce9c5730b5";//临时请求，key固定 玩家接口i

#endif /* Config_Hongbao_h */
