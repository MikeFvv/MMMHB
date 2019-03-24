//
//  RonYun.m
//  Project
//
//  Created by mini on 2018/7/31.
//  Copyright © 2018年 CDJay. All rights reserved.
//

#import "RongCloudManager.h"
//#import <RongIMKit/RongIMKit.h>
#import <RongIMLib/RongIMLib.h>
#import "SqliteManage.h"
#import "EnvelopeMessage.h"
#import "ChatViewController.h"
#import "BANetManager_OC.h"

@interface RongCloudManager()
@property(nonatomic,assign)NSInteger retryCount;
@end

@implementation RongCloudManager


+ (RongCloudManager *)shareInstance{
    static RongCloudManager *instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[[self class] alloc] init];
    });
    return instance;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        //配置融云
        self.retryCount = 0;
        [RCIM sharedRCIM].enablePersistentUserInfoCache = YES;
        [RCIM sharedRCIM].userInfoDataSource = self;//[RonYun shareInstance];
        [RCIM sharedRCIM].groupInfoDataSource = self;//[RonYun shareInstance];
        [RCIM sharedRCIM].receiveMessageDelegate = self;//[RonYun shareInstance];
        [RCIM sharedRCIM].groupMemberDataSource = self;
        [RCIM sharedRCIM].showUnkownMessage = YES;
        [RCIM sharedRCIM].showUnkownMessageNotificaiton = YES;
        [RCIM sharedRCIM].enableMessageMentioned = YES;
        [RCIMClient sharedRCIMClient].logLevel = RC_Log_Level_Info;
        [[RCIM sharedRCIM] registerMessageType:NSClassFromString(@"EnvelopeMessage")];
        [[RCIM sharedRCIM] registerMessageType:NSClassFromString(@"EnvelopeTipMessage")];
        [RCIM sharedRCIM].enableMessageAttachUserInfo = YES;
        [[RCIM sharedRCIM]setConnectionStatusDelegate:self];
    }
    return self;
}

#pragma mark RCIMConnectionStatusDelegate
- (void)onRCIMConnectionStatusChanged:(RCConnectionStatus)status{
    switch (status) {
        case ConnectionStatus_UNKNOWN:{
            
        }
            break;
        case ConnectionStatus_Connected:{
            
        }
            break;
        case ConnectionStatus_NETWORK_UNAVAILABLE:{
            
        }
            break;
        case ConnectionStatus_AIRPLANE_MODE:{
            
        }
            break;
        case ConnectionStatus_Cellular_2G:{
            
        }
            break;
        case ConnectionStatus_Cellular_3G_4G:{
            
        }
            break;
        case ConnectionStatus_WIFI:{
            
        }
            break;
        case ConnectionStatus_KICKED_OFFLINE_BY_OTHER_CLIENT:{
            SVP_ERROR_STATUS(kOtherDevicesLoginMessage);
            [APP_MODEL logout];
        }
            break;
        case ConnectionStatus_Connecting:{
            
        }
            break;
        case ConnectionStatus_Unconnected:{
            
        }
            break;
        case ConnectionStatus_SignUp:{
            
        }
            break;
        case ConnectionStatus_TOKEN_INCORRECT:{
            
        }
            break;
        case ConnectionStatus_DISCONN_EXCEPTION:{
            //            NSLog(@"111");
        }
            break;
        default:
            break;
    }
    
}

#pragma mark - RCIMReceiveMessageDelegate 未读消息来源
- (void)onRCIMReceiveMessage:(RCMessage *)message left:(int)left{
    // 广播消息
    if ([message.objectName isEqualToString:@"RC:CmdMsg"]) {
        [NET_REQUEST_MANAGER requestSystemNoticeWithSuccess:nil fail:nil];
        return;
    }
    
    if (message.conversationType == ConversationType_PRIVATE) {
        RCTextMessage *text = (RCTextMessage *)message.content;
        if ([message.senderUserId isEqualToString:@"1"]&&[text.content isEqualToString:@"push웃유App"]) {
            //            NSLog(@"%@",text.extra.mj_JSONObject);
            NSString *type = text.extra.mj_JSONObject[@"type"];
            if ([type isEqualToString:@"login"]) {
                if (!APP_MODEL.user.isLogined) {
                    return;
                }
                if (![APP_MODEL.rongYunToken isEqualToString:text.extra.mj_JSONObject[@"token"]]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [APP_MODEL logout];
                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"账号已在别处登录" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确认", nil];
                        [alert show];
                    });
                }
            }
            if ([type isEqualToString:@"quitGroup"]) {
                
            }
            if ([type isEqualToString:@"joinGroup"]) {
                
            }
        }
        return;
    }
    
    [self messageTypeJudgeMessage:message];
}


- (void)messageTypeJudgeMessage:(RCMessage *)message {
    
    if ([message.objectName isEqualToString:@"RC:TxtMsg"] || [message.objectName isEqualToString:@"RC:ImgMsg"] || [message.objectName isEqualToString:@"RC:VcMsg"]) {
        int number = 0;
        NSString *tid = nil;
        ChatViewController *vc = [ChatViewController currentChat];
        if (vc) {
            tid = vc.targetId;
        }
        NSString *gId = message.targetId;
        number = ([tid isEqualToString:gId])?0:1;
        NSString *text = nil;
        //        NSLog(@"============ %@", message.objectName);
        if ([message.content isKindOfClass:[RCTextMessage class]]) {
            RCTextMessage *content = (RCTextMessage *)message.content;
            text = content.content;
        } else if ([message.content isKindOfClass:[RCImageMessage class]]) {
            text = @"【图片】";
        } else if ([message.content isKindOfClass:[RCVoiceMessage class]]) {
            text = @"【语音】";
        } else if ([message.content isKindOfClass:[EnvelopeMessage class]]) {
            text = @"【红包】";
        } else {
            text = @"暂无未读消息";
        }
        
        [SqliteManage updateGroup:gId number:number lastMessage:text];
    } else {
        NSLog(@"=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*= 未知消息类型-> %@ =*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=", message.objectName);
    }
}

#pragma mark - RCIMUserInfoDataSource
//- (void)getUserInfoWithUserId:(NSString *)userId completion:(void (^)(RCUserInfo *))completion {
//    NSLog(@"getUserInfoWithUserId ----- %@", userId);
//    RCUserInfo *userInfo = [[RCIM sharedRCIM] getUserInfoCache:userId];
//    RCUserInfo *user = [RCUserInfo new];
//    if (userId == nil || [userId length] == 0) {
//        user.userId = userId;
//        user.portraitUri = @"";
//        user.name = @"";
//        completion(user);
//        return;
//    }
//    //开发者调自己的服务器接口根据userID异步请求数据
//    if (![userId isEqualToString:[RCIM sharedRCIM].currentUserInfo.userId]) {
//        [NET_REQUEST_MANAGER requestUserInfoWithUserId:userId success:^(id object) {
//            user.portraitUri = nil;
//            user.name = nil;
//            [[RCIM sharedRCIM] refreshUserInfoCache:user withUserId:user.userId];
//            completion(user);
//        } fail:^(id object) {
//
//        }];
//    } else {
//            [[RCIM sharedRCIM] refreshUserInfoCache:user withUserId:user.userId];
//            completion(user);
//    }
//    return;
//}

#pragma mark RCIMGroupInfoDataSource
- (void)getGroupInfoWithGroupId:(NSString *)groupId completion:(void (^)(RCGroup *groupInfo))completion{
    
}

#pragma mark - RCIMUserInfoDataSource
//- (void)getUserInfoWithUserId:(NSString *)userId completion:(void (^)(RCUserInfo *))completion {
//    NSLog(@"getUserInfoWithUserId ----- %@", userId);
//    RCUserInfo *user = [RCUserInfo new];
//    if (userId == nil || [userId length] == 0) {
//        user.userId = userId;
//        user.portraitUri = @"";
//        user.name = @"";
//        completion(user);
//        return;
//    }
//    //开发者调自己的服务器接口根据userID异步请求数据
//    if (![userId isEqualToString:[RCIM sharedRCIM].currentUserInfo.userId]) {
//        [UserModel getUserInfoObj:@{@"uid":userId} Success:^(NSDictionary *info) {
//            user.userId = [info objectForKey:@"userId"];
//            user.portraitUri = [NSString cdImageLink:[info objectForKey:@"avatar"]];
//            user.name = [info objectForKey:@"nickname"];
//            [[RCIM sharedRCIM] refreshUserInfoCache:user withUserId:user.userId];
//            completion(user);
//        } Failure:^(NSError *error) {
//
//        }];
//    } else {
//        [UserModel getUserInfoObj:@{@"uid":userId} Success:^(NSDictionary *info) {
//            [[RCIM sharedRCIM] refreshUserInfoCache:user withUserId:user.userId];
//            completion(user);
//        } Failure:^(NSError *error) {
//
//        }];
//    }
//    return;
//}

#pragma mark RCIMGroupInfoDataSource
- (void)getUserInfoWithUserId:(NSString *)userId
                      inGroup:(NSString *)groupId
                   completion:(void (^)(RCUserInfo *userInfo))completion{
    //    NSLog(@"dsad");
}

#pragma mark RCIMGroupUserInfoDataSource
//- (void)getAllMembersOfGroup:(NSString *)groupId result:(void (^)(NSArray<NSString *> *userIdList))resultBlock{
//
//}



- (void)initWithMode{
    [[RCIM sharedRCIM] initWithAppKey:[AppModel shareInstance].rongYunKey];
}

- (void)setToken:(NSString *)token{
    [[RCIMClient sharedRCIMClient] setDeviceToken:token];
}

- (void)doConnect{
    if (self.isConnectRC) {
        return;
    }
    [[RCIM sharedRCIM] disconnect];
    if ([AppModel shareInstance].rongYunToken != nil) {
        [self connectRongCloud];
    } else {
        [self getRongCloudToken];
    }
}


#pragma mark -  与融云服务器建立连接
- (void)connectRongCloud {
    WEAK_OBJ(weakSelf, self);
    NSLog(@"============ 融云Token:%@ ============",[AppModel shareInstance].rongYunToken);
    
    [[RCIM sharedRCIM] connectWithToken:[AppModel shareInstance].rongYunToken success:^(NSString *userId) {
        [weakSelf refreshUserInfo];
        weakSelf.isConnectRC = YES;
        weakSelf.retryCount = 0;
    } error:^(RCConnectErrorCode status) {
        NSLog(@"🔴 %ld",(long)status);
        weakSelf.isConnectRC = NO;
        if(weakSelf.retryCount < 10){
            weakSelf.retryCount++;
           [[RongCloudManager shareInstance] doConnect];
        }
    } tokenIncorrect:^{ 
        NSLog(@"***** 🔴Token不正确 *****");
        weakSelf.isConnectRC = NO;
        [[RCIMClient sharedRCIMClient] disconnect];
        if(weakSelf.retryCount < 10){
            weakSelf.retryCount += 1;
            [weakSelf getRongCloudToken];
        }
    }];
}


-(void)refreshUserInfo{
    RCUserInfo *user = [[RCUserInfo alloc]initWithUserId:APP_MODEL.user.userId name:APP_MODEL.user.nick portrait:[NSString cdImageLink:APP_MODEL.user.avatar]];
    [[RCIM sharedRCIM] refreshUserInfoCache:user withUserId:APP_MODEL.user.userId];
    [RCIM sharedRCIM].currentUserInfo = user;
}

#pragma mark - 获取融云Token
/**
 获取融云Token
 */
- (void)getRongCloudToken {
    //    [NET_REQUEST_MANAGER requestIMTokenWithSuccess:^(id object) {
    //        NSLog(@"************** 融云Token: %@ **************", [object objectForKey:@"data"]);
    //        [self connectRongCloud];
    //    } fail:^(id object) {
    //        NSLog(@"************** 🔴获取融云Token失败 **************");
    //        [FUNCTION_MANAGER handleFailResponse:object];
    //    }];
    
    BADataEntity *entity = [BADataEntity new];
    entity.urlString = [NSString stringWithFormat:@"%@%@",APP_MODEL.serverUrl,@"social/basic/getIMToken"];
    entity.needCache = NO;
    
    __weak __typeof(self)weakSelf = self;
    [BANetManager ba_request_GETWithEntity:entity successBlock:^(id response) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if ([response objectForKey:@"code"] && [[response objectForKey:@"code"] integerValue] == 0) {
             NSLog(@"************** 融云Token: %@ **************", [response objectForKey:@"data"]);
            [AppModel shareInstance].rongYunToken = [response objectForKey:@"data"];
            [[AppModel shareInstance] saveAppModel];
            [strongSelf connectRongCloud];
        } else {
            NSLog(@"************** 🔴获取融云Token失败 %@**************",response);
//            AlertViewCus *view = [AlertViewCus createInstanceWithView:nil];
//            [view showWithText:@"此账号连接服务器失败" button:@"退出重连" callBack:^(id object) {
//                [[AppModel shareInstance] logout];
//            }];
        }
    } failureBlock:^(NSError *error) { 
        NSLog(@"************** 🔴获取融云Token失败 %@**************",error);
//        AlertViewCus *view = [AlertViewCus createInstanceWithView:nil];
//        [view showWithText:@"此账号连接服务器失败" button:@"退出重连" callBack:^(id object) {
//            [[AppModel shareInstance] logout];
//        }];
    } progressBlock:nil];
}




- (void)disConnect{
    self.isConnectRC = NO;
    [[RCIM sharedRCIM] logout];
}




//设置群组通知消息没有提示音
- (BOOL)onRCIMCustomAlertSound:(RCMessage *)message {
    //当应用处于前台运行，收到消息不会有提示音。
    //  if ([message.content isMemberOfClass:[RCGroupNotificationMessage class]]) {
    // targetID   2   messageId  = 15896   senderUserId = 1
    
    NSString *switchKeyStr = [NSString stringWithFormat:@"%@-%@", APP_MODEL.user.userId,message.targetId];
    // 读取
    BOOL isSwitch = [[NSUserDefaults standardUserDefaults] boolForKey:switchKeyStr];
    return isSwitch;
    //  }
    //  return NO;
}

@end
