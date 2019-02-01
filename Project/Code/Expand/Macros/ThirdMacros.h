//
//  ThirdMacros.h
//  Project
//
//  Created by Mike on 2018/12/30.
//  Copyright © 2018 CDJay. All rights reserved.
//

#ifndef ThirdMacros_h
#define ThirdMacros_h

///**
// ****   融云环境  0测试  1生产
// ***/
//static int isLine = 0;
//
//// 生产服务器地址
static NSString * const serverUrl  = @"http://api.520qun.com/api/";
// 测试服务器地址
static NSString * const serverUrlTest  = @"http://10.10.15.178:8099/";
static NSString * const serverUrlTest2  = @"http://10.10.15.176:8099/";


//
///**
// ****   融云
// ***/
static NSString * const rongfYunKeyTest = @"qd46yzrfqi8wf";   // 测试
static NSString * const rongYunKey = @"vnroth0kv85xo";     // 生产

/**
 ****   微信
 ***/
static NSString * const WXKey = @"wxb9a25b32bcf8449c";
static NSString * const WXSecret = @"2853774d619b53cef728d235874058ce";

// 自定义红包 特殊字符判断  踩雷
static NSString * const RedPacketString = @"~!@#$%^&*()";
// 牛牛
static NSString * const CowCowMessageString = @"~!@#$niuniuPrize%^&*()";


// 在线客服系统
static NSString * const ServiceLink  =  @"http://api.pop800.com/chat/458076";//366223

// 热更新请求地址

static NSString * const JSPatchRequestUrl  =  @"https://www.shiji68.com/iOSPatch/patchVersion.js";

// static NSString* const H_KEY  =  @"652e6f3c7dcf22227cc884ce9c5730b5";//临时请求，key固定 玩家接口i

#endif /* ThirdMacros_h */
