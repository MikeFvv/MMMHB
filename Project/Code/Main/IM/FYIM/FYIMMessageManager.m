//
//  FYSocketMessageManager.m
//  
//
//  Created by Mike on 2019/3/30.
//  Copyright © 2019 Mike. All rights reserved.
//

#import "FYIMMessageManager.h"
#import <AVFoundation/AVFoundation.h>

#import "FYSocketManager.h"
#import <MJExtension/MJExtension.h>
#import "WHC_ModelSqlite.h"
#import "FYMessagelLayoutModel.h"
#import "SSChatDatas.h"
#import "EnvelopeMessage.h"

#import "FYIMSessionViewController.h"


@interface FYIMMessageManager ()

@property (nonatomic,strong) AVAudioPlayer *player;
// 是否已经获取到我加入的群数据
@property (nonatomic,assign) BOOL isGetMyJoinGroups;
// 是否已经获取到离线消息
@property (nonatomic,assign) BOOL isGetOfflineMessage;
// 最新消息
@property (nonatomic,strong) NSMutableArray *latestMessageArray;


@end

@implementation FYIMMessageManager

+ (FYIMMessageManager *)shareInstance{
    static FYIMMessageManager *instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[[self class] alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _isConnectFY = NO;
        _isGetMyJoinGroups = NO;
        _isGetOfflineMessage = NO;
        _latestMessageArray = [NSMutableArray array];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doneGetMyJoinedGroupsNotification) name:kDoneGetMyJoinedGroupsNotification object:nil];
    }
    return self;
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)initWithAppKey:(NSString *)appKey {
    [self startConnecting:appKey];
}

#pragma mark - socket消息处理
- (void)startConnecting:(NSString *)appKey {
    
    NSString *url = [NSString stringWithFormat:@"%@?token=%@",[AppModel shareInstance].commonInfo[@"ws_url"], appKey];
    NSLog(@"======url======>%@", url);
    [[FYSocketManager shareManager] fy_open:url connect:^{
        NSLog(@"✅ === tcp连接IM成功  === ✅");
    } receive:^(id message, FYSocketReceiveType type) {
        
        if (type == FYSocketReceiveTypeForMessage) {
            //            NSLog(@"接收 类型1--%@",message);
            NSDictionary *dict = (NSDictionary *)[message mj_JSONObject];
            NSInteger command = [dict[@"command"] integerValue];
            
            if (command == 6) {
                NSInteger code = [dict[@"code"] integerValue];
                if (code == 10007) {
                    self.isConnectFY = YES;
                    NSLog(@"✅✅✅✅✅✅✅ === 登录IM成功  === ✅✅✅✅✅✅✅");
                    // 登录成功，连接建立。收到消息
                    //                    [self sendGetOfflineMessages];
                    [self sendGetNewUnreadMessage];
                }
                else if (code == 10008) {
                    NSLog(@"登录失败,无效token!");
                    [AppModel shareInstance].userInfo.token = nil;
                    [[NSNotificationCenter defaultCenter] postNotificationName:kOnConnectSocketNotification object: nil];
                } else if (code == 10010) {
                    // 被踢出登录  此账号已在其它终端登录
                    [self kickedOutLogin];
                } else if (code == 10009) {
                    NSLog(@"登录失败，此账号已被封");
                    [[FYSocketManager shareManager] fy_close:nil];
                    [self forcedOffline:dict];
                }
            } else if (command == 12) {
                // 系统消息类
                [self sysMessage:dict];
            } else if (command == 11) {//在线气泡
                NSDictionary *dictList = dict[@"data"];
                [self receiveMessage:dictList isOfflineMsg:NO messageCount:0 left:0];
            } else if (command == 13) {
                // 心跳处理
            } else if (command == 16) {
                // 撤回消息
                [self userRecallMessage:dict];
            } else if (command == 20) {
                // 历史消息
                [self getOfflineMessagesData:dict];
            } else if (command == 31) {
                // 所有群的未读消息
                [self getNewUnreadMessageData:dict];
            }
            else if (command == 26) { // 通知
                [self sysNotificationMessage:dict];
            } else if (command == 28) { // 强制下线
                NSInteger code = [dict[@"code"] integerValue];
                if (code == 10029) {
                    // 强制下线
                    [self forcedOffline:dict];
                }
            }
            
        } else if (type == FYSocketReceiveTypeForPong){
            NSLog(@"🔴接收 类型2--%@",message);
        }
    } failure:^(NSError *error) {
        self.isConnectFY = NO;   // 本地dns没有设置也会出现连接不上
        NSLog(@"🔴 ====== 连接失败 ====== 🔴%@",error);
    }];
}



#pragma mark - 获取离线消息数据   command 20
- (void)getOfflineMessagesData:(NSDictionary *)dict {
    NSInteger code = [dict[@"code"] integerValue];
    if (code == 10016) {
        NSDictionary *dataDict = dict[@"data"];
        NSArray *groupArray = dataDict[@"groups"];
        
        for (NSInteger index = 0; index < groupArray.count; index++) {
            NSDictionary *groupDict = groupArray[index];
            //            NSString *groupId =  groupDict[@"groupId"];
            NSArray *groupMessageList =  groupDict[@"offlineMsgList"];
            NSInteger num = groupMessageList.count;
            
            for (NSInteger i = 0; i < groupMessageList.count; i++) {
                num--;
                [self receiveMessage:groupMessageList[i] isOfflineMsg:YES messageCount:0 left:num];
            }
        }
    } else if (code == 10018) {
        // 下拉数据
        NSDictionary *groupDict = dict[@"data"];
        NSString *groupId = [NSString stringWithFormat:@"%@", groupDict[@"groupId"]];
        NSArray *groupMessageList =  groupDict[@"msgList"];
        
        NSArray *messageList = [self messageJsonModel:groupMessageList];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(downPullGetMessageArray:)]) {
            [self.delegate downPullGetMessageArray:messageList];
        }
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [WHC_ModelSqlite inserts:messageList];
        });
    }
}


- (NSArray *)messageJsonModel:(NSArray *)array {
    
    NSMutableArray *arrayM = [NSMutableArray array];
    for (NSInteger index = 0; index < array.count; index++) {
        
        FYMessage *message = [FYMessage mj_objectWithKeyValues:array[index]];
        if(message.messageType == FYMessageTypeRedEnvelope){
            if ([array[index] isKindOfClass:[NSDictionary class]]) {
                EnvelopeMessage *reMessage = [EnvelopeMessage mj_objectWithKeyValues:[message.text mj_JSONObject]];
                message.redEnvelopeMessage  = reMessage;
            }
        }
        message.create_time = [NSDate date];
        
        if ([[AppModel shareInstance].userInfo.userId isKindOfClass:[NSNumber class]]) {
            [AppModel shareInstance].userInfo.userId  = [(NSNumber *)[AppModel shareInstance].userInfo.userId stringValue];
        }
        
        [arrayM addObject:message];
    }
    
    return arrayM;
}




#pragma mark - 获取所有群未读消息
- (void)getNewUnreadMessageData:(NSDictionary *)dict {
    NSInteger code = [dict[@"code"] integerValue];
    if (code == 10036) {
        NSArray *groupArray = dict[@"data"];
        
        for (NSInteger index = 0; index < groupArray.count; index++) {
            NSDictionary *groupDict = groupArray[index];
            NSString *groupId = [NSString stringWithFormat:@"%@", groupDict[@"groupId"]];
            NSInteger messageCount =  [groupDict[@"count"] integerValue]; // 未读消息总量
            NSArray *groupMessageList =  groupDict[@"msgList"];
            NSInteger num = groupMessageList.count;  // 当前返回数量
            
            if (messageCount >= 100) {
                NSString *query = [NSString stringWithFormat:@"sessionId='%@'",groupId];
                [WHC_ModelSqlite delete:[FYMessage class] where:query];
            }
            
            for (NSInteger i = 0; i < groupMessageList.count; i++) {
                num--;
                [self receiveMessage:groupMessageList[i] isOfflineMsg:YES messageCount:messageCount left:num];
            }
        }
        
        // 获取到了 未读消息
        self.isGetOfflineMessage = YES;
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [WHC_ModelSqlite inserts:self.latestMessageArray];
        });
    }
}

#pragma mark - 上线发送获取未读消息命令
/**
 发送命令获取所有群未读消息  对应返回 command 31  code 10036
 */
- (void)sendGetNewUnreadMessage {
    if (self.isGetMyJoinGroups) {
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
            NSMutableArray *listArray = [NSMutableArray array];
            for (NSInteger i = 0; i < [AppModel shareInstance].myGroupArray.count; i++) {
                NSMutableDictionary *listDict = [NSMutableDictionary dictionary];
                [listDict setObject:[AppModel shareInstance].myGroupArray[i] forKey:@"groupId"];
                NSString *whereStr = [NSString stringWithFormat:@"sessionId = %@", [AppModel shareInstance].myGroupArray[i]];
                FYMessage *fyMessage = [[WHC_ModelSqlite query:[FYMessage class] where:whereStr order:@"by timestamp desc" limit:@"0,1"] firstObject];
                [listDict setObject:@(fyMessage.timestamp) forKey:@"msgCreateTime"];
                [listArray addObject:listDict];
            }
            
            NSDictionary *parameters = @{
                                         @"cmd":@"30",
                                         @"list":listArray
                                         };
            NSLog(@"✅✅✅%@",parameters);
            [self sendMessageServer:parameters];
        });
    }
    NSLog(@"1");
}

/**
 发送命令获取离线消息
 */
- (void)sendGetOfflineMessages {
    NSDictionary *parameters = @{
                                 @"userId":[AppModel shareInstance].userInfo.userId,
                                 @"type":@"0",
                                 @"cmd":@"19"
                                 };
    [self sendMessageServer:parameters];
}

- (void)doneGetMyJoinedGroupsNotification {
    _isGetMyJoinGroups = YES;
    if (self.isConnectFY) {
        [self sendGetNewUnreadMessage];
    }
}



#pragma mark - 下拉请求的数据发送的参数
/**
 聊天界面下拉请求数据   对应返回 command 20  code 10018
 */
- (void)sendDropdownRequest:(NSString *)groupId endTime:(NSTimeInterval)endTime {
    // 固定返回50条
    NSDictionary *parameters = @{
                                 @"cmd":@"19",
                                 @"endTime":endTime == -1 ? @"" : @(endTime),
                                 @"groupId":groupId,
                                 @"userId":[AppModel shareInstance].userInfo.userId
                                 };
    [self sendMessageServer:parameters];
}



#pragma mark - 撤回消息
- (void)userRecallMessage:(NSDictionary *)dict {
    
    NSDictionary *dataDict = dict[@"data"];
    NSString *whereStr = [NSString stringWithFormat:@"messageId='%@'", dataDict[@"id"]];
    FYMessage *fyMessage = [[WHC_ModelSqlite query:[FYMessage class] where:whereStr] firstObject];
    fyMessage.isDeleted = YES;
    fyMessage.isRecallMessage = YES;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(willRecallMessage:)]) {
        [self.delegate willRecallMessage:[NSString stringWithFormat:@"%@", dataDict[@"id"]]];
    }
    
    if (fyMessage != nil) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [WHC_ModelSqlite update:fyMessage where:whereStr];
        });
    }
}


#pragma mark - 系统消息类
/**
 common 12 系统消息类
 
 @param dict 字典数据
 */
- (void)sysMessage:(NSDictionary *)dict {
    NSInteger code = [dict[@"code"] integerValue];
    FYMessage *message = [[FYMessage alloc] init];
    if (code == 10000) {  // 消息发送成功
        NSLog(@"消息发送成功");
    } else if (code == 10024 || code == 10025 || code == 10032 || code == 10033) {
        // 10024 您已被禁言!   // 10025 群组已禁言!   // 10032 聊天字数超过群限制    // 10033 说话速度超过群设置的聊天间隔
        message.messageType = FYSystemMessage;
        message.create_time = [NSDate date];
        
        message.text = dict[@"msg"];
        if (self.delegate && [self.delegate respondsToSelector:@selector(willAppendAndDisplayMessage:)]) {
            message = [self.delegate willAppendAndDisplayMessage:message];
        }
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [WHC_ModelSqlite insert:message];
        });
    }
}

#pragma mark - 消息接收
/**
 common 11 or other 消息接收
 
 @param dict 消息字典数据
 @param isOfflineMsg 是否离线消息
 @param left -
 */
- (void)receiveMessage:(NSDictionary *)dict isOfflineMsg:(BOOL)isOfflineMsg messageCount:(NSInteger)messageCount left:(NSInteger)left {
    
    FYMessage *message = [FYMessage mj_objectWithKeyValues:dict];
    
    if(message.messageType == FYMessageTypeRedEnvelope){
        if ([dict isKindOfClass:[NSDictionary class]]) {
            EnvelopeMessage *reMessage = [EnvelopeMessage mj_objectWithKeyValues:[message.text mj_JSONObject]];
            message.redEnvelopeMessage  = reMessage;
        }
    }
    message.create_time = [NSDate date];
    
    NSString *sessionId = nil;
    FYIMSessionViewController *vc = [FYIMSessionViewController currentChat];
    if (vc) {
        sessionId = vc.sessionId;
    }
    
    if ([[AppModel shareInstance].userInfo.userId isKindOfClass:[NSNumber class]]) {
        [AppModel shareInstance].userInfo.userId  = [(NSNumber *)[AppModel shareInstance].userInfo.userId stringValue];
    }
    if ([[AppModel shareInstance].userInfo.userId isEqualToString:message.messageSendId]) {
        message.deliveryState = FYMessageDeliveryStateDeliveried;
        message.isReceivedMsg = YES;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(willAppendAndDisplayMessage:)] && [sessionId isEqualToString: message.sessionId]) {
        message = [self.delegate willAppendAndDisplayMessage:message];
    }
    
    // 更新数据库的消息  暂时不做
    //                        if (message.deliveryState == FYMessageDeliveryStateDeliveried && message.isReceivedMsg == YES) {
    //
    //                        } else {
    //
    //                        }
    
    if (self.receiveMessageDelegate && [self.receiveMessageDelegate respondsToSelector:@selector(onFYIMReceiveMessage: messageCount:left:)]) {
        [self.receiveMessageDelegate onFYIMReceiveMessage:message messageCount:messageCount left:left];
    }
    
    if (self.receiveMessageDelegate && [self.receiveMessageDelegate respondsToSelector:@selector(onFYIMCustomAlertSound:)] && ![[AppModel shareInstance].userInfo.userId isEqualToString: message.messageSendId] && ![sessionId isEqualToString: message.sessionId]) {
        
        if (![AppModel shareInstance].turnOnSound && ![self.receiveMessageDelegate onFYIMCustomAlertSound:message]) {
#if TARGET_IPHONE_SIMULATOR
#elif TARGET_OS_IPHONE
            [self.player play];
#endif
        }
    }
    
    if ((!isOfflineMsg && self.isGetOfflineMessage) || isOfflineMsg) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [WHC_ModelSqlite insert:message];
        });
    } else {
        // 先保存在属性当中， 之后再保存数据库
        [self.latestMessageArray addObject:message];
    }
}


#pragma mark - 系统通知类
/**
 common 26 系统通知类
 
 @param dict 字典数据
 */
- (void)sysNotificationMessage:(NSDictionary *)dict {
    // 广播消息
    NSDictionary *dictData = [NSDictionary dictionaryWithDictionary:dict[@"data"]];
    NSString *objectName = [NSString stringWithFormat:@"%@", dictData[@"objectName"]];
    if ([objectName isEqualToString:@"refreshNews"]) {
        // 刷新新闻公告
        [[NetRequestManager sharedInstance] requestSystemNoticeWithSuccess:nil fail:nil];
        return;
    } else if ([objectName isEqualToString:@"refreshGroup"]) {
        // 刷新群信息
        [[NSNotificationCenter defaultCenter] postNotificationName:kReloadMyMessageGroupList object:nil];
    } else if ([objectName isEqualToString:@"refreshConfig"]) {
        // 刷新appconfig 接口
        [[NetRequestManager sharedInstance] requestAppConfigWithSuccess:^(id object) {
            
        } fail:^(id object) {
            
        }];
    }
}

/**
 发送消息
 
 @param parameters 参数
 */
- (void)sendMessageServer:(NSDictionary *)parameters {
    
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:parameters options:NSJSONWritingPrettyPrinted error:&parseError];
    [[FYSocketManager shareManager] fy_sendData:jsonData];
}



#pragma mark - 退出登录
- (void)userSignout {
    [[FYSocketManager shareManager] fy_close:nil];
    self.isConnectFY = NO;
    [AppModel shareInstance].userInfo.token = nil;
    [FYSocketManager shareManager].isViewLoad = NO;
//    [WHC_ModelSqlite removeModel:[FYMessage class]];
}

/**
 被踢出登录  此账号已在其它终端登录
 */
- (void)kickedOutLogin {
    [self userSignout];
    [[AppModel shareInstance] logout];
    dispatch_async(dispatch_get_main_queue(),^{
        AlertViewCus *view = [AlertViewCus createInstanceWithView:nil];
        [view showWithText:kOtherDevicesLoginMessage button:@"好的" callBack:nil];
    });
}

// 强制下线
- (void)forcedOffline:(NSDictionary *)dict {
    [self userSignout];
    [[AppModel shareInstance] logout];
    
    dispatch_async(dispatch_get_main_queue(),^{
        AlertViewCus *view = [AlertViewCus createInstanceWithView:nil];
        [view showWithText:[NSString stringWithFormat:@"%@", dict[@"msg"]] button:@"确定" callBack:nil];
    });
}

#pragma mark - 更新红包信息
// 更新红包信息
- (void)setRedEnvelopeMessage:(NSString *)messageId redEnvelopeMessage:(EnvelopeMessage *)redEnvelopeMessage {
    
    NSString *whereStr = [NSString stringWithFormat:@"messageId='%@'", messageId];
    FYMessage *fyMessage = [[WHC_ModelSqlite query:[FYMessage class] where:whereStr] firstObject];
    fyMessage.redEnvelopeMessage = redEnvelopeMessage;
    if (fyMessage != nil) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [WHC_ModelSqlite update:fyMessage where:whereStr];
        });
    }
}



- (AVAudioPlayer *)player {
    if (!_player) {
        // 1. 创建播放器对象
        // 虽然传递的参数是NSURL地址, 但是只支持播放本地文件, 远程音乐文件路径不支持
        NSURL *url = [[NSBundle mainBundle]URLForResource:@"fy_sms-received.caf" withExtension:nil];
        _player = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:nil];
        
        //允许调整速率,此设置必须在prepareplay 之前
        _player.enableRate = YES;
        //        _player.delegate = self;
        
        //指定播放的循环次数、0表示一次
        //任何负数表示无限播放
        [_player setNumberOfLoops:0];
        //准备播放
        [_player prepareToPlay];
        
    }
    return _player;
}


@end



