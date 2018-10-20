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
    ActionGetToken,//密码登录
    ActionGetTokenByVerifyCode,  // 验证码登陆
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
    ActionJoinGroup,
    ActionGetGroupListMyJoined,//我加入的群组
    ActionGetGroupList,//所有群组
    ActionQuitGroup,//退出群组
    ActionGetGroupMemberList,//获取群组成员列表
    ActionUserSign,//签到
    ActionIsSign,//是否已签到
    ActionDrawBoon,//领取福利
    ActionPostEditUserInfo, // 编辑用户资料
    ActionPutRecharge, // 充值
    ActionGetBankList,//获取银行列表
    ActionGetDrawRecordList,//获取以前提现时填入的信息
    ActionUploadFile,//上传文件
    ActionWithDraw,//提现
    ActionSendRedPackage, // 发红包
    ActionGrabRedPackage, // 抢红包
    ActionGetMyPlayerList,//我的玩家
    ActionGetBillList,//获取帐单明细列表
    ActionGetBillType,//获取帐单类型
}Action;

typedef enum{
    RequestTypeNull,
    RequestTypePost,
    RequestTypeGet,
    RequestTypePut,
    RequestTypeDel,
    RequestTypeUpload,
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

- (void)requestData:(id)data action:(Action)act extraData:(NSDictionary *)extraData success:(ResponseBlock)successBlock fail:(ResponseBlock)failBlock;

//---------------------------业务接口

//注册   F
-(void)registeWithAccount:(NSString *)account password:(NSString *)password smsCode:(NSString *)smsCode referralCode:(NSString *)referralCode success:(ResponseBlock)successBlock fail:(ResponseBlock)failBlock;

//获取短信验证码 reg login reset_passwd   F
-(void)requestSmsCodeWithPhone:(NSString *)phone code:(NSString *)code success:(ResponseBlock)successBlock fail:(ResponseBlock)failBlock;

//找回密码   F
-(void)findPasswordWithPhone:(NSString *)phone smsCode:(NSString *)smsCode password:(NSString *)password success:(ResponseBlock)successBlock fail:(ResponseBlock)failBlock;

//帐号密码获取token F
-(void)requestTockenWithAccount:(NSString *)account password:(NSString *)password success:(ResponseBlock)successBlock fail:(ResponseBlock)failBlock;

//获取用户基础信息 F
-(void)requestUserInfoWithUserId:(NSString *)userId success:(ResponseBlock)successBlock fail:(ResponseBlock)failBlock;


//发红包
-(void)sendRedPacketWithCount:(NSInteger)count groupId:(NSString *)groupId money:(NSString *)money userId:(NSString *)userId type:(NSInteger)type extInfo:(NSDictionary *)extInfo success:(ResponseBlock)successBlock fail:(ResponseBlock)failBlock;

//获取组详情
-(void)requestGroupDetailWithId:(NSString *)groupId success:(ResponseBlock)successBlock fail:(ResponseBlock)failBlock;

//创建群组
-(void)createGroupWithName:(NSString *)name image:(NSString *)imagePath active:(BOOL)isActive shutUp:(BOOL)isShutUp joinMoney:(NSString *)money know:(NSString *)know rule:(NSString *)rule notice:(NSString *)notice userId:(NSString *)userId success:(ResponseBlock)successBlock fail:(ResponseBlock)failBlock;

//请求群组用户列表 page 1开始 F
-(void)requestGroupMemberListWithPage:(NSInteger)page pageSize:(NSInteger)pageSize orderField:(NSString *)orderField asc:(BOOL)asc groupId:(NSString *)groupId success:(ResponseBlock)successBlock fail:(ResponseBlock)failBlock;

//加入群组 F
-(void)joinGroupWithId:(NSString *)groupId success:(ResponseBlock)successBlock fail:(ResponseBlock)failBlock;

//退出群组 F
-(void)quitGroupWithId:(NSString *)groupId success:(ResponseBlock)successBlock fail:(ResponseBlock)failBlock;

//查找我加入的群组
-(void)requestGroupListMyJoinedWithPage:(NSInteger)page pageSize:(NSInteger)pageSize orderField:(NSString *)orderField asc:(BOOL)asc success:(ResponseBlock)successBlock fail:(ResponseBlock)failBlock;

//所有群组
-(void)requestGroupListWithPage:(NSInteger)page pageSize:(NSInteger)pageSize orderField:(NSString *)orderField asc:(BOOL)asc success:(ResponseBlock)successBlock fail:(ResponseBlock)failBlock;

//获取IM token F
-(void)requestIMTokenWithSuccess:(ResponseBlock)successBlock fail:(ResponseBlock)failBlock;

//领取福利
-(void)drawBoonWithId:(NSString *)boonId success:(ResponseBlock)successBlock fail:(ResponseBlock)failBlock;

//是否签到
-(void)isSignWithSuccess:(ResponseBlock)successBlock fail:(ResponseBlock)failBlock;

//签到 F
-(void)signWithSuccess:(ResponseBlock)successBlock fail:(ResponseBlock)failBlock;

//获取银行列表  F
-(void)requestBankListWithSuccess:(ResponseBlock)successBlock fail:(ResponseBlock)failBlock;

//获取以前提现时填入的信息  F
-(void)requestDrawRecordListWithSuccess:(ResponseBlock)successBlock fail:(ResponseBlock)failBlock;

//提现 F
-(void)widthDrawWithAmount:(NSString *)amount userName:(NSString *)userName bankName:(NSString *)bankName address:(NSString *)address uppayNO:(NSString *)uppayNo remark:(NSString *)remark success:(ResponseBlock)successBlock fail:(ResponseBlock)failBlock;

// 充值  F
-(void)rechargeWithUserId:(NSString *)userId type:(NSString *)type money:(NSString *)money success:(ResponseBlock)successBlock fail:(ResponseBlock)failBlock;
// 修改用户资料  F
-(void)editUserInfoWithUserAvatar:(NSString *)userAvatar userNick:(NSString *)userNick gender:(NSInteger)gender success:(ResponseBlock)successBlock fail:(ResponseBlock)failBlock;
// 上传图片   F
-(void)upLoadImageObj:(UIImage *)image success:(ResponseBlock)successBlock fail:(ResponseBlock)failBlock;
// 发红包   F
-(void)sendRedPackageWithGroupId:(NSString *)groupId userId:(NSString *)userId type:(NSInteger)type money:(NSString *)money count:(NSInteger)count ext:(NSDictionary *)ext success:(ResponseBlock)successBlock fail:(ResponseBlock)failBlock;
// 抢红包   F
-(void)grabRedPackageWithRedPackageId:(NSString *)packetId type:(NSInteger)type success:(ResponseBlock)successBlock fail:(ResponseBlock)failBlock;

// 获取红包详情 F
-(void)requestRedPacketDetailWithId:(NSString *)redPacketId success:(ResponseBlock)successBlock fail:(ResponseBlock)failBlock;

// 验证码登录请求接口
-(void)requestTockenWithPhoneNum:(NSString *)phoneNum verCode:(NSString *)verCode success:(ResponseBlock)successBlock fail:(ResponseBlock)failBlock;
    

//获取组成员信息 F
-(void)requestGroupMemberListWithGroupId:(NSString *)groupId page:(NSInteger)page pageSize:(NSInteger)pageSize orderField:(NSString *)orderField asc:(BOOL)asc success:(ResponseBlock)successBlock fail:(ResponseBlock)failBlock;

//获取我的玩家  F
-(void)requestMyPlayerWithPage:(NSInteger)page pageSize:(NSInteger)pageSize orderField:(NSString *)orderField asc:(BOOL)asc success:(ResponseBlock)successBlock fail:(ResponseBlock)failBlock;

//获取帐单类型列表 F
-(void)requestBillTypeWithSuccess:(ResponseBlock)successBlock fail:(ResponseBlock)failBlock;

//获取帐单明细列表  F type=999表示全部
-(void)requestBillListWithType:(NSInteger)type beginTime:(NSInteger)beginTime endTime:(NSInteger)endTime page:(NSInteger)page pageSize:(NSInteger)pageSize orderField:(NSString *)orderField asc:(BOOL)asc success:(ResponseBlock)successBlock fail:(ResponseBlock)failBlock;

//app通用配置
-(void)requestAppConfigWithSuccess:(ResponseBlock)successBlock fail:(ResponseBlock)failBlock;



//测试
-(void)test;
@end
