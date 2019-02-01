//
//  PushMessageModel.h
//  Project
//
//  Created by 罗耀生 on 2019/1/31.
//  Copyright © 2019 CDJay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WHC_ModelSqlite.h"


NS_ASSUME_NONNULL_BEGIN

@interface PushMessageModel : NSObject<NSCoding,WHC_SqliteInfo>

@property (nonatomic ,copy) NSString *userId; // 用户ID
@property (nonatomic ,copy) NSString *groupId; // 群ID,
//本地
@property (nonatomic ,copy) NSString *lastMessage; ///<最后一条消息
@property (nonatomic ,assign) int number;      // 消息条数

- (void)encodeWithCoder:(nonnull NSCoder *)aCoder;
- (nullable instancetype)initWithCoder:(nonnull NSCoder *)aDecoder;

@end

NS_ASSUME_NONNULL_END