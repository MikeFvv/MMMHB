//
//  SqliteManage.h
//  Project
//
//  Created by mini on 2018/8/9.
//  Copyright © 2018年 CDJay. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MessageItem;
@interface SqliteManage : NSObject

+ (SqliteManage *)shareInstance;


/**

 @param groupId 组id
 @param number 传-1表示清除数量
 @param message 最后一条信息
 */
+ (void)updateGroup:(NSString *)groupId number:(int)number lastMessage:(NSString *)message;
+ (MessageItem *)queryById:(NSString *)groupId;

+ (void)clean;


@end
