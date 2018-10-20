//
//  NetDataManager.m
//  XM_12580
//
//  Created by mac on 12-7-9.
//  Copyright (c) 2012年 Neptune. All rights reserved.
//

#import "NetRequestManager.h"
#import "NetResponseManager.h"

#define key_requestType @"requestType"
#define key_apiPath @"apiPath"

@implementation RequestInfo
@end

@interface NetRequestManager()
@property(nonatomic,strong)NSMutableArray *requestsArray;
@end

static NetRequestManager *instance = nil;

@implementation NetRequestManager

+ (NetRequestManager *)sharedInstance{
    static dispatch_once_t instRequ;
    dispatch_once(&instRequ, ^{
        if(instance == nil)
            instance = [[NetRequestManager alloc] init];
    });
    return instance;
}

+ (void)destroyInstance{
    if(instance){
        instance = nil;
    }
}

-(id)init{
    self=[super init];
    if (self){
        if(self.requestsArray == nil)
            self.requestsArray = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void)dealloc{
}

#pragma mark    - 公共部分

- (void)requestData:(id)data action:(Action)act api:(NSString *)api extraData:(NSDictionary *)extraData headerData:(NSDictionary *)headerData requestType:(RequestType)requestType success:(ResponseBlock)successBlock fail:(ResponseBlock)failBlock{
    AFHTTPSessionManager2 *manager = [self createHttpSessionManager];
    [self.requestsArray addObject:manager];
    manager.requestParameters = data;
    manager.extraData = extraData;
    manager.successBlock = successBlock;
    manager.failBlock = failBlock;
    manager.action = act;
    NSString *apiPath = api;
    if(apiPath == nil){
        apiPath = [self apiByAction:act].apiPath;
    }
    CDWeakSelf(self);
    WEAK_OBJ(weakObj, manager);
    
    if(headerData){
        NSArray *keyArr = [headerData allKeys];
        for (NSString *key in keyArr) {
            [manager.requestSerializer setValue:[headerData objectForKey:key] forHTTPHeaderField:key];
        }
    }
    if(requestType == RequestTypeGet){
        [manager GET:apiPath parameters:data progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [NET_RESPONSE_MANAGER requestWithHTTPSessionManager:weakObj block:responseObject];
            if([weakself.requestsArray containsObject:weakObj])
                [weakself.requestsArray removeObject:weakObj];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [NET_RESPONSE_MANAGER requestWithHTTPSessionManager:weakObj failed:error];
            if([weakself.requestsArray containsObject:weakObj])
                [weakself.requestsArray removeObject:weakObj];
        }];
    }else{
        [manager POST:apiPath parameters:data progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [NET_RESPONSE_MANAGER requestWithHTTPSessionManager:weakObj block:responseObject];
            if([weakself.requestsArray containsObject:weakObj])
                [weakself.requestsArray removeObject:weakObj];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"error= %@",error);
            [NET_RESPONSE_MANAGER requestWithHTTPSessionManager:weakObj failed:error];
            if([weakself.requestsArray containsObject:weakObj])
                [weakself.requestsArray removeObject:weakObj];
        }];
    }
}

- (void)requestData:(id)data action:(Action)act extraData:(NSDictionary *)extraData headerData:(NSDictionary *)headerData requestType:(RequestType)requestType success:(ResponseBlock)successBlock fail:(ResponseBlock)failBlock{
    [self requestData:data action:act api:nil extraData:extraData headerData:headerData requestType:requestType success:successBlock fail:failBlock];
}

//POST请求
- (void)postData:(id)data action:(Action)act extraData:(NSDictionary *)extraData headerData:(NSDictionary *)headerData success:(ResponseBlock)successBlock fail:(ResponseBlock)failBlock{
    [self requestData:data action:act extraData:extraData headerData:headerData requestType:RequestTypePost success:successBlock fail:failBlock];
}

- (void)postData:(id)data action:(Action)act success:(ResponseBlock)successBlock fail:(ResponseBlock)failBlock{
    NSMutableDictionary *headDic = [[NSMutableDictionary alloc] init];
    NSString *tocken = APP_MODEL.user.token;
    if(tocken.length == 0)
        tocken = KEY_AUTH;
    [headDic setObject:tocken forKey:@"Authorization"];
    [self requestData:data action:act extraData:nil headerData:nil requestType:RequestTypePost success:successBlock fail:failBlock];
}

//GET请求
- (void)getData:(id)data action:(Action)act extraData:(NSDictionary *)extraData headerData:(NSDictionary *)headerData success:(ResponseBlock)successBlock fail:(ResponseBlock)failBlock{
    [self requestData:data action:act extraData:extraData headerData:headerData requestType:RequestTypeGet success:successBlock fail:failBlock];
}

- (void)cancelRequestByAction:(Action)action{
    for (AFHTTPSessionManager2 *manager in self.requestsArray) {
        if(manager.action == action){
            manager.successBlock = nil;
            manager.failBlock = nil;
            [self.requestsArray removeObject:manager];
            break;
        }
    }
}

-(AFHTTPSessionManager2 *)createHttpSessionManager{
    AFHTTPSessionManager2 *manager = [AFHTTPSessionManager2 manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/javascript",@"text/json",@"text/html",@"image/jpeg", @"image/png",@"text/plain",@"application/octet-stream", nil];
    manager.requestSerializer.timeoutInterval = 30;
    return manager;
}

#pragma mark    - 接口部分

-(void)registeWithAccount:(NSString *)account password:(NSString *)password smsCode:(NSString *)smsCode referralCode:(NSString *)referralCode success:(ResponseBlock)successBlock fail:(ResponseBlock)failBlock{
    Action action = ActionRegiste;
    RequestInfo *requestInfo = [self apiByAction:action];
    NSString * api = [NSString stringWithFormat:@"%@?mobile=%@&code=%@",requestInfo.apiPath,account,smsCode];
    NSMutableDictionary *bodyDic = [self parametersDic];
    [bodyDic setObject:password forKey:@"passwd"];
    if(referralCode)
        [bodyDic setObject:referralCode forKey:@"referralCode"];
    
    NSMutableDictionary *headDic = [[NSMutableDictionary alloc] init];
    [headDic setObject:KEY_AUTH forKey:@"Authorization"];
    [self requestData:bodyDic action:action api:api extraData:nil headerData:headDic requestType:requestInfo.requestType success:successBlock fail:failBlock];
}

-(void)requestSmsCodeWithPhone:(NSString *)phone code:(NSString *)code success:(ResponseBlock)successBlock fail:(ResponseBlock)failBlock{
    Action action = ActionGetSMS;
    RequestInfo *requestInfo = [self apiByAction:action];
    NSString * api = [NSString stringWithFormat:@"%@/%@/%@",requestInfo.apiPath,phone,code];
    [self requestData:nil action:action api:api extraData:nil headerData:nil requestType:requestInfo.requestType success:successBlock fail:failBlock];
}

-(void)findPasswordWithPhone:(NSString *)phone smsCode:(NSString *)smsCode password:(NSString *)password success:(ResponseBlock)successBlock fail:(ResponseBlock)failBlock{
    Action action = ActionFindPassword;
    RequestInfo *requestInfo = [self apiByAction:action];
    NSString * api = [NSString stringWithFormat:@"%@?mobile=%@&code=%@&password=%@",requestInfo.apiPath,phone,smsCode,password];
    NSMutableDictionary *headDic = [[NSMutableDictionary alloc] init];
    [headDic setObject:KEY_AUTH forKey:@"Authorization"];
    [self requestData:nil action:action api:api extraData:nil headerData:headDic requestType:requestInfo.requestType success:successBlock fail:failBlock];
}

-(void)requestTockenWithAccount:(NSString *)account password:(NSString *)password success:(ResponseBlock)successBlock fail:(ResponseBlock)failBlock{
    Action action = ActionGetToken;
    RequestInfo *requestInfo = [self apiByAction:action];
    NSData *aesData = [[password dataUsingEncoding:NSUTF8StringEncoding] AES128EncryptWithKey:KEY_AES iv:KEY_AES_IV];
    NSData *base64Data = [GTMBase64 encodeData:aesData];
    password = [[NSString alloc] initWithData:base64Data encoding:NSUTF8StringEncoding];
    NSString * api = [NSString stringWithFormat:@"%@?username=%@&password=%@&randomStr=82701535096009570&code=5app&grant_type=password&scope=server",requestInfo.apiPath,account,password];
    NSMutableDictionary *headDic = [[NSMutableDictionary alloc] init];
    [headDic setObject:KEY_AUTH forKey:@"Authorization"];
    [self requestData:nil action:action api:api extraData:nil headerData:headDic requestType:requestInfo.requestType success:successBlock fail:failBlock];
}

-(void)requestUserInfoWithUserId:(NSString *)userId success:(ResponseBlock)successBlock fail:(ResponseBlock)failBlock{
    Action action = ActionGetUserInfo;
    RequestInfo *requestInfo = [self apiByAction:action];
    NSMutableDictionary *headDic = [[NSMutableDictionary alloc] init];
    [headDic setObject:APP_MODEL.user.fullToken forKey:@"Authorization"];
    [self requestData:nil action:action api:nil extraData:nil headerData:headDic requestType:requestInfo.requestType success:successBlock fail:failBlock];
}

-(void)updatePhoto:(NSString *)photo nickName:(NSString *)nickName success:(ResponseBlock)successBlock fail:(ResponseBlock)failBlock{
    Action action = ActionUpdateAvatarNickName;
    NSMutableDictionary *bodyDic = [self parametersDic];
    [bodyDic setObject:photo forKey:@"userAvatar"];
    [bodyDic setObject:nickName forKey:@"userNick"];
    [self postData:bodyDic action:action success:successBlock fail:failBlock];
}

-(void)requestRedPacketDetailWithId:(NSString *)redPacketId success:(ResponseBlock)successBlock fail:(ResponseBlock)failBlock{
    Action action = ActionGetRedPacketDetail;
    RequestInfo *requestInfo = [self apiByAction:action];
    NSString * api = [NSString stringWithFormat:@"%@/%@",requestInfo.apiPath,redPacketId];
    [self requestData:nil action:action extraData:nil headerData:nil requestType:requestInfo.requestType success:successBlock fail:failBlock];
}

-(void)sendRedPacketWithCount:(NSInteger)count groupId:(NSString *)groupId money:(NSString *)money userId:(NSString *)userId type:(NSInteger)type extInfo:(NSDictionary *)extInfo success:(ResponseBlock)successBlock fail:(ResponseBlock)failBlock{
    Action action = ActionSendRedPacket;
    RequestInfo *requestInfo = [self apiByAction:action];
    NSMutableDictionary *bodyDic = [self parametersDic];
}
-(void)grabRedPacketWithUserId:(NSString *)userId redPacketId:(NSString *)redPacketId success:(ResponseBlock)successBlock fail:(ResponseBlock)failBlock{
    
}

-(void)requestGroupDetailWithId:(NSString *)groupId success:(ResponseBlock)successBlock fail:(ResponseBlock)failBlock{
    Action action = ActionGetGroupDetail;
    RequestInfo *requestInfo = [self apiByAction:action];
    NSString * api = [NSString stringWithFormat:@"%@/%@",requestInfo.apiPath,groupId];
    [self requestData:nil action:action extraData:nil headerData:nil requestType:requestInfo.requestType success:successBlock fail:failBlock];
}

-(void)createGroupWithName:(NSString *)name image:(NSString *)imagePath active:(BOOL)isActive shutUp:(BOOL)isShutUp joinMoney:(NSString *)money know:(NSString *)know rule:(NSString *)rule notice:(NSString *)notice userId:(NSString *)userId success:(ResponseBlock)successBlock fail:(ResponseBlock)failBlock{
    Action action = ActionCreateGroup;
    RequestInfo *requestInfo = [self apiByAction:action];
    NSMutableDictionary *bodyDic = [self parametersDic];
    if(name)
        [bodyDic setObject:name forKey:@"name"];
    if(imagePath)
        [bodyDic setObject:imagePath forKey:@"img"];
    [bodyDic setObject:[NSNumber numberWithBool:isActive] forKey:@"isActive"];
    [bodyDic setObject:[NSNumber numberWithBool:isShutUp] forKey:@"isShutup"];
    if(know)
        [bodyDic setObject:know forKey:@"know"];
    if(money)
        [bodyDic setObject:money forKey:@"joinMoney"];
    if(rule)
        [bodyDic setObject:rule forKey:@"rule"];
    if(notice)
        [bodyDic setObject:notice forKey:@"notice"];
    [bodyDic setObject:userId forKey:@"onwerUserId"];
    [self postData:bodyDic action:action success:successBlock fail:failBlock];
}

-(void)requestGroupMemberListWithPage:(NSInteger)page pageSize:(NSInteger)pageSize orderField:(NSString *)orderField asc:(BOOL)asc groupId:(NSString *)groupId success:(ResponseBlock)successBlock fail:(ResponseBlock)failBlock{
    Action action = ActionGetGroupMemberList;
    RequestInfo *requestInfo = [self apiByAction:action];
}

-(void)joinGroupWithId:(NSString *)groupId success:(ResponseBlock)successBlock fail:(ResponseBlock)failBlock{
    Action action = ActionJoinGroup;
    RequestInfo *requestInfo = [self apiByAction:action];
    NSString * api = [NSString stringWithFormat:@"%@/%@",requestInfo.apiPath,groupId];
    NSMutableDictionary *headDic = [[NSMutableDictionary alloc] init];
    [headDic setObject:APP_MODEL.user.fullToken forKey:@"Authorization"];
    [self requestData:nil action:action api:api extraData:nil headerData:headDic requestType:requestInfo.requestType success:successBlock fail:failBlock];
}

-(void)requestGroupListMyJoinedWithPage:(NSInteger)page pageSize:(NSInteger)pageSize orderField:(NSString *)orderField asc:(BOOL)asc success:(ResponseBlock)successBlock fail:(ResponseBlock)failBlock{
    Action action = ActionGetGroupListMyJoined;
    RequestInfo *requestInfo = [self apiByAction:action];
    NSMutableDictionary *headDic = [[NSMutableDictionary alloc] init];
    [headDic setObject:APP_MODEL.user.fullToken forKey:@"Authorization"];
    [self requestData:nil action:action extraData:nil headerData:headDic requestType:requestInfo.requestType success:successBlock fail:failBlock];
}

-(void)requestGroupListWithPage:(NSInteger)page pageSize:(NSInteger)pageSize orderField:(NSString *)orderField asc:(BOOL)asc success:(ResponseBlock)successBlock fail:(ResponseBlock)failBlock{
    Action action = ActionGetGroupList;
    RequestInfo *requestInfo = [self apiByAction:action];
    NSMutableDictionary *headDic = [[NSMutableDictionary alloc] init];
    [headDic setObject:APP_MODEL.user.fullToken forKey:@"Authorization"];
    [self requestData:nil action:action extraData:nil headerData:headDic requestType:requestInfo.requestType success:successBlock fail:failBlock];
}

-(void)quitGroupWithId:(NSString *)groupId success:(ResponseBlock)successBlock fail:(ResponseBlock)failBlock{
    Action action = ActionQuitGroup;
    RequestInfo *requestInfo = [self apiByAction:action];
    NSString * api = [NSString stringWithFormat:@"%@/%@",requestInfo.apiPath,groupId];
    NSMutableDictionary *headDic = [[NSMutableDictionary alloc] init];
    [headDic setObject:APP_MODEL.user.fullToken forKey:@"Authorization"];
    [self requestData:nil action:action api:api extraData:nil headerData:headDic requestType:requestInfo.requestType success:successBlock fail:failBlock];
}

-(void)requestIMTokenWithSuccess:(ResponseBlock)successBlock fail:(ResponseBlock)failBlock{
    Action action = ActionGetIMToken;
    RequestInfo *requestInfo = [self apiByAction:action];
    NSMutableDictionary *headDic = [[NSMutableDictionary alloc] init];
    [headDic setObject:APP_MODEL.user.fullToken forKey:@"Authorization"];
    [self requestData:nil action:action extraData:nil headerData:headDic requestType:requestInfo.requestType success:successBlock fail:failBlock];
}

-(RequestInfo *)apiByAction:(Action)act{
    NSString *apiPath = nil;
    RequestType requestType = RequestTypeNull;
    if(act == ActionRegiste){
        apiPath = @"admin/user/mobile/token/reg";
        requestType = RequestTypePost;
    }
    else if(act == ActionGetToken){
        apiPath = @"auth/oauth/token";
        requestType = RequestTypePost;
    }
    else if(act == ActionGetUserInfo){
        apiPath = @"admin/user/baseInfo";
        requestType = RequestTypeGet;
    }
    else if(act == ActionFindPassword){
        apiPath = @"admin/user/mobile/token/resetPasswd";
        requestType = RequestTypePost;
    }
    else if(act == ActionGetSMS){
        apiPath = @"admin/smsCode";
        requestType = RequestTypeGet;
    }
    else if(act == ActionGetAppConfig){
        apiPath = @"social/basic/getAppConfig";
        requestType = RequestTypeGet;
    }
    else if(act == ActionGetIMToken){
        apiPath = @"social/basic/getIMToken";
        requestType = RequestTypeGet;
    }
    else if(act == ActionGetRedPacketDetail){
        apiPath = @"social/redpacket";
        requestType = RequestTypeGet;
    }
    else if(act == ActionGrabRedPacket){
        apiPath = @"social/redpacket/grab";
        requestType = RequestTypePost;
    }
    else if(act == ActionGrabRedPacketByFree){
        apiPath = @"social/redpacket/freeGrab";
        requestType = RequestTypePost;
    }
    else if(act == ActionGrabPacketByRobot){
        apiPath = @"social/redpacket/robotGrab";
        requestType = RequestTypePost;
    }
    else if(act == ActionSendRedPacket){
        apiPath = @"social/redpacket/send";
        requestType = RequestTypePost;
    }
    else if(act == ActionUpdateAvatarNickName){
        apiPath = @"admin/user/updateAvatarNickName";
    }
    else if(act == ActionGetGroupDetail){
        apiPath = @"social/skChatGroup";
        requestType = RequestTypeGet;
    }
    else if(act == ActionCreateGroup){
        apiPath = @"social/skChatGroup/create";
    }
    else if(act == ActionGetGroupMemberList){
        apiPath = @"social/skChatGroup/groupUsers";
        requestType = RequestTypeGet;
    }
    else if(act == ActionJoinGroup){
        apiPath = @"social/skChatGroup/join";
        requestType = RequestTypeGet;
    }
    else if(act == ActionGetGroupListMyJoined){
        apiPath = @"social/skChatGroup/joinGroupPage";
        requestType = RequestTypeGet;
    }
    else if(act == ActionGetGroupList){
        apiPath = @"social/skChatGroup/page";
        requestType = RequestTypeGet;
    }
    else if(act == ActionQuitGroup){
        apiPath = @"social/skChatGroup/quit";
        requestType = RequestTypeGet;
    }
    else if(act == ActionNull){
        apiPath = @"";
    }
    else if(act == ActionNull){
        apiPath = @"";
    }
    else if(act == ActionNull){
        apiPath = @"";
    }
    else if(act == ActionNull){
        apiPath = @"";
    }
    else if(act == ActionNull){
        apiPath = @"";
    }
    else if(act == ActionNull){
        apiPath = @"";
    }
    else if(act == ActionNull){
        apiPath = @"";
    }
    
    apiPath = [NSString stringWithFormat:@"%@%@",SERVER_URL,apiPath];
    apiPath = [apiPath stringByReplacingOccurrencesOfString:@"//" withString:@"/" options:NSBackwardsSearch range:NSMakeRange(8, apiPath.length - 8)];
    RequestInfo *info = [[RequestInfo alloc] init];
    info.requestType = requestType;
    info.apiPath = apiPath;
    return info;
}

-(NSMutableDictionary *)parametersDic{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    return dict;
}

-(void)test{
//    [self requestSmsCodeWithPhone:@"13290807584" callBackBlock:^(id object) {
//
//    }];
//    [self registeWithAccount:@"13290807584" password:@"qqqqqqqq" smsCode:@"2352" referralCode:@"B9XWMV" callBackBlock:^(id object) {
//
//    }];
//    [self findPasswordWithPhone:@"13290807584" smsCode:@"2598" password:@"qqqqqqqq" callBackBlock:^(id object) {
//
//    }];
//    [self requestTockenWithAccount:@"admin" password:@"123456" callBackBlock:^(id object) {
//
//    }];
    NSLog(@"---------test NetRequestManager");
}
@end
