//
//  FYIMManager.m
//  Project
//
//  Created by Mike on 2019/4/2.
//  Copyright © 2019 CDJay. All rights reserved.
//

#import "FYIMManager.h"
#import "BANetManager_OC.h"
#import "FYIMMessageManager.h"
#import "ChatViewController.h"
#import "SqliteManage.h"
#import "SSKeychain.h"
#import "GTMBase64.h"
#import "NSData+AES.h"
#import "MessageSingle.h"
#import "PushMessageModel.h"


@implementation FYIMManager

+ (FYIMManager *)shareInstance {
    static FYIMManager *instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[[self class] alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        //        self.isConnectFY = NO;
        [self onConnectSocket];
        [FYIMMessageManager shareInstance].receiveMessageDelegate = self;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onConnectSocket) name:kOnConnectSocketNotification object:nil];
    }
    return self;
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


/**
 更新红包信息
 
 @param messageId 消息ID
 @param redEnvelopeMessage 更改后的红包模型
 */
- (void)setRedEnvelopeMessage:(NSString *)messageId redEnvelopeMessage:(EnvelopeMessage *)redEnvelopeMessage {
    [[FYIMMessageManager shareInstance] setRedEnvelopeMessage:messageId redEnvelopeMessage:redEnvelopeMessage];
}

- (void)onConnectSocket {
    
    if ([FYIMMessageManager shareInstance].isConnectFY) {
        return;
    }
    if ([AppModel shareInstance].commonInfo[@"ws_url"] == nil) {
        return;
    }
    // 用户token
    if ([AppModel shareInstance].userInfo.token != nil) {
        [self notificationLogin];
        [[FYIMMessageManager shareInstance] initWithAppKey:[AppModel shareInstance].userInfo.token];
    } else {
        [self getFYToken];
    }
}

#pragma mark - FYReceiveMessageDelegate 消息来源
- (void)onFYIMReceiveMessage:(FYMessage *)message messageCount:(NSInteger)messageCount left:(NSInteger)left {
    NSInteger number = 0;
    NSString *tid = nil;
    
    ChatViewController *vc = [ChatViewController currentChat];
    if (vc) {
        tid = vc.sessionId;
    }
    number = ([tid isEqualToString:message.sessionId]) ? 0 : 1;
    
    NSString *lastMessage = nil;
    if (message.messageType == FYMessageTypeRedEnvelope) {
        lastMessage = @"【红包】";
    } else if (message.messageType == FYMessageTypeNoticeRewardInfo) {
        lastMessage = @"【报奖结果】";
    } else {
        lastMessage = message.text;
    }
    [self updateGroup:message.sessionId number:number lastMessage:lastMessage messageCount:messageCount left:left];
}

- (void)updateGroup:(NSString *)groupId number:(NSInteger)number lastMessage:(NSString *)last messageCount:(NSInteger)messageCount left:(NSInteger)left {
    NSString *queryId = [NSString stringWithFormat:@"%@-%@",groupId,[AppModel shareInstance].userInfo.userId];
    PushMessageModel *oldModel = (PushMessageModel *)[MessageSingle shareInstance].myJoinGroupMessage[queryId];
    
    if (oldModel) {
        if (number == 0) {
            [AppModel shareInstance].unReadCount -= oldModel.number;
            oldModel.number = 0;
        } else {
            if (oldModel.number > 99) {
                return;
            }
            oldModel.number += 1;
            [AppModel shareInstance].unReadCount += 1;
            oldModel.messageCountLeft = messageCount;
        }
        
        if (last.length >0) {
            oldModel.lastMessage = last;
        }
    } else {
        if (number == 0) {
            return;
        }
        
        [AppModel shareInstance].unReadCount += 1;
        PushMessageModel *newModel = [PushMessageModel new];
        newModel.userId = [AppModel shareInstance].userInfo.userId;
        newModel.number = 1;
        newModel.lastMessage = last;
        newModel.sessionId = groupId;
        newModel.messageCountLeft = messageCount;
        
        [[MessageSingle shareInstance].myJoinGroupMessage setObject:newModel forKey:queryId];
        
    }
    
    if ((left == 0 && oldModel.number <= 99) || (messageCount > 0 && left == 0)) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kUnreadMessageNumberChange object:nil];
    }
}




#pragma mark - 获取IM Token
/**
 获取IM Token
 */
- (void)getFYToken {
    
    NSString *password = [SSKeychain passwordForService:@"password" account:[AppModel shareInstance].userInfo.mobile];
    if (password == nil) {
        if([AppModel shareInstance].userInfo.isLogined == YES) {
            [[AppModel shareInstance] logout];
        }
        return;
    }
    NSString *key = @"1234567887654321";
    NSData *data = [password dataUsingEncoding:NSUTF8StringEncoding];
    data = [data AES128EncryptWithKey:key gIv:key];
    data = [GTMBase64 encodeData:data];
    NSString *passswordS = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    passswordS = [[FunctionManager sharedInstance] encodedWithString:passswordS];
    
    BADataEntity *entity = [BADataEntity new];
    entity.urlString = [NSString stringWithFormat:@"%@%@?username=%@&password=%@&randomStr=82701535096009570&code=5app&grant_type=password&scope=server",[AppModel shareInstance].serverUrl,@"auth/oauth/token", [AppModel shareInstance].userInfo.mobile, passswordS];
    entity.needCache = NO;
    
    NSString *defaultToken = @"Basic YXBwOmFwcA==";
    
    [[BANetManager sharedBANetManager].sessionManager.requestSerializer setValue:defaultToken forHTTPHeaderField:@"Authorization"];
    
    __weak __typeof(self)weakSelf = self;
    [BANetManager ba_request_POSTWithEntity:entity successBlock:^(id response) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if ([response isKindOfClass:[NSDictionary class]]) {
            NSLog(@"************** Token: %@ **************", [response objectForKey:@"access_token"]);
            [AppModel shareInstance].userInfo.token = [response objectForKey:@"access_token"];
            [[AppModel shareInstance] saveAppModel];
            if ([AppModel shareInstance].userInfo.token.length > 0) {
                [weakSelf onConnectSocket];
            }
        } else {
            NSLog(@"************** 🔴获取Token失败 %@**************",response);
        }
    } failureBlock:^(NSError *error) {
        NSLog(@"************** 🔴获取 Token失败 %@**************",error);
    } progressBlock:nil];
}

/**
 通知服务器 登录了
 */
- (void)notificationLogin {
    
    BADataEntity *entity = [BADataEntity new];
    entity.urlString = [NSString stringWithFormat:@"%@%@",[AppModel shareInstance].serverUrl,@"social/basic/appLogin"];
    entity.needCache = NO;
    //    __weak __typeof(self)weakSelf = self;
    [BANetManager ba_request_GETWithEntity:entity successBlock:^(id response) {
        //        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if ([response objectForKey:@"code"] && [[response objectForKey:@"code"] integerValue] == 0) {
        } else {
        }
    } failureBlock:^(NSError *error) {
    } progressBlock:nil];
}


//设置群组通知消息没有提示音  NO 有声音
- (BOOL)onFYIMCustomAlertSound:(FYMessage *)message {
    //    当应用处于前台运行，收到消息不会有提示音。
    NSString *switchKeyStr = [NSString stringWithFormat:@"%@-%@", [AppModel shareInstance].userInfo.userId,message.sessionId];
    // 读取
    BOOL isSwitch = [[NSUserDefaults standardUserDefaults] boolForKey:switchKeyStr];
    return isSwitch;
}

/**
 用户主动退出登录
 */
- (void)userSignout {
    [[FYIMMessageManager shareInstance] userSignout];
    [WHC_ModelSqlite removeModel:[PushMessageModel class]];
    [[MessageSingle shareInstance].myJoinGroupMessage removeAllObjects];
}

@end
