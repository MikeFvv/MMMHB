//
//  NetRequestManager.m
//  XM_12580
//
//  Created by mac on 12-7-9.
//  Copyright (c) 2012年 Neptune. All rights reserved.
//

#import "NetRequestManager.h"
#import "NetResponseManager.h"
#import "AFNetworking.h"
#import "AFHTTPSessionManager2.h"
#import "GTMBase64.h"
#import "NSData+AES.h"
#import "FunctionManager.h"

@implementation RequestInfo
@end

@implementation NetRequestManager

+ (NetRequestManager *)sharedInstance{
    static dispatch_once_t onceNetReq;
    static NetRequestManager *instance = nil;
    dispatch_once(&onceNetReq, ^{
        if(instance == nil)
            instance = [[NetRequestManager alloc] init];
    });
    return instance;
}

-(id)init{
    self=[super init];
    if (self){
        _httpManagerArray = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void)dealloc{
}

#pragma mark    - 公共部分

-(void)requestWithData:(NSDictionary *)dict requestInfo:(RequestInfo *)requestInfo success:(CallbackBlock)successBlock fail:(CallbackBlock)failBlock{
    NSString *auth = nil;
    if(requestInfo.act == ActRequestToken || requestInfo.act == ActRegiste || requestInfo.act == ActResetPassword|| requestInfo.act == ActRequestVerifyCode || requestInfo.act == ActRequestTokenBySMS)
        auth = APP_MODEL.authKey;
    else{
        auth = APP_MODEL.user.fullToken;
    }
    if(requestInfo.act != ActRequestCommonInfo){
        if(auth == nil){
            NSLog(@"auth 为空");
            if(failBlock)
                failBlock(@"系统错误，请退出重新登录");
            return;
        }
    }
    requestInfo.startTime = [[NSDate date] timeIntervalSince1970];
    requestInfo.url = [requestInfo.url stringByReplacingOccurrencesOfString:@" " withString:@""];
    if(dict)
        NSLog(@"================= 接口地址:%@ ===参数:%@",requestInfo.url,[dict mj_JSONString]);
    else
        NSLog(@"================= 接口地址:%@ ===参数:nil",requestInfo.url);

    AFHTTPSessionManager2 *httpSessionManager = [self createHttpSessionManager];
    httpSessionManager.successBlock = successBlock;
    httpSessionManager.failBlock = failBlock;
    httpSessionManager.act = requestInfo.act;
    [httpSessionManager.requestSerializer setValue:auth forHTTPHeaderField:@"Authorization"];
    
    WEAK_OBJ(weakManager, httpSessionManager);
    if(requestInfo.requestType == RequestType_post){
        [httpSessionManager POST:requestInfo.url parameters:dict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [NET_RESPONSE_MANAGER responseWithHttpManager:weakManager responseData:responseObject];
            [weakManager clear];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [NET_RESPONSE_MANAGER responseWithHttpManager:weakManager responseData:error];
            [weakManager clear];
        }];
    }else if(requestInfo.requestType == RequestType_get){
        [httpSessionManager GET:requestInfo.url parameters:dict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [NET_RESPONSE_MANAGER responseWithHttpManager:weakManager responseData:responseObject];
            [weakManager clear];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [NET_RESPONSE_MANAGER responseWithHttpManager:weakManager responseData:error];
            [weakManager clear];
        }];
    }
}

-(AFHTTPSessionManager2 *)createHttpSessionManager{
    for (AFHTTPSessionManager2 *manager in _httpManagerArray) {
        if(manager.act == ActNil)
            return manager;
    }
    AFHTTPSessionManager2 *manager = [AFHTTPSessionManager2 manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer.timeoutInterval = 30;
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/octet-stream",@"text/html",@"text/json",@"application/json",@"text/javascript",@"image/jpeg",@"image/png",@"text/plain", nil];
    [_httpManagerArray addObject:manager];
    
    NSString *iosVersion = [FUNCTION_MANAGER getIosVersion];
    NSString *model = [FUNCTION_MANAGER getDeviceModel];
    NSString *appVersion = [FUNCTION_MANAGER getApplicationVersion];
    if(iosVersion)
        [manager.requestSerializer setValue:iosVersion forHTTPHeaderField:@"systemVersion"];
    if(model)
        [manager.requestSerializer setValue:model forHTTPHeaderField:@"deviceModel"];
    if(appVersion)
        [manager.requestSerializer setValue:appVersion forHTTPHeaderField:@"appVersion"];
    
    return manager;
}

#pragma mark -
#pragma mark 接口部分
-(NSMutableDictionary *)createDicWithHead{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    return dic;
}

#pragma mark 密码请求tocken
-(void)requestTockenWithAccount:(NSString *)account
                       password:(NSString *)password
                        success:(CallbackBlock)successBlock
                           fail:(CallbackBlock)failBlock{
    RequestInfo *info = [self requestInfoWithAct:ActRequestToken];
    NSString *key = @"1234567887654321";
    NSData *data = [password dataUsingEncoding:NSUTF8StringEncoding];
    data = [data AES128EncryptWithKey:key gIv:key];
    data = [GTMBase64 encodeData:data];
    NSString *s = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    s = [FUNCTION_MANAGER encodedWithString:s];
    NSString *url = [NSString stringWithFormat:@"%@?username=%@&password=%@&randomStr=82701535096009570&code=5app&grant_type=password&scope=server",info.url,account,s];
    info.url = url;
    [self requestWithData:nil requestInfo:info success:successBlock fail:failBlock];
}

#pragma mark 短信验证码获取tocken
-(void)requestTockenWithPhone:(NSString *)phone
                      smsCode:(NSString *)smsCode
                      success:(CallbackBlock)successBlock
                         fail:(CallbackBlock)failBlock{
    RequestInfo *info = [self requestInfoWithAct:ActRequestTokenBySMS];
    NSString *par = [NSString stringWithFormat:@"mobile=%@&code=%@&grant_type=mobile&scope=server",phone,smsCode];
    NSString *url = [NSString stringWithFormat:@"%@?%@",info.url,par];
    info.url = url;
    [self requestWithData:nil requestInfo:info success:successBlock fail:failBlock];
}

#pragma mark 重置密码（找回密码）
-(void)findPasswordWithPhone:(NSString *)phone
                     smsCode:(NSString *)smsCode
                    password:(NSString *)password
                     success:(CallbackBlock)successBlock
                        fail:(CallbackBlock)failBlock{
    RequestInfo *info = [self requestInfoWithAct:ActResetPassword];
    NSString *url = [NSString stringWithFormat:@"%@?mobile=%@&code=%@&password=%@",info.url,phone,smsCode,password];
    info.url = url;
    [self requestWithData:nil requestInfo:info success:successBlock fail:failBlock];
}

#pragma mark 手机注册
-(void)registeWithAccount:(NSString *)account
                 password:(NSString *)password
                  smsCode:(NSString *)smsCode
             referralCode:(NSString *)code
                  success:(CallbackBlock)successBlock
                     fail:(CallbackBlock)failBlock{
    RequestInfo *info = [self requestInfoWithAct:ActRegiste];
    NSString *url = [NSString stringWithFormat:@"%@?mobile=%@&code=%@",info.url,account,smsCode];
    info.url = url;
    NSMutableDictionary *bodyDic = [self createDicWithHead];
    [bodyDic setObject:password forKey:@"passwd"];
    if(code)
        [bodyDic setObject:code forKey:@"referralCode"];
    [self requestWithData:bodyDic requestInfo:info success:successBlock fail:failBlock];
}

#pragma mark 请求用户信息
-(void)requestUserInfoWithSuccess:(CallbackBlock)successBlock
                            fail:(CallbackBlock)failBlock{
    RequestInfo *info = [self requestInfoWithAct:ActRequestUserInfo];
    [self requestWithData:nil requestInfo:info success:successBlock fail:failBlock];
}

#pragma mark 请求用户信息2
-(void)requestUserInfoWithUserId:(NSString *)userId
                         success:(CallbackBlock)successBlock
                            fail:(CallbackBlock)failBlock{
    RequestInfo *info = [self requestInfoWithAct:ActRequestUserInfoById];
    [self requestWithData:nil requestInfo:info success:successBlock fail:failBlock];
}
#pragma mark 请求验证码
-(void)requestSmsCodeWithPhone:(NSString *)phone
                       success:(CallbackBlock)successBlock
                          fail:(CallbackBlock) failBlock{
    RequestInfo *info = [self requestInfoWithAct:ActRequestVerifyCode];
    NSString *url = [NSString stringWithFormat:@"%@/%@/reg",info.url,phone];
    info.url = url;
    [self requestWithData:nil requestInfo:info success:successBlock fail:failBlock];
}

#pragma mark 获取银行列表
-(void)requestBankListWithSuccess:(CallbackBlock)successBlock
                             fail:(CallbackBlock)failBlock{
    RequestInfo *info = [self requestInfoWithAct:ActRequestBankList];
    [self requestWithData:nil requestInfo:info success:successBlock fail:failBlock];
}

#pragma mark 获取提现记录
-(void)requestDrawRecordListWithSuccess:(CallbackBlock)successBlock
                                   fail:(CallbackBlock)failBlock{
    RequestInfo *info = [self requestInfoWithAct:ActRequestDrawRecordList];
    [self requestWithData:nil requestInfo:info success:successBlock fail:failBlock];
}

-(void)requestDrawRecordListWithPage:(NSInteger)page success:(CallbackBlock)successBlock
                                fail:(CallbackBlock)failBlock{
    RequestInfo *info = [self requestInfoWithAct:ActRequestWithdrawHistory];
    NSString *url = [NSString stringWithFormat:@"%@?page=%d&limit=50&orderByField=operator_time&isAsc=0",info.url,page];
    info.url = url;
    [self requestWithData:nil requestInfo:info success:successBlock fail:failBlock];
}

#pragma mark 提现
-(void)withDrawWithAmount:(NSString *)amount//金额
                 userName:(NSString *)name//名字
                 bankName:(NSString *)backName//银行名
                   bankId:(NSString *)bankId//银行id
                  address:(NSString *)address//地址
                  uppayNO:(NSString *)uppayNO //卡号
                   remark:(NSString *)remark//备注
                  success:(CallbackBlock)successBlock
                     fail:(CallbackBlock)failBlock{
    RequestInfo *info = [self requestInfoWithAct:ActDraw];
    NSMutableDictionary *bodyDic = [self createDicWithHead];
    [bodyDic setObject:amount forKey:@"amount"];
    //[bodyDic setObject:bankId forKey:@"bankId"];
    [bodyDic setObject:name forKey:@"uppPayName"];
    [bodyDic setObject:backName forKey:@"uppayBank"];
    [bodyDic setObject:address forKey:@"uppayAddress"];
    [bodyDic setObject:uppayNO forKey:@"uppayNo"];
    [bodyDic setObject:remark forKey:@"remark"];
    [self requestWithData:bodyDic requestInfo:info success:successBlock fail:failBlock];
}

-(void)withDrawWithAmount:(NSString *)amount//金额
                   bankId:(NSString *)bankId//银行id
                  success:(CallbackBlock)successBlock
                     fail:(CallbackBlock)failBlock{
    RequestInfo *info = [self requestInfoWithAct:ActDraw];
    NSMutableDictionary *bodyDic = [self createDicWithHead];
    [bodyDic setObject:amount forKey:@"amount"];
    [bodyDic setObject:bankId forKey:@"userPaymentId"];
    [bodyDic setObject:@"无" forKey:@"remark"];
    [self requestWithData:bodyDic requestInfo:info success:successBlock fail:failBlock];
}

#pragma mark 获取账单列表
-(void)requestBillListWithName:(NSString *)billName
                   categoryStr:(NSString *)categoryStr
                     beginTime:(NSString *)beginTime
                       endTime:(NSString *)endTime
                          page:(NSInteger)page
                      pageSize:(NSInteger)pageSize
                       success:(CallbackBlock)successBlock
                          fail:(CallbackBlock)failBlock{
    RequestInfo *info = [self requestInfoWithAct:ActRequestBillList];
    NSMutableString *url = [[NSMutableString alloc] initWithFormat:@"%@?start_time=%@&end_time=%@&page=%ld&orderByField=id&isAsc=0&limit=%ld",info.url,beginTime,endTime,(long)page,(long)pageSize];
    if(billName.length > 0)
        [url appendFormat:@"&billt_name=%@",billName];
    if(categoryStr.length > 0)
        [url appendFormat:@"&category=%@",categoryStr];
    info.url = url;
    [self requestWithData:nil requestInfo:info success:successBlock fail:failBlock];
}

#pragma mark 账单类型   线上充值 人工充值 抢包 踩雷...
-(void)requestBillTypeWithType:(NSString *)type success:(CallbackBlock)successBlock
                             fail:(CallbackBlock)failBlock{
    RequestInfo *info = [self requestInfoWithAct:ActRequestBillTypeList];
    NSString *url = [NSString stringWithFormat:@"%@?category=%@",info.url,type];
    info.url = url;
    [self requestWithData:nil requestInfo:info success:successBlock fail:failBlock];
}

#pragma mark 上传图片
-(void)upLoadImageObj:(UIImage *)image
              success:(CallbackBlock)successBlock
                 fail:(CallbackBlock)failBlock{
    RequestInfo *requestInfo = [self requestInfoWithAct:ActUploadImg];
    NSData *data = UIImagePNGRepresentation(image);
    
    NSString *auth = APP_MODEL.user.fullToken;
    if(auth == nil)
        return;
//    NSLog(@"%@",requestInfo.url);
    AFHTTPSessionManager2 *httpSessionManager = [self createHttpSessionManager];
    httpSessionManager.successBlock = successBlock;
    httpSessionManager.failBlock = failBlock;
    httpSessionManager.act = requestInfo.act;
    [httpSessionManager.requestSerializer setValue:auth forHTTPHeaderField:@"Authorization"];
    
    WEAK_OBJ(weakManager, httpSessionManager);
//    [httpSessionManager POST:requestInfo.url parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
//        [formData appendPartWithFileData:data name:@"file" fileName:@"file.png" mimeType:@"image/png"];
//    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        [NET_RESPONSE_MANAGER responseWithHttpManager:weakManager responseData:responseObject];
//        [weakManager clear];
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        [NET_RESPONSE_MANAGER responseWithHttpManager:weakManager responseData:error];
//        [weakManager clear];
//    }];
    
    [httpSessionManager POST:requestInfo.url parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFileData:data name:@"file" fileName:@"file.png" mimeType:@"image/png"];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [NET_RESPONSE_MANAGER responseWithHttpManager:weakManager responseData:responseObject];
        [weakManager clear];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [NET_RESPONSE_MANAGER responseWithHttpManager:weakManager responseData:error];
        [weakManager clear];
    }];
}

#pragma mark 编辑用户信息
-(void)editUserInfoWithUserAvatar:(NSString *)url
                         userNick:(NSString *)nickName
                           gender:(NSInteger)gender
                          success:(CallbackBlock)successBlock
                             fail:(CallbackBlock)failBlock{
    RequestInfo *info = [self requestInfoWithAct:ActModifyUserInfo];
    NSMutableDictionary *bodyDic = [self createDicWithHead];
    [bodyDic setObject:url forKey:@"userAvatar"];
    [bodyDic setObject:nickName forKey:@"userNick"];
    [bodyDic setObject:INT_TO_STR(gender) forKey:@"userGender"];
    [self requestWithData:bodyDic requestInfo:info success:successBlock fail:failBlock];
}

#pragma mark 获取app配置
-(void)requestAppConfigWithSuccess:(CallbackBlock)successBlock
                              fail:(CallbackBlock)failBlock{
    RequestInfo *info = [self requestInfoWithAct:ActRequestCommonInfo];
    [self requestWithData:nil requestInfo:info success:successBlock fail:failBlock];
}

#pragma mark 我的下线列表
-(void)requestMyPlayerWithPage:(NSInteger)page
                      pageSize:(NSInteger)pageSize
                    userString:(NSString *)userString
                          type:(NSInteger)type
                       success:(CallbackBlock)successBlock
                          fail:(CallbackBlock)failBlock{
    RequestInfo *info = [self requestInfoWithAct:ActMyPlayer];
    NSMutableString *s = [[NSMutableString alloc] initWithFormat:@"%@?page=%ld&limit=%ld&orderByField=id&isAsc=0",info.url,page,pageSize];
    if(userString.length > 0)
        [s appendFormat:@"&userId=%@",userString];
    if(type >= 0)
        [s appendFormat:@"&type=%zd",type];
    info.url = s;
    [self requestWithData:nil requestInfo:info success:successBlock fail:failBlock];
}

#pragma mark 获取通知列表
-(void)requestSystemNoticeWithSuccess:(CallbackBlock)successBlock
                                 fail:(CallbackBlock)failBlock{
    RequestInfo *info = [self requestInfoWithAct:ActRequestSystemNotice];
    NSString *url = [NSString stringWithFormat:@"%@?page=1&limit=50&orderByField=id&isAsc=1",info.url];
    info.url = url;
    [self requestWithData:nil requestInfo:info success:successBlock fail:failBlock];
}

#pragma mark 请求容云tocken
-(void)requestIMTokenWithSuccess:(CallbackBlock)successBlock
                            fail:(CallbackBlock)failBlock{
    RequestInfo *info = [self requestInfoWithAct:ActRequestIMToken];
    [self requestWithData:nil requestInfo:info success:successBlock fail:failBlock];
}

#pragma mark 请求分享列表
-(void)requestShareListWithSuccess:(CallbackBlock)successBlock
                              fail:(CallbackBlock)failBlock{
    RequestInfo *info = [self requestInfoWithAct:ActRequestShareList];
    NSString *url = [NSString stringWithFormat:@"%@?page=1&limit=50&orderByField=id&isAsc=1",info.url];
    info.url = url;
    [self requestWithData:nil requestInfo:info success:successBlock fail:failBlock];
}

#pragma mark 增加分享页的访问量
-(void)addShareCountWithId:(NSInteger)shareId success:(CallbackBlock)successBlock
                      fail:(CallbackBlock)failBlock{
    RequestInfo *info = [self requestInfoWithAct:ActAddShareCount];
    NSString *url = [NSString stringWithFormat:@"%@/%ld",info.url,(long)shareId];
    info.url = url;
    [self requestWithData:nil requestInfo:info success:successBlock fail:failBlock];
}

#pragma mark 充值列表
-(void)requestRechargeListWithSuccess:(CallbackBlock)successBlock
                                 fail:(CallbackBlock)failBlock{
    RequestInfo *info = [self requestInfoWithAct:ActRequestRechargeList];
    [self requestWithData:nil requestInfo:info success:successBlock fail:failBlock];
}

#pragma mark 报表
-(void)requestReportFormsWithUserId:(NSString *)userId beginTime:(NSString *)beginTime endTime:(NSString *)endTime success:(CallbackBlock)successBlock fail:(CallbackBlock)failBlock{
    RequestInfo *info = [self requestInfoWithAct:ActRequestReportForms];
    NSMutableDictionary *bodyDic = [self createDicWithHead];
    [bodyDic setObject:beginTime forKey:@"startTime"];
    [bodyDic setObject:endTime forKey:@"endTime"];
    [bodyDic setObject:userId forKey:@"loginUserId"];
    //[bodyDic setObject:APP_MODEL.user.userId forKey:@"loginUserId"];
    [self requestWithData:bodyDic requestInfo:info success:successBlock fail:failBlock];
}

#pragma mark 删除token
-(void)removeTokenWithSuccess:(CallbackBlock)successBlock
                         fail:(CallbackBlock)failBlock{
    RequestInfo *info = [self requestInfoWithAct:ActRemoveToken];
    NSString *url = [NSString stringWithFormat:@"%@?accesstoken=%@",info.url,APP_MODEL.user.token];
    info.url = url;
    [self requestWithData:nil requestInfo:info success:successBlock fail:failBlock];
}

#pragma mark 获取活动列表
-(void)requestActivityListWithUserId:(NSString *)userId success:(CallbackBlock)successBlock
                               fail:(CallbackBlock)failBlock{
    RequestInfo *info = [self requestInfoWithAct:ActRequestActivityList];
    NSMutableDictionary *bodyDic = [self createDicWithHead];
    [bodyDic setObject:userId forKey:@"userId"];
    [self requestWithData:bodyDic requestInfo:info success:successBlock fail:failBlock];
}

#pragma mark 领取奖励
-(void)getRewardWithActivityType:(NSString *)type userId:(NSString *)userId success:(CallbackBlock)successBlock
                            fail:(CallbackBlock)failBlock{
    RequestInfo *info = [self requestInfoWithAct:ActGetReward];
    NSMutableDictionary *bodyDic = [self createDicWithHead];
    [bodyDic setObject:type forKey:@"promotType"];
    [bodyDic setObject:userId forKey:@"userId"];
    [self requestWithData:bodyDic requestInfo:info success:successBlock fail:failBlock];
}

#pragma mark 领取首充 二充奖励
-(void)getFirstRewardWithUserId:(NSString *)userId rewardType:(NSInteger)rewardType success:(CallbackBlock)successBlock
                            fail:(CallbackBlock)failBlock{
    RequestInfo *info = [self requestInfoWithAct:ActGetFirstRewardInfo];
    NSMutableDictionary *bodyDic = [self createDicWithHead];
    [bodyDic setObject:INT_TO_STR(rewardType) forKey:@"promotType"];
    [bodyDic setObject:userId forKey:@"userId"];
    [self requestWithData:bodyDic requestInfo:info success:successBlock fail:failBlock];
}

#pragma mark 申请成为代理
-(void)askForToBeAgentWithSuccess:(CallbackBlock)successBlock
                             fail:(CallbackBlock)failBlock{
    RequestInfo *info = [self requestInfoWithAct:ActToBeAgent];
    [self requestWithData:nil requestInfo:info success:successBlock fail:failBlock];
}

#pragma mark 查询可抽奖列表
-(void)getLotteryListWithSuccess:(CallbackBlock)successBlock
                            fail:(CallbackBlock)failBlock{
    RequestInfo *info = [self requestInfoWithAct:ActGetLotteryList];
    [self requestWithData:nil requestInfo:info success:successBlock fail:failBlock];
}

#pragma mark 查询可抽奖具体信息
-(void)getLotteryDetailWithId:(NSInteger)lId success:(CallbackBlock)successBlock
                         fail:(CallbackBlock)failBlock{
    RequestInfo *info = [self requestInfoWithAct:ActGetLotterys];
    NSString *url = [NSString stringWithFormat:@"%@/%ld",info.url,(long)lId];
    info.url = url;
    [self requestWithData:nil requestInfo:info success:successBlock fail:failBlock];
}

#pragma mark 抽奖
-(void)lotteryWithId:(NSInteger)lId success:(CallbackBlock)successBlock
                fail:(CallbackBlock)failBlock{
    RequestInfo *info = [self requestInfoWithAct:ActLottery];
    NSString *url = [NSString stringWithFormat:@"%@/%ld",info.url,(long)lId];
    info.url = url;
    [self requestWithData:nil requestInfo:info success:successBlock fail:failBlock];
}

#pragma mark 添加银行卡
-(void)addBankCardWithUserName:(NSString *)userName cardNO:(NSString *)cardNO bankId:(NSString *)bankId address:(NSString *)address success:(CallbackBlock)successBlock fail:(CallbackBlock)failBlock{
    RequestInfo *info = [self requestInfoWithAct:ActAddBankCard];
    NSMutableDictionary *bodyDic = [self createDicWithHead];
    [bodyDic setObject:userName forKey:@"user"];
    [bodyDic setObject:bankId forKey:@"upaytId"];
    [bodyDic setObject:cardNO forKey:@"upayNo"];
    [bodyDic setObject:address forKey:@"bankRegion"];
    [self requestWithData:bodyDic requestInfo:info success:successBlock fail:failBlock];
}

#pragma mark 我的银行卡
-(void)getMyBankCardListWithSuccess:(CallbackBlock)successBlock fail:(CallbackBlock)failBlock{
    RequestInfo *info = [self requestInfoWithAct:ActRequestMyBankList];
    [self requestWithData:nil requestInfo:info success:successBlock fail:failBlock];
}

#pragma mark 获取最后一次的提现信息
-(void)getLastWithdrawInfoWithSuccess:(CallbackBlock)successBlock fail:(CallbackBlock)failBlock{
    RequestInfo *info = [self requestInfoWithAct:ActRequestLastWithdrawInfo];
    [self requestWithData:nil requestInfo:info success:successBlock fail:failBlock];
}

#pragma mark 获取首先支付通道列表
-(void)requestFirstRechargeListWithSuccess:(CallbackBlock)successBlock fail:(CallbackBlock)failBlock{
    RequestInfo *info = [self requestInfoWithAct:ActRequestRechargeListFirst];
    [self requestWithData:nil requestInfo:info success:successBlock fail:failBlock];
}

#pragma mark 获取所有支付通道列表
-(void)requestAllRechargeListWithSuccess:(CallbackBlock)successBlock fail:(CallbackBlock)failBlock{
    RequestInfo *info = [self requestInfoWithAct:ActRequestRechargeListAll];
    [self requestWithData:nil requestInfo:info success:successBlock fail:failBlock];
}

#pragma mark 提交支付资料
-(void)submitRechargeInfoWithBankId:(NSString *)bankId
                           bankName:(NSString *)bankName
                             bankNo:(NSString *)bankNo
                                tId:(NSString *)tId
                              money:(NSString *)money
                               name:(NSString *)name
                            orderId:(NSString *)orderId
                               type:(NSInteger)type
                           typeCode:(NSInteger)typeCode
                             userId:(NSString *)userId
                            success:(CallbackBlock)successBlock
                               fail:(CallbackBlock)failBlock{
    RequestInfo *info = [self requestInfoWithAct:ActSubmitRechargeInfo];
    NSMutableDictionary *bodyDic = [self createDicWithHead];
    if(bankId)
        [bodyDic setObject:bankId forKey:@"bankId"];
    if(bankName)
        [bodyDic setObject:bankName forKey:@"bankName"];
    [bodyDic setObject:bankNo forKey:@"bankNo"];
    [bodyDic setObject:tId forKey:@"id"];
    [bodyDic setObject:money forKey:@"money"];
    [bodyDic setObject:name forKey:@"name"];
//    [bodyDic setObject:orderId forKey:@"orderId"];
    [bodyDic setObject:INT_TO_STR(type) forKey:@"type"];
    [bodyDic setObject:userId forKey:@"userId"];
    [bodyDic setObject:INT_TO_STR(typeCode) forKey:@"typeCode"];


    [self requestWithData:bodyDic requestInfo:info success:successBlock fail:failBlock];
}

#pragma mark 重新下订单
-(void)reOrderRechargeInfoWithId:(NSString *)orderId success:(CallbackBlock)successBlock fail:(CallbackBlock)failBlock{
    RequestInfo *info = [self requestInfoWithAct:ActReOrderRecharge];
    NSMutableDictionary *bodyDic = [self createDicWithHead];
    [bodyDic setObject:orderId forKey:@"orderId"];
    [self requestWithData:bodyDic requestInfo:info success:successBlock fail:failBlock];
}

#pragma mark 提交订单
-(void)submitOrderRechargeInfoWithId:(NSString *)orderId success:(CallbackBlock)successBlock fail:(CallbackBlock)failBlock{
    RequestInfo *info = [self requestInfoWithAct:ActOrderRecharge];
    NSMutableDictionary *bodyDic = [self createDicWithHead];
    [bodyDic setObject:orderId forKey:@"orderId"];
    [self requestWithData:bodyDic requestInfo:info success:successBlock fail:failBlock];
}

#pragma mark 获取分享url
-(void)getShareUrlWithCode:(NSString *)code success:(CallbackBlock)successBlock fail:(CallbackBlock)failBlock{
    RequestInfo *info = [self requestInfoWithAct:ActRequestShareUrl];
    NSString *url = [NSString stringWithFormat:@"%@/%@",info.url,code];
    info.url = url;
    [self requestWithData:nil requestInfo:info success:successBlock fail:failBlock];
}

#pragma mark 获取新手引导图片列表
-(void)getGuideImageListWithSuccess:(CallbackBlock)successBlock fail:(CallbackBlock)failBlock{
    RequestInfo *info = [self requestInfoWithAct:ActRequestGuideImageList];
    NSMutableDictionary *bodyDic = [self createDicWithHead];
    [bodyDic setObject:@"6" forKey:@"helpType"];
    [self requestWithData:bodyDic requestInfo:info success:successBlock fail:failBlock];
}

#pragma mark 活动奖励列表
-(void)getActivityListWithSuccess:(CallbackBlock)successBlock fail:(CallbackBlock)failBlock{
    RequestInfo *info = [self requestInfoWithAct:ActRequestActivityList2];
    NSMutableDictionary *bodyDic = [self createDicWithHead];
    [bodyDic setObject:@"page" forKey:@"1"];
    [self requestWithData:bodyDic requestInfo:info success:successBlock fail:failBlock];
}

#pragma mark 获取抢包活动阶段
-(void)getActivityQiaoBaoListWithId:(NSString *)activityId success:(CallbackBlock)successBlock fail:(CallbackBlock)failBlock{
    RequestInfo *info = [self requestInfoWithAct:ActRequestQiaoBaoList];
    NSString *url = [NSString stringWithFormat:@"%@/%@",info.url,activityId];
    info.url = url;
    [self requestWithData:nil requestInfo:info success:successBlock fail:failBlock];
}

#pragma mark 获取发包活动阶段
-(void)getActivityFaBaoListWithId:(NSString *)activityId success:(CallbackBlock)successBlock fail:(CallbackBlock)failBlock{
    RequestInfo *info = [self requestInfoWithAct:ActRequestFaBaoList];
    NSString *url = [NSString stringWithFormat:@"%@/%@",info.url,activityId];
    info.url = url;
    [self requestWithData:nil requestInfo:info success:successBlock fail:failBlock];
}

#pragma mark 获取活动详情
-(void)getActivityDetailWithId:(NSString *)activityId type:(NSInteger)type success:(CallbackBlock)successBlock fail:(CallbackBlock)failBlock{
    RequestInfo *info = [[RequestInfo alloc] init];
    info.requestType = RequestType_get;
    info.act = ActAll;
    NSString *urlTail = nil;
    if(type == RewardType_bzsz)//6000豹子顺子奖励 5000直推流水佣金 2000邀请好友充值 1100充值奖励  3000发包奖励 4000抢包奖励
        urlTail = @"promotion/skPromot/bzsz/detail";
    else if(type == RewardType_ztlsyj)
        urlTail = @"promotion/skPromot/commission/detail";
    else if(type == RewardType_yqhycz)
        urlTail = @"promotion/skPromot/invite/detail";
    else if(type == RewardType_czjl)
        urlTail = @"promotion/skPromot/recharge/detail";
//    else if(type == RewardType_fbjl){
//        urlTail = @"promotion/skPromot/get/send/reward/money";
//        info.requestType = RequestType_post;
//    }
//    else if(type == RewardType_qbjl){
//        urlTail = @"promotion/skPromot/get/rob/reward/money";
//        info.requestType = RequestType_post;
//    }
    urlTail = [NSString stringWithFormat:@"%@/%@",urlTail,activityId];
    info.url = [NSString stringWithFormat:@"%@%@",APP_MODEL.serverUrl,urlTail];
    [self requestWithData:nil requestInfo:info success:successBlock fail:failBlock];
}

#pragma mark 获取发包抢包奖励
-(void)getRewardWithId:(NSString *)activityId type:(NSInteger)type success:(CallbackBlock)successBlock fail:(CallbackBlock)failBlock{
    RequestInfo *info = [[RequestInfo alloc] init];
    info.requestType = RequestType_post;
    info.act = ActAll;
    NSString *urlTail = nil;
    if(type == RewardType_qbjl)//4000抢包奖励 3000发包奖励
        urlTail = @"promotion/skPromot/get/rob/reward/money";
    else
        urlTail = @"promotion/skPromot/get/send/reward/money";
    urlTail = [NSString stringWithFormat:@"%@/%@",urlTail,activityId];
    info.url = [NSString stringWithFormat:@"%@%@",APP_MODEL.serverUrl,urlTail];
    [self requestWithData:nil requestInfo:info success:successBlock fail:failBlock];
}

#pragma mark 获取下线基础信息
-(void)requestMyPlayerCommonInfoWithSuccess:(CallbackBlock)successBlock
                                       fail:(CallbackBlock)failBlock{
    RequestInfo *info = [[RequestInfo alloc] init];
    info.requestType = RequestType_get;
    info.act = ActAll;
    info.url = [NSString stringWithFormat:@"%@proxy/skUserBaseinfoRankModel/team/count",APP_MODEL.serverUrl];
    [self requestWithData:nil requestInfo:info success:successBlock fail:failBlock];
}

#pragma mark 个人报表信息
-(void)requestUserReportInfoWithId:(NSString *)userId success:(CallbackBlock)successBlock
                              fail:(CallbackBlock)failBlock{
    
    RequestInfo *info = [[RequestInfo alloc] init];
    info.requestType = RequestType_get;
    info.act = ActAll;
    info.url = [NSString stringWithFormat:@"%@proxy/skUserBaseinfoRankModel/team/user/report/%@",APP_MODEL.serverUrl,userId];
    [self requestWithData:nil requestInfo:info success:successBlock fail:failBlock];
}

#pragma mark 查询所有推广教程
-(void)requestCopyListWithSuccess:(CallbackBlock)successBlock
                              fail:(CallbackBlock)failBlock{
    
    RequestInfo *info = [[RequestInfo alloc] init];
    info.requestType = RequestType_post;
    info.act = ActAll;
    info.url = [NSString stringWithFormat:@"%@promotion/skPromoteCourse/queryPromoteCourse",APP_MODEL.serverUrl];
    [self requestWithData:nil requestInfo:info success:successBlock fail:failBlock];
}

#pragma mark act
-(RequestInfo *)requestInfoWithAct:(Act)act{
    RequestInfo *info = [[RequestInfo alloc] init];
    info.requestType = RequestType_post;
    info.act = act;
    NSString *urlTail = nil;
    switch (act) {
        case ActRequestToken:
            urlTail = @"auth/oauth/token";
            break;
        case ActRequestTokenBySMS:
            urlTail = @"auth/mobile/token";
            break;
        case ActRegiste:
            urlTail = @"admin/user/mobile/token/reg";
            break;
        case ActRequestIMToken:
            info.requestType = RequestType_get;
            urlTail = @"social/basic/getIMToken";
            break;
        case ActRequestUserInfo:
            info.requestType = RequestType_get;
            urlTail = @"admin/user/baseInfo";
            break;
        case ActRequestUserInfoById:
            info.requestType = RequestType_get;
            urlTail = @"";
            break;
        case ActResetPassword:
            urlTail = @"admin/user/mobile/token/resetPasswd";
            break;
        case ActRequestVerifyCode:
            info.requestType = RequestType_get;
            urlTail = @"admin/smsCode";
            break;
        case ActRequestBankList:
            info.requestType = RequestType_get;
            urlTail = @"finance/skUserPaymentType/getPaymentType";
            break;
        case ActDraw:
            urlTail = @"finance/skBillCashDraws/cash";
            break;
        case ActRequestBillList:
            info.requestType = RequestType_get;
            urlTail = @"finance/skBill/page";
            break;
        case ActRequestBillTypeList:
            info.requestType = RequestType_get;
            urlTail = @"finance/skBillType/list";
            break;
        case ActUploadImg:
            urlTail = @"admin/user/upload";
            break;
        case ActModifyUserInfo:
            urlTail = @"admin/user/updateAvatarNickName";
            break;
        case ActRequestCommonInfo:
            info.requestType = RequestType_get;
            urlTail = @"social/basic/getAppConfig";
            break;
        case ActMyPlayer:
            info.requestType = RequestType_get;
            urlTail = @"proxy/skUserBaseinfoRankModel/page";//@"social/skUserBaseinfoRankModel/page";
            break;
        case ActRequestDrawRecordList:
            info.requestType = RequestType_get;
            urlTail = @"finance/skUserPayment/getPaymentType";
            break;
        case ActRequestSystemNotice:
            info.requestType = RequestType_get;
            urlTail = @"social/systemNotice/page";
            break;
        case ActRequestShareList:
            info.requestType = RequestType_get;
            urlTail = @"social/promotionShare/page";
            break;
        case ActAddShareCount:
            info.requestType = RequestType_get;
            urlTail = @"social/promotionShare/addCount";
            break;
        case ActRequestRechargeList:
            urlTail = @"finance/skPayChannel/page";
            break;
        case ActRequestReportForms:
            urlTail = @"bms/agentreport/allData";
            break;
        case ActRemoveToken:
            info.requestType = RequestType_get;
            urlTail = @"auth/authentication/removeToken";
            break;
        case ActRequestActivityList:
            urlTail = @"social/promotReward/list";
            break;
        case ActGetReward:
            urlTail = @"social/promotReward/receive";
            break;
        case ActGetFirstRewardInfo:
            urlTail = @"social/promotReward/getRechargeReward";
            break;
        case ActToBeAgent:
            urlTail = @"social/proxy/applyAgent";
            break;
        case ActGetLotterys:
            urlTail = @"social/userLottery/lotteryItems";
            break;
        case ActGetLotteryList:
            urlTail = @"social/userLottery/lotteryUserList";
            break;
        case ActLottery:
            urlTail = @"social/userLottery/startLottery";
            break;
        case ActAddBankCard:
            urlTail = @"finance/skUserPayment";
            break;
        case ActRequestMyBankList:
            urlTail = @"finance/skUserPayment/list";
            break;
        case ActRequestWithdrawHistory:
            info.requestType = RequestType_get;
            urlTail = @"finance/skBillCashDraws/page";
            break;
        case ActRequestLastWithdrawInfo:
            urlTail = @"finance/skUserPayment/getSkUserPaymentModel";
            break;
        case ActRequestRechargeListFirst:
            urlTail = @"finance/skPayChannel/page";
            break;
        case ActRequestRechargeListAll:
            urlTail = @"finance/skPayChannel/querPromotionShares";
            break;
        case ActSubmitRechargeInfo:
            urlTail = @"finance/transfer/info";
            break;
        case ActReOrderRecharge:
            urlTail = @"finance/transfer/cancelpay";
            break;
        case ActOrderRecharge:
            urlTail = @"finance/transfer/pay";
            break;
        case ActRequestShareUrl:
            info.requestType = RequestType_get;
            urlTail = @"bms/skAgentDomain/get/domain";
            break;
        case ActRequestGuideImageList:
            urlTail = @"promotion/skHelpCenter/querySkHelpCenter";
            break;
        case ActRequestActivityList2:
            urlTail = @"promotion/skPromot/new/page";
            break;
        case ActRequestFaBaoList:
            info.requestType = RequestType_get;
            urlTail = @"promotion/skPromot/send/detail";
            break;
        case ActRequestQiaoBaoList:
            info.requestType = RequestType_get;
            urlTail = @"promotion/skPromot/rob/detail";
            break;
        case ActNil:
            urlTail = @"";
            break;
        default:
            break;
    }
    info.url = [NSString stringWithFormat:@"%@%@",APP_MODEL.serverUrl,urlTail];
    return info;
}

@end
