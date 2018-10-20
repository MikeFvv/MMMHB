//
//  MessageItem.h
//  Project
//
//  Created by mini on 2018/8/1.
//  Copyright © 2018年 CDJay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WHC_ModelSqlite.h"

@interface MessageItem : NSObject<NSCoding,WHC_SqliteInfo>

@property (nonatomic ,assign) NSInteger dateline; ///<DEFAULT '0',
@property (nonatomic ,copy) NSString *ewm; ///<DEFAULT NULL COMMENT '群主二维码',
@property (nonatomic ,copy) NSString *groupId; ///<NOT NULL AUTO_INCREMENT COMMENT '聊天组表',
@property (nonatomic ,copy) NSString *groupName; ///<DEFAULT '' COMMENT '群组 Id 对应的名称'
@property (nonatomic ,copy) NSString *img; ///<DEFAULT NULL COMMENT '群图片',
@property (nonatomic ,copy) NSString *joinMoney;///<NOT NULL DEFAULT '0.00' COMMENT '进群最少金额',
@property (nonatomic ,copy) NSString *know;///<DEFAULT NULL COMMENT '群须知',


@property (nonatomic ,copy) NSString *maxMoney;///<NOT NULL DEFAULT '100000.00' COMMENT '最大发包金额',
@property (nonatomic ,copy) NSString *minMoney;///<NOT NULL DEFAULT '0.00' COMMENT '最小发包金额',
@property (nonatomic ,copy) NSString *count;
@property (nonatomic ,copy) NSString *handicap; //赔率
@property (nonatomic ,copy) NSString *ruleBombId;
@property (nonatomic ,copy) NSString *name;


@property (nonatomic ,copy) NSString *notice;///<DEFAULT NULL COMMENT '群公告',
@property (nonatomic ,copy) NSString *rule;///<DEFAULT '' COMMENT '群规则',
@property (nonatomic ,assign) NSInteger status;///<DEFAULT '1' COMMENT '房间状态：0-关闭，1-正常',
@property (nonatomic ,assign) NSInteger type;///<DEFAULT '0' COMMENT '群类型(0-正常，1-扫雷，2-牛牛30台面，3-牛牛100台面)',

//本地
@property (nonatomic ,copy) NSString *lastMessage;///<最后一条消息
@property (nonatomic ,copy) NSString *localImg;
@property (nonatomic ,assign) int number;
@property (nonatomic ,assign) NSInteger localType;///<1 我加入的群
@property (nonatomic ,copy) NSString *path;
@end
