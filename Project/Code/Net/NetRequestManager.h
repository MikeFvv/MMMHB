//
//  NetDataManager.h
//  XM_12580
//
//  Created by mac on 12-7-9.
//  Copyright (c) 2012年 Neptune. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "AFHTTPSessionManager2.h"

#define NET_REQUEST_MANAGER [NetRequestManager sharedInstance]

//每个接口对应一个action
typedef enum{
    ActionNull,
    ActionLogin,
    ActionRegiste,
    ActionGetSMS,
    ActionFindPassword,
    ActionGetToken,
    ActionUpdateAvatarNickName,//更新头像及昵称
    ActionGetUserInfo,//获取用户信息
    ActionGetAppConfig,
    ActionGetIMToken,
    ActionGetRedPacketDetail,//红包详情
    ActionGrabRedPacket,//抢红包
    ActionGrabRedPacketByFree,//免死抢红包
    ActionGrabPacketByRobot,//机器人抢红包
    ActionSendRedPacket,//发红包
    ActionGetGroupDetail,
    ActionCreateGroup,
    ActionGetGroupMemberList,
    ActionJoinGroup,
    ActionGetGroupListMyJoined,//我加入的群组
    ActionGetGroupList,//所有群组
    ActionQuitGroup,//退出群组
}Action;

typedef enum{
    RequestTypeNull,
    RequestTypePost,
    RequestTypeGet,
    RequestTypePut,
    RequestTypeDel,
}RequestType;

@interface RequestInfo:NSObject{
}
@property(nonatomic,assign)RequestType requestType;
@property(nonatomic,copy)NSString *apiPath;
@end

@interface NetRequestManager : NSObject{
}
//---------------------------公共
+ (NetRequestManager *)sharedInstance;
+ (void)destroyInstance;

- (void)requestData:(id)data action:(Action)act extraData:(NSDictionary *)extraData headerData:(NSDictionary *)headerData success:(ResponseBlock)successBlock fail:(ResponseBlock)failBlock;
- (void)requestData:(id)data action:(Action)act extraData:(NSDictionary *)extraData success:(ResponseBlock)successBlock fail:(ResponseBlock)failBlock;

//---------------------------业务接口

//注册
-(void)registeWithAccount:(NSString *)account password:(NSString *)password smsCode:(NSString *)smsCode referralCode:(NSString *)referralCode success:(ResponseBlock)successBlock fail:(ResponseBlock)failBlock;

//获取短信验证码 reg login reset_passwd
-(void)requestSmsCodeWithPhone:(NSString *)phone code:(NSString *)code success:(ResponseBlock)successBlock fail:(ResponseBlock)failBlock;

//找回密码
-(void)findPasswordWithPhone:(NSString *)phone smsCode:(NSString *)smsCode password:(NSString *)password success:(ResponseBlock)successBlock fail:(ResponseBlock)failBlock;

//帐号密码获取token
-(void)requestTockenWithAccount:(NSString *)account password:(NSString *)password success:(ResponseBlock)successBlock fail:(ResponseBlock)failBlock;

//获取用户基础信息
-(void)requestUserInfoWithUserId:(NSString *)userId success:(ResponseBlock)successBlock fail:(ResponseBlock)failBlock;

//获取红包详情
-(void)requestRedPacketDetailWithId:(NSString *)redPacketId success:(ResponseBlock)successBlock fail:(ResponseBlock)failBlock;

//发红包
-(void)sendRedPacketWithCount:(NSInteger)count groupId:(NSString *)groupId money:(NSString *)money userId:(NSString *)userId type:(NSInteger)type extInfo:(NSDictionary *)extInfo success:(ResponseBlock)successBlock fail:(ResponseBlock)failBlock;

//获取组详情
-(void)requestGroupDetailWithId:(NSString *)groupId success:(ResponseBlock)successBlock fail:(ResponseBlock)failBlock;

//创建群组
-(void)createGroupWithName:(NSString *)name image:(NSString *)imagePath active:(BOOL)isActive shutUp:(BOOL)isShutUp joinMoney:(NSString *)money know:(NSString *)know rule:(NSString *)rule notice:(NSString *)notice userId:(NSString *)userId success:(ResponseBlock)successBlock fail:(ResponseBlock)failBlock;

//请求群组用户列表 page 1开始
-(void)requestGroupMemberListWithPage:(NSInteger)page pageSize:(NSInteger)pageSize orderField:(NSString *)orderField asc:(BOOL)asc groupId:(NSString *)groupId success:(ResponseBlock)successBlock fail:(ResponseBlock)failBlock;

//加入群组
-(void)joinGroupWithId:(NSString *)groupId success:(ResponseBlock)successBlock fail:(ResponseBlock)failBlock;

//退出群组
-(void)quitGroupWithId:(NSString *)groupId success:(ResponseBlock)successBlock fail:(ResponseBlock)failBlock;

//查找我加入的群组
-(void)requestGroupListMyJoinedWithPage:(NSInteger)page pageSize:(NSInteger)pageSize orderField:(NSString *)orderField asc:(BOOL)asc success:(ResponseBlock)successBlock fail:(ResponseBlock)failBlock;
//所有群组
-(void)requestGroupListWithPage:(NSInteger)page pageSize:(NSInteger)pageSize orderField:(NSString *)orderField asc:(BOOL)asc success:(ResponseBlock)successBlock fail:(ResponseBlock)failBlock;
//获取IM token
-(void)requestIMTokenWithSuccess:(ResponseBlock)successBlock fail:(ResponseBlock)failBlock;
//测试
-(void)test;
@end
