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
static NSString * const kServerUrl  = @"http://api.520qun.com/api/";
// 测试服务器地址
static NSString * const kServerUrlTest1  = @"http://10.10.15.176:8099/";
static NSString * const kServerUrlTest2  = @"http://10.10.15.178:8099/";
static NSString * const kServerUrlTest3  = @"http://43.225.159.247:8099/";


//
///**
// ****   融云
// ***/
static NSString * const kRongYunKey = @"4z3hlwrv4gayt";
static NSString * const kRongfYunKeyTest1 = @"qd46yzrfqi8wf";   // 测试
static NSString * const kRongfYunKeyTest2 = @"cpj2xarlct7jn";   // 测试
static NSString * const kRongfYunKeyTest3 = @"0vnjpoad036nz";   // 测试

/**
 ****   微信 2019.02.15
 ***/
static NSString * const WXKey = @"wx6855b12dbf3d7a06";//@"wxb9a25b32bcf8449c";
static NSString * const WXSecret = @"3da5d9957cbc82685512002aac39e3f0";//@"2853774d619b53cef728d235874058ce";


// 在线客服系统
//static NSString * const ServiceLink  =  @"http://api.pop800.com/chat/458076";//366223

// static NSString* const H_KEY  =  @"652e6f3c7dcf22227cc884ce9c5730b5";//临时请求，key固定 玩家接口i

// 保存下载页 URL
static NSString * const kDownloadPageURL = @"https://www.520qun.com/appdown/IOS/index.html?code=";
static NSString * const kJSPatchURL = @"https://www.520qun.com";

#endif /* ThirdMacros_h */
