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
static NSString * const kServerUrl  = @"http://api.5858hbw.com/api/";
// 测试服务器地址
static NSString * const kServerUrlTest1  = @"http://10.10.15.176:8099/";
static NSString * const kServerUrlTest2  = @"http://10.10.15.178:8099/";


//
///**
// ****   融云
// ***/
static NSString * const kRongYunKey = @"n19jmcy5na0i9";
static NSString * const kRongfYunKeyTest1 = @"qd46yzrfqi8wf";   // 测试
static NSString * const kRongfYunKeyTest2 = @"cpj2xarlct7jn";   // 测试

/**
 **** 
 ***/
static NSString * const WXKey = @"wx7dee96d9b15804bd";
static NSString * const WXSecret = @"8e21567a668ebe2abfe68889ea41e7c5";//@"2853774d619b53cef728d235874058ce";


// 在线客服系统
//static NSString * const ServiceLink  =  @"https://e-141635.chatnow.meiqia.com/dist/standalone.html";

// static NSString* const H_KEY  =  @"652e6f3c7dcf22227cc884ce9c5730b5";//临时请求，key固定 玩家接口i


// 保存下载页 URL
static NSString * const kDownloadPageURL = @"https://www.5858hb.com/appdown/IOS/index.html?code=";

static NSString * const kJSPatchURL = @"https://www.5858hb.com";


#endif /* ThirdMacros_h */
