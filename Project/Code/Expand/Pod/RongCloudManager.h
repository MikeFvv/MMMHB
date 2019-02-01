//
//  RonYun.h
//  Project
//
//  Created by mini on 2018/7/31.
//  Copyright © 2018年 CDJay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RongIMKit/RongIMKit.h>

@interface RongCloudManager : NSObject <RCIMUserInfoDataSource, RCIMGroupInfoDataSource, RCIMGroupUserInfoDataSource,
RCIMGroupMemberDataSource,RCIMReceiveMessageDelegate,RCIMConnectionStatusDelegate>//RCCallGroupMemberDataSource语音通话 RCCCContactsDataSource RCCCGroupDataSource

@property (nonatomic ,assign) BOOL isConnect;
+ (RongCloudManager *)shareInstance;
- (void)initWithMode;
- (void)setToken:(NSString *)token;

- (void)doConnect;
- (void)disConnect;
-(void)refreshUserInfo;

/**
 *  同步自己的所属群组到融云服务器,修改群组信息后都需要调用同步
 */
//- (void)syncGroups;

/**
 *  获取群中的成员列表
 */
//- (void)getAllMembersOfGroup:(NSString *)groupId result:(void (^)(NSArray *userIdList))resultBlock;

/**
 *  从服务器同步好友列表
 */
//- (void)syncFriendList:(NSString *)userId complete:(void (^)(NSMutableArray *friends))completion;
/*
 * 获取所有用户信息
 */
//- (NSArray *)getAllUserInfo:(void (^)(void))completion;
/*
 * 获取所有群组信息
 */
//- (NSArray *)getAllGroupInfo:(void (^)(void))completion;
/*
 * 获取所有好友信息
 */
//- (NSArray *)getAllFriends:(void (^)(void))completion;



@end
