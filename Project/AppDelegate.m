//
//  AppDelegate.m
//  Project
//
//  Created by zhyt on 2018/7/10.
//  Copyright © 2018年 CDJay. All rights reserved.
//

#import "AppDelegate.h"
#import "WXManage.h"
#import "AFNetworkReachabilityManager.h"
#import "NSData+AES.h"
#import "GTMBase64.h"
#import "JSPatchManager.h"
#import <Bugtags/Bugtags.h>
#import "FYIMManager.h"
#import <objc/runtime.h>
#import "MTA.h"
#import "MessageSingle.h"
#import "PushMessageModel.h"
#import "WHC_ModelSqlite.h"


@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSLog(@"服务器地址 %@",kServerUrl);
    NSLog(@"融云key %@",kRongYunKey);
    NSLog(@"微信key %@ 微信secret %@",kWXKey,kWXSecret);
    [self check];
    [self getAppConfig];
#if TARGET_IPHONE_SIMULATOR
    [JPEngine startEngine];
    NSString *sourcePath = [[NSBundle mainBundle] pathForResource:@"main" ofType:@"js"];
    NSString *script = [NSString stringWithContentsOfFile:sourcePath encoding:NSUTF8StringEncoding error:nil];
    [JPEngine evaluateScript:script];
#elif TARGET_OS_IPHONE
    // 热更新加载
    [JSPatchManager asyncUpdate:YES];
    if(kMTAKey.length > 1)
        [MTA startWithAppkey:kMTAKey];
#endif
    [self gethistoryMessageNum];
    [FYIMManager shareInstance];
    
#if DEBUG
#else
    [NSThread sleepForTimeInterval:2.0];
#endif
    
    [self applicationRoot];
    
    return YES;
}


- (void)getAppConfig {
    [[NetRequestManager sharedInstance] requestAppConfigWithSuccess:^(id object) {
        
    } fail:^(id object) {
        
    }];
}

- (void)applicationRoot {
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = CDCOLOR(245, 245, 245);
    self.window.rootViewController = [[AppModel shareInstance] rootVc];
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    [self AFNReachability];
    [[AppModel shareInstance] initSetUp];
    
    if([AppModel shareInstance].userInfo.isLogined)
        [[NetRequestManager sharedInstance] requestSystemNoticeWithSuccess:nil fail:nil];
}

/**
 * 推送处理3
 */
- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *token = [[[[deviceToken description] stringByReplacingOccurrencesOfString:@"<" withString:@""]
                        stringByReplacingOccurrencesOfString:@">"
                        withString:@""] stringByReplacingOccurrencesOfString:@" "
                       withString:@""];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
#if TARGET_IPHONE_SIMULATOR
    // 模拟器不能使用远程推送
#else
    // 请检查App的APNs的权限设置，更多内容可以参考文档
    // http://www.rongcloud.cn/docs/ios_push.html。
    NSLog(@"获取DeviceToken失败");
    NSLog(@"ERROR：%@", error);
#endif
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    
    //    /**
    //     * 统计推送打开率2
    //     */
    //    [[RCIMClient sharedRCIMClient] recordRemoteNotificationEvent:userInfo];
    //    /**
    //     * 获取融云推送服务扩展字段2
    //     */
    //    NSDictionary *pushServiceData = [[RCIMClient sharedRCIMClient] getPushExtraFromRemoteNotification:userInfo];
    //    if (pushServiceData) {
    //        NSLog(@"该远程推送包含来自融云的推送服务");
    //        for (id key in [pushServiceData allKeys]) {
    //            NSLog(@"key = %@, value = %@", key, pushServiceData[key]);
    //        }
    //    } else {
    //        NSLog(@"该远程推送不包含来自融云的推送服务");
    //    }
    
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url{
    return [WXManage handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    return [WXManage handleOpenURL:url];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {

    NSDictionary *dict = [NSDictionary dictionaryWithDictionary:[MessageSingle shareInstance].myJoinGroupMessage];
    NSArray *arr = [dict allKeys];
    for (NSInteger i = 0; i < arr.count; i++) {
        PushMessageModel *model = (PushMessageModel *)[dict objectForKey:arr[i]];
        NSString *query = [NSString stringWithFormat:@"sessionId='%@' AND userId='%@'",model.sessionId,[AppModel shareInstance].userInfo.userId];
        PushMessageModel *sqlModel = [[WHC_ModelSqlite query:[PushMessageModel class] where:query] firstObject];
        
        if (sqlModel) {
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [WHC_ModelSqlite update:model where:query];
            });
        } else {
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [WHC_ModelSqlite insert:model];
            });
        }
        //        NSLog(@"%@ : %@", arr[i], [dict objectForKey:arr[i]]); // dic[arr[i]]
    }
}

- (void)gethistoryMessageNum {
    
    NSInteger oldMessageNum = 0;
    if ([AppModel shareInstance].unReadCount > 0) {
        oldMessageNum = [AppModel shareInstance].unReadCount;
    }
    [AppModel shareInstance].unReadCount = 0;

    NSString *queryWhere = [NSString stringWithFormat:@"userId='%@'",[AppModel shareInstance].userInfo.userId];
    NSArray *userGroupArray = [WHC_ModelSqlite query:[PushMessageModel class] where:queryWhere];

    for (NSInteger index = 0; index < userGroupArray.count; index++) {
        PushMessageModel *pmModel = (PushMessageModel *)userGroupArray[index];
        
        if (pmModel != nil && pmModel.sessionId != nil && ![pmModel.sessionId isEqualToString:@""]) {
            [AppModel shareInstance].unReadCount += pmModel.number;
            
            NSString *queryId = [NSString stringWithFormat:@"%@-%@",pmModel.sessionId,[AppModel shareInstance].userInfo.userId];
            [MessageSingle shareInstance].myJoinGroupMessage[queryId] = pmModel;
        }
    }
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    [self requestJSPatchInfo];
    [[FunctionManager sharedInstance] checkVersion:NO];

}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


- (void)requestJSPatchInfo {
    NSString *requestJStime = [[NSUserDefaults standardUserDefaults] valueForKey:@"requestJStime"];
    NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
    CGFloat timeSpace = currentTime - [requestJStime floatValue];
    if (requestJStime.length==0 | timeSpace > 3600) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%f",currentTime] forKey:@"requestJStime"];
        [JSPatchManager asyncUpdate:YES]
    }
}

#pragma mark AFNReachability
-(void)AFNReachability{
    //1.创建网络监听管理者
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    
    //2.监听网络状态的改变
    /*
     AFNetworkReachabilityStatusUnknown          = 未知
     AFNetworkReachabilityStatusNotReachable     = 没有网络
     AFNetworkReachabilityStatusReachableViaWWAN = 3G
     AFNetworkReachabilityStatusReachableViaWiFi = WIFI
     */
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
                NSLog(@"未知");
                break;
            case AFNetworkReachabilityStatusNotReachable:
                SVP_ERROR_STATUS(@"当前网络错误，请检查网络");
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                NSLog(@"3G");
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                NSLog(@"WIFI");
                break;
                
            default:
                break;
        }
    }];
    
    //3.开始监听
    [manager startMonitoring];
}

//用来防止建新的app时忘了配置某些参数
-(void)check{
#if DEBUG
    NSDictionary *infoPlist = [[NSBundle mainBundle] infoDictionary];
    NSString *wKey = [[[infoPlist valueForKeyPath:@"CFBundleURLTypes.CFBundleURLSchemes"] lastObject] lastObject];
    NSCAssert([wKey isEqualToString:kWXKey],@"info.plist里微信key配置不一致");
#endif
}
@end
