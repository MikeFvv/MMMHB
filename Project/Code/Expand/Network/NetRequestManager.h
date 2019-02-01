//
//  NetRequestManager.h
//  XM_12580
//
//  Created by mac on 12-7-9.
//  Copyright (c) 2012年 Neptune. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Public.h"

typedef enum{
    RequestType_post,
    RequestType_get,
    RequestType_put,
    RequestType_delete,
}RequestType;

#define NET_REQUEST_MANAGER [NetRequestManager sharedInstance]

typedef enum{
    ActNil,
    ActRequestUserInfo,//用户信息
    ActRequestUserInfoById,//用户信息
    ActModifyUserInfo,//修改个人信息
    ActModifyPassword,//修改密码
    ActResetPassword,//找回密码
    ActRequestVerifyCode,
    ActRegiste,
    ActRequestToken,
    ActRequestTokenBySMS,
    ActRequestIMToken,
    ActRemoveToken,//删除token
    ActRequestCommonInfo,//APP基本数据
    ActMyPlayer,//我的下线
    ActUploadImg,
    ActRequestBankList,
    ActRequestDrawRecordList,//获取提现记录
    ActDraw,//提现
    ActRequestBillList,//账单列表
    ActRequestBillTypeList,//账单类型
    ActRequestSystemNotice,//通知列表
    ActRequestShareList,//分享列表
    ActAddShareCount,//增加分享页的访问量
    ActRequestRechargeList,//充值列表
    ActRequestReportForms,//报表
    ActRequestActivityList,//查询活动列表
    ActGetReward,//领取奖励
    ActGetFirstRewardInfo,//获取首充、二充数据
}Act;

@interface RequestInfo : NSObject
@property(nonatomic,assign)RequestType requestType;
@property(nonatomic,copy)NSString *url;
@property(nonatomic,assign)Act act;
@property(nonatomic,assign)long long startTime;
@end

@interface NetRequestManager : NSObject{
    NSMutableArray *_httpManagerArray;
}
#pragma mark ---------------------------公共
+ (NetRequestManager *)sharedInstance;

//- (NSString *)getJsonStrFromData:(id)data;

//- (id)getDataFromJson:(NSString *)jsonStr;

#pragma mark ---------------------------接口
#pragma mark 手机注册
-(void)registeWithAccount:(NSString *)account
                 password:(NSString *)password
                  smsCode:(NSString *)smsCode
             referralCode:(NSString *)code
                  success:(CallbackBlock)successBlock
                     fail:(CallbackBlock)failBlock;

#pragma mark 请求验证码
-(void)requestSmsCodeWithPhone:(NSString *)phone
                       success:(CallbackBlock)successBlock
                          fail:(CallbackBlock) failBlock;

#pragma mark 重置密码（找回密码）
-(void)findPasswordWithPhone:(NSString *)phone
                     smsCode:(NSString *)smsCode
                    password:(NSString *)password
                     success:(CallbackBlock)successBlock
                        fail:(CallbackBlock)failBlock;

#pragma mark 密码请求tocken
-(void)requestTockenWithAccount:(NSString *)account
                       password:(NSString *)password
                        success:(CallbackBlock)successBlock
                           fail:(CallbackBlock)failBlock;

#pragma mark 短信验证码获取tocken
-(void)requestTockenWithPhone:(NSString *)phone
                      smsCode:(NSString *)smsCode
                      success:(CallbackBlock)successBlock
                         fail:(CallbackBlock)failBlock;

#pragma mark 请求用户信息
-(void)requestUserInfoWithSuccess:(CallbackBlock)successBlock
                            fail:(CallbackBlock)failBlock;

#pragma mark 请求用户信息2
-(void)requestUserInfoWithUserId:(NSString *)userId
                         success:(CallbackBlock)successBlock
                            fail:(CallbackBlock)failBlock;

#pragma mark 领取福利（暂不知道此接口用处及参数）
//-(void)drawBoonWithId:(NSString *)bId
//              success:(CallbackBlock)successBlock
//                 fail:(CallbackBlock)failBlock;

#pragma mark 是否签到
//-(void)isSignWithSuccess:(CallbackBlock)successBlock
//                    fail:(CallbackBlock)failBlock;

#pragma mark 签到
//-(void)signWithSuccess:(CallbackBlock)successBlock
//                  fail:(CallbackBlock)failBlock;

#pragma mark 获取银行列表
-(void)requestBankListWithSuccess:(CallbackBlock)successBlock
                             fail:(CallbackBlock)failBlock;

#pragma mark 获取提现记录
-(void)requestDrawRecordListWithSuccess:(CallbackBlock)successBlock
                                   fail:(CallbackBlock)failBlock;

#pragma mark 提现
-(void)withDrawWithAmount:(NSString *)amount//金额
                  userName:(NSString *)name//名字
                  bankName:(NSString *)backName//银行名
                   bankId:(NSString *)bankId//银行id
                   address:(NSString *)address//地址
                   uppayNO:(NSString *)uppayNO //卡号
                    remark:(NSString *)remark//备注
                   success:(CallbackBlock)successBlock
                      fail:(CallbackBlock)failBlock;

#pragma mark 编辑用户信息
-(void)editUserInfoWithUserAvatar:(NSString *)url
                         userNick:(NSString *)nickName
                           gender:(NSInteger)gender
                          success:(CallbackBlock)successBlock
                             fail:(CallbackBlock)failBlock;

#pragma mark 上传图片
-(void)upLoadImageObj:(UIImage *)image
              success:(CallbackBlock)successBlock
                 fail:(CallbackBlock)failBlock;

#pragma mark (暂不知道用处)
//-(void)requestbizId:(NSString *)bizId
//            success:(CallbackBlock)successBlock
//               fail:(CallbackBlock)failBlock;

#pragma mark 我的下线列表
-(void)requestMyPlayerWithPage:(NSInteger)page
                      pageSize:(NSInteger)pageSize
                    orderField:(NSString *)field
                           asc:(NSInteger)asc
                       success:(CallbackBlock)successBlock
                          fail:(CallbackBlock)failBlock;

#pragma mark 账单类型   线上充值 人工充值 抢包 踩雷...
-(void)requestBillTypeWithSuccess:(CallbackBlock)successBlock
                             fail:(CallbackBlock)failBlock;

#pragma mark 获取账单列表
-(void)requestBillListWithType:(NSInteger)type
                     beginTime:(NSString *)beginTime
                       endTime:(NSString *)endTime
                          page:(NSInteger)page
                      pageSize:(NSInteger)pageSize
                       success:(CallbackBlock)successBlock
                          fail:(CallbackBlock)failBlock;

#pragma mark 获取app配置
-(void)requestAppConfigWithSuccess:(CallbackBlock)successBlock
                              fail:(CallbackBlock)failBlock;

#pragma mark 获取通知列表
-(void)requestSystemNoticeWithSuccess:(CallbackBlock)successBlock
                                 fail:(CallbackBlock)failBlock;

#pragma mark 请求容云tocken
-(void)requestIMTokenWithSuccess:(CallbackBlock)successBlock
                            fail:(CallbackBlock)failBlock;

#pragma mark 请求分享列表
-(void)requestShareListWithSuccess:(CallbackBlock)successBlock
                              fail:(CallbackBlock)failBlock;

#pragma mark 增加分享页的访问量
-(void)addShareCountWithId:(NSInteger)shareId success:(CallbackBlock)successBlock
                      fail:(CallbackBlock)failBlock;

#pragma mark 充值列表
-(void)requestRechargeListWithSuccess:(CallbackBlock)successBlock
                              fail:(CallbackBlock)failBlock;

#pragma mark 报表
-(void)requestReportFormsWithUserId:(NSString *)userId beginTime:(NSString *)beginTime endTime:(NSString *)endTime success:(CallbackBlock)successBlock fail:(CallbackBlock)failBlock;

#pragma mark 删除token
-(void)removeTokenWithSuccess:(CallbackBlock)successBlock
                         fail:(CallbackBlock)failBlock;

#pragma mark 获取活动列表
-(void)requestActivityListWithUserId:(NSString *)userId success:(CallbackBlock)successBlock
                                fail:(CallbackBlock)failBlock;

#pragma mark 领取奖励
-(void)getRewardWithActivityType:(NSString *)type userId:(NSString *)userId success:(CallbackBlock)successBlock
                            fail:(CallbackBlock)failBlock;

#pragma mark 领取首充 二充奖励
-(void)getFirstRewardWithUserId:(NSString *)userId rewardType:(NSInteger)rewardType success:(CallbackBlock)successBlock
                           fail:(CallbackBlock)failBlock;
@end
