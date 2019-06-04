//
//  SSChatDatas.m
//  SSChatView
//
//  Created by soldoros on 2018/9/25.
//  Copyright © 2018年 soldoros. All rights reserved.
//


#import "SSChatDatas.h"
#import "EnvelopeMessage.h"
#import "NSTimer+SSAdd.h"

#define headerImg1  @"http://www.120ask.com/static/upload/clinic/article/org/201311/201311061651418413.jpg"
#define headerImg2  @"http://www.qqzhi.com/uploadpic/2014-09-14/004638238.jpg"
#define headerImg3  @"http://e.hiphotos.baidu.com/image/pic/item/5ab5c9ea15ce36d3b104443639f33a87e950b1b0.jpg"

@implementation SSChatDatas

//获取单聊的初始会话 数据均该由服务器处理生成 这里demo写死
+(NSMutableArray *)LoadingMessagesStartWithChat:(NSString *)sessionId{
    
    
    NSDictionary *dic1 = @{@"text":@"测试文字",
                           @"date":@"2018-10-10 09:20:15",
                           @"from":@"1",
                           @"messageId":@"20181010092015",
                           @"type":@"1",
                           @"sessionId":sessionId,
                           @"headerImg":headerImg1
                           };
    NSDictionary *dic2 = @{@"text":@"您好",
                           @"date":@"2018-10-10 09:22:15",
                           @"from":@"2",
                           @"messageId":@"20181010092515",
                           @"type":@"1",
                           @"sessionId":sessionId,
                           @"headerImg":headerImg2
                           };
    
    
    NSMutableArray *messages = [NSMutableArray new];
    [messages addObjectsFromArray: @[dic1,dic2]];
    
    return [SSChatDatas receiveMessages:messages];
    
}



//获取群聊的初始会话
+(NSMutableArray *)LoadingMessagesStartWithGroupChat:(NSString *)sessionId{
    
    return nil;
}


//处理接收的消息数组
+(NSMutableArray *)receiveMessages:(NSArray *)messages{
    
    NSMutableArray *array = [NSMutableArray new];
    for(NSDictionary *dic in messages){
        FYMessagelLayoutModel *layout = [SSChatDatas getMessageWithData:dic];
        [array addObject:layout];
    }
    return array;
}

//接受一条消息
+(FYMessagelLayoutModel *)receiveMessage:(id)message{
    return [SSChatDatas getMessageWithData:message];
}

//消息内容生成消息模型
+(FYMessagelLayoutModel *)getMessageWithData:(id)data {
    
    FYMessage *message;
    if ([data isKindOfClass:[FYMessage class]]) {
        message = data;
    } else {
        message = [FYMessage mj_objectWithKeyValues:data];
    }
    //    FYMessage *message = [FYMessage mj_objectWithKeyValues:dic];
    
    if (message.messageType != FYSystemMessage) {
        
        if ([message.messageSendId isEqualToString:[AppModel shareInstance].userInfo.userId]) {
            message.messageFrom = FYMessageDirection_SEND;
        } else {
            message.messageFrom  = FYMessageDirection_RECEIVE;
        }
        
        //    message.textColor    = SSChatTextColor;
        
        NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
        NSString *userKey = [NSString stringWithFormat:@"%@%@", message.sessionId, [AppModel shareInstance].userInfo.userId];
        if([user valueForKey:userKey] == nil){
            [user setValue:@(message.timestamp/1000) forKey:userKey];
            message.showTime = YES;
        }else{
            [message showTimeWithLastShowTime:[[user valueForKey:userKey] doubleValue] currentTime:message.timestamp/1000];
            if(message.showTime){
                [user setValue:@(message.timestamp/1000) forKey:userKey];
            }
        }
        
        // 默认气泡图片
        if(message.messageFrom == FYMessageDirection_SEND){
            message.backImgString = @"icon_qipao1";
        }else{
            message.backImgString = @"icon_qipao2";
        }
    }
    //    message.messageType = FYMessageTypeRedEnvelope;
    
    if(message.messageType == FYMessageTypeText || message.messageType == FYMessageTypeReportAwardInfo){
        message.cellString   = SSChatTextCellId;
    } else if(message.messageType == FYMessageTypeRedEnvelope){
        message.cellString   = FYRedEnevlopeCellId;
        if ([data isKindOfClass:[NSDictionary class]]) {
            EnvelopeMessage *reMessage = [EnvelopeMessage mj_objectWithKeyValues:[message.text mj_JSONObject]];
            message.redEnvelopeMessage  = reMessage;
        }
    } else if(message.messageType == FYMessageTypeNoticeRewardInfo){
        message.cellString   = CowCowVSMessageCellId;
        NSDictionary *dict = [message.text mj_JSONObject];
        message.cowcowRewardInfoDict  = dict;
    } else if(message.messageType == FYSystemMessage) {
        message.cellString   = NotificationMessageCellId;
        message.showTime = NO;
    }
    
    
    //    SSChatMessage *message = [SSChatMessage new];
    //
    //    FYMessageType messageType = (FYMessageType)[dic[@"type"]integerValue];
    //    FYChatMessageFrom messageFrom = (FYChatMessageFrom)[dic[@"from"]integerValue];
    
    //    if(messageFrom == FYMessageDirection_SEND){
    //        message.messageFrom = FYMessageDirection_SEND;
    //        message.backImgString = @"icon_qipao1";
    //    }else{
    //        message.messageFrom = FYMessageDirection_RECEIVE;
    //        message.backImgString = @"icon_qipao2";
    //    }
    //
    //
    //    message.sessionId    = dic[@"sessionId"];
    //    message.sendError    = NO;
    //    message.headerImgurl = dic[@"headerImg"];
    //    message.messageId    = dic[@"messageId"];
    //    message.textColor    = SSChatTextColor;
    //    message.messageType  = messageType;
    //
    //
    //    //判断时间是否展示
    //    message.messageTime = [NSTimer getChatTimeStr2:[NSTimer getStampWithTime:dic[@"date"]]];
    //    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    //    if([user valueForKey:message.sessionId]==nil){
    //        [user setValue:dic[@"date"] forKey:message.sessionId];
    //        message.showTime = YES;
    //    }else{
    //        [message showTimeWithLastShowTime:[user valueForKey:message.sessionId] currentTime:dic[@"date"]];
    //        if(message.showTime){
    //            [user setValue:dic[@"date"] forKey:message.sessionId];
    //        }
    //    }
    
    //    //判断消息类型
    //    if(message.messageType == FYMessageTypeText){
    //
    //        message.cellString   = SSChatTextCellId;
    //        message.textString = dic[@"content"] ? dic[@"content"] : dic[@"text"];
    //    }else if (message.messageType == FYMessageTypeImage){
    //        message.cellString   = SSChatImageCellId;
    //
    //        if([dic[@"image"] isKindOfClass:NSClassFromString(@"NSString")]){
    //            message.image = [UIImage imageNamed:dic[@"image"]];
    //        }else{
    //            message.image = dic[@"image"];
    //        }
    //    }else if (message.messageType == FYMessageTypeVoice){
    //
    //        message.cellString   = SSChatVoiceCellId;
    //        message.voice = dic[@"voice"];
    //        message.voiceDuration = [dic[@"second"]integerValue];
    //        message.voiceTime = [NSString stringWithFormat:@"%@'s ",dic[@"second"]];
    //
    //        message.voiceImg = [UIImage imageNamed:@"chat_animation_white3"];
    //        message.voiceImgs =
    //        @[[UIImage imageNamed:@"chat_animation_white1"],
    //          [UIImage imageNamed:@"chat_animation_white2"],
    //          [UIImage imageNamed:@"chat_animation_white3"]];
    //
    //        if(messageFrom == FYMessageDirection_RECEIVE){
    //
    //            message.voiceImg = [UIImage imageNamed:@"chat_animation3"];
    //            message.voiceImgs =
    //            @[[UIImage imageNamed:@"chat_animation1"],
    //              [UIImage imageNamed:@"chat_animation2"],
    //              [UIImage imageNamed:@"chat_animation3"]];
    //        }
    //
    //    }else if (message.messageType == FYMessageTypeMap){
    //        message.cellString = SSChatMapCellId;
    //        message.latitude = [dic[@"lat"] doubleValue];
    //        message.longitude = [dic[@"lon"] doubleValue];
    //        message.addressString = dic[@"address"];
    //
    //    }else if (message.messageType == FYMessageTypeVideo){
    //        message.cellString = SSChatVideoCellId;
    //        message.videoLocalPath = dic[@"videoLocalPath"];
    //        message.videoImage = [UIImage getImage:message.videoLocalPath];
    //    }
    
    FYMessagelLayoutModel *layout = [[FYMessagelLayoutModel alloc]initWithMessage:message];
    return layout;
    
}




// 发送一条消息
+(void)sendMessage:(FYMessage *)message messageBlock:(MessageBlock)messageBlock {
    
    NSMutableDictionary *messageDic = [NSMutableDictionary dictionaryWithDictionary:nil];
    
    long time = [NSTimer getLocationTimeStamp];
    //    NSString *messageId = [time stringByReplacingOccurrencesOfString:@" " withString:@""];
    //    messageId = [messageId stringByReplacingOccurrencesOfString:@"-" withString:@""];
    //    messageId = [messageId stringByReplacingOccurrencesOfString:@":" withString:@""];
    
    
    switch (message.messageType) {
        case FYMessageTypeText:{
            message.timestamp = time;
            message.isDeleted = NO;
            message.isRecallMessage = NO;
            message.isReceivedMsg = NO;
            message.deliveryState = FYMessageDeliveryStateDelivering;
            message.messageFrom = FYMessageDirection_SEND;
        }
            break;
        case FYMessageTypeImage:{
            [messageDic setObject:@"1" forKey:@"from"];
            [messageDic setValue:@(time) forKey:@"date"];
            //            [messageDic setValue:@(messageType) forKey:@"type"];
            //            [messageDic setValue:messageId forKey:@"messageId"];
            //            [messageDic setValue:sessionId forKey:@"sessionId"];
            [messageDic setValue:headerImg1 forKey:@"headerImg"];
        }
            break;
        case FYMessageTypeVoice:{
            [messageDic setObject:@"1" forKey:@"from"];
            [messageDic setValue:@(time) forKey:@"date"];
            //            [messageDic setValue:@(messageType) forKey:@"type"];
            //            [messageDic setValue:messageId forKey:@"messageId"];
            //            [messageDic setValue:sessionId forKey:@"sessionId"];
            [messageDic setValue:headerImg1 forKey:@"headerImg"];
        }
            break;
        case FYMessageTypeMap:{
            [messageDic setObject:@"1" forKey:@"from"];
            [messageDic setValue:@(time) forKey:@"date"];
            //            [messageDic setValue:@(messageType) forKey:@"type"];
            //            [messageDic setValue:messageId forKey:@"messageId"];
            //            [messageDic setValue:sessionId forKey:@"sessionId"];
            [messageDic setValue:headerImg1 forKey:@"headerImg"];
        }
            break;
        case FYMessageTypeVideo:{
            [messageDic setObject:@"1" forKey:@"from"];
            [messageDic setValue:@(time) forKey:@"date"];
            //            [messageDic setValue:@(messageType) forKey:@"type"];
            //            [messageDic setValue:messageId forKey:@"messageId"];
            //            [messageDic setValue:sessionId forKey:@"sessionId"];
            [messageDic setValue:headerImg1 forKey:@"headerImg"];
        }
            break;
        case FYMessageTypeRedEnvelope:{
            [messageDic setValue:@(time) forKey:@"createTime"]; // 时间
            //            [messageDic setValue:dict[@"chatType"] forKey:@"chatType"];  // 1 群聊   2  p2p
            //            [messageDic setValue:@(messageType) forKey:@"msgType"];
            //            [messageDic setValue:messageId forKey:@"id"];  // 消息ID
            //            [messageDic setValue:sessionId forKey:@"groupId"];  // 群ID
        }
            break;
            
        default:
            break;
    }
    
    FYMessagelLayoutModel *layout = [SSChatDatas getMessageWithData:message];
    NSProgress *pre = [[NSProgress alloc]init];
    
    messageBlock(layout,nil,pre);
}


@end
