//
//  ChatViewController.h
//  Project
//
//  Created by mini on 2018/8/1.
//  Copyright © 2018年 CDJay. All rights reserved.
//

#import <RongIMKit/RongIMKit.h>
@class MessageItem;

@interface ChatViewController : RCConversationViewController


+ (ChatViewController *)groupChatWithObj:(MessageItem *)obj;

+ (ChatViewController *)currentChat;

+ (void)sendCustomMessage:(id)message;

@end
