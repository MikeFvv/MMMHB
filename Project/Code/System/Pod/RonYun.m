//
//  RonYun.m
//  Project
//
//  Created by mini on 2018/7/31.
//  Copyright © 2018年 CDJay. All rights reserved.
//

#import "RonYun.h"
//#import <RongIMKit/RongIMKit.h>
#import <RongIMLib/RongIMLib.h>
#import "SqliteManage.h"
#import "EnvelopeMessage.h"
#import "ChatViewController.h"
#import "NetRequestManager.h"

@interface RonYun()
@end

@implementation RonYun


+ (RonYun *)shareInstance{
    static RonYun *instance = nil;
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
                
            }
            break;
        default:
            break;
    }
    
}

- (void)setMode:(NSInteger)mode{
    [[RCIM sharedRCIM] initWithAppKey:(mode==0)?RyTestKey:RyKey];
}

#pragma mark - RCIMReceiveMessageDelegate
- (void)onRCIMReceiveMessage:(RCMessage *)message left:(int)left{
    
    if (message.conversationType == ConversationType_PRIVATE) {
        RCTextMessage *text = (RCTextMessage *)message.content;
        if ([message.senderUserId isEqualToString:@"1"]&&[text.content isEqualToString:@"push웃유App"]) {
            NSLog(@"%@",text.extra.mj_JSONObject);
            NSString *type = text.extra.mj_JSONObject[@"type"];
            if ([type isEqualToString:@"login"]) {
                if (!APP_MODEL.user.isLogined) {
                    return;
                }
                if (![APP_MODEL.user.token isEqualToString:text.extra.mj_JSONObject[@"token"]]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [AppModel loginOut];
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
    }else{
        int number = 0;
        NSString *tid = nil;
        ChatViewController *vc = [ChatViewController currentChat];
        if (vc) {
            tid = vc.targetId;
        }
        NSString *gId = message.targetId;
        number = ([tid isEqualToString:gId])?0:1;
        NSString *text = nil;
        if ([message.content isKindOfClass:[RCTextMessage class]]) {
            RCTextMessage *content = (RCTextMessage *)message.content;
            text = content.content;
        }
        else if ([message.content isKindOfClass:[RCImageMessage class]]){
            text = @"【图片】";
        }else if ([message.content isKindOfClass:[RCVoiceMessage class]]){
            text = @"【语音】";
        }else if ([message.content isKindOfClass:[EnvelopeMessage class]]){
            text = @"【红包】";
        }
        else
        text = @"暂无未读消息";
        
        [SqliteManage updateGroup:gId number:number lastMessage:text];
    }
}

#pragma mark - RCIMUserInfoDataSource
- (void)getUserInfoWithUserId:(NSString *)userId completion:(void (^)(RCUserInfo *))completion {
    NSLog(@"getUserInfoWithUserId ----- %@", userId);
    RCUserInfo *user = [RCUserInfo new];
    if (userId == nil || [userId length] == 0) {
        user.userId = userId;
        user.portraitUri = @"";
        user.name = @"";
        completion(user);
        return;
    }
    //开发者调自己的服务器接口根据userID异步请求数据
    if (![userId isEqualToString:[RCIM sharedRCIM].currentUserInfo.userId]) {
        [UserModel getUserInfoObj:@{@"uid":userId} Success:^(NSDictionary *info) {
            user.userId = [info objectForKey:@"userId"];
            user.portraitUri = [NSString cdImageLink:[info objectForKey:@"avatar"]];
            user.name = [info objectForKey:@"nickname"];
            [[RCIM sharedRCIM] refreshUserInfoCache:user withUserId:user.userId];
            completion(user);
        } Failure:^(NSError *error) {
            
        }];
    } else {
        [UserModel getUserInfoObj:@{@"uid":userId} Success:^(NSDictionary *info) {
            [[RCIM sharedRCIM] refreshUserInfoCache:user withUserId:user.userId];
            completion(user);
        } Failure:^(NSError *error) {
            
        }];
    }
    return;
}

#pragma mark RCIMGroupInfoDataSource
- (void)getGroupInfoWithGroupId:(NSString *)groupId completion:(void (^)(RCGroup *groupInfo))completion{
    
}

#pragma mark RCIMGroupInfoDataSource
- (void)getUserInfoWithUserId:(NSString *)userId
                      inGroup:(NSString *)groupId
                   completion:(void (^)(RCUserInfo *userInfo))completion{
    NSLog(@"dsad");
}

#pragma mark RCIMGroupUserInfoDataSource
- (void)getAllMembersOfGroup:(NSString *)groupId result:(void (^)(NSArray<NSString *> *userIdList))resultBlock{
    
}



+ (void)initWithMode:(NSInteger)mode{
    [[RonYun shareInstance]setMode:mode];
}

- (void)setToken:(NSString *)token{
    [[RCIMClient sharedRCIMClient] setDeviceToken:token];
}

- (void)doConnect{
    if (self.isConnected) {
        return;
    }
    [[RCIM sharedRCIM]disconnect];
    if (APP_MODEL.rongYunToken != nil) {
        [self connect];
    }
    else{
        [self getToken];
    }
}



- (void)connect{
    NSLog(@"token%@",APP_MODEL.rongYunToken);
    WEAK_OBJ(weakSelf, self);
    [[RCIM sharedRCIM]connectWithToken:APP_MODEL.rongYunToken success:^(NSString *userId) {
        RCUserInfo *user = [[RCUserInfo alloc]initWithUserId:userId name:APP_MODEL.user.userNick portrait:[NSString cdImageLink:APP_MODEL.user.userAvatar]];
        [[RCIM sharedRCIM] refreshUserInfoCache:user withUserId:userId];
        [RCIM sharedRCIM].currentUserInfo = user;
        weakSelf.isConnected = YES;
    } error:^(RCConnectErrorCode status) {
        NSLog(@"%ld",(long)status);
        weakSelf.isConnected = NO;
    } tokenIncorrect:^{
        NSLog(@"token is invalue");
        weakSelf.isConnected = NO;
        [[RCIMClient sharedRCIMClient]disconnect];
        [weakSelf getToken];
    }];
}

- (void)getToken{
    WEAK_OBJ(weakSelf, self);
    [NET_REQUEST_MANAGER requestIMTokenWithSuccess:^(id object) {
        [weakSelf connect];
    } fail:^(id object) {
        [FUNCTION_MANAGER handleFailResponse:object];
    }];
}

- (void)disConnect{
    RONG_YUN.isConnected = NO;
    [[RCIM sharedRCIM]disconnect];
}

@end
