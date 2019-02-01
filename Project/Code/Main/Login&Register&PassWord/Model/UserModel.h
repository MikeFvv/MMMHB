//
//  UserModel.h
//  Project
//
//  Created by mini on 2018/8/1.
//  Copyright © 2018年 CDJay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserModel : NSObject<NSCoding>

@property(nonatomic,assign)BOOL isLogined;
@property(nonatomic,copy)NSString *userId;
@property(nonatomic,copy)NSString *avatar;
@property(nonatomic,copy)NSString *email;
@property(nonatomic,copy)NSString *invitecode;//邀请码
@property(nonatomic,copy)NSString *mobile;
@property(nonatomic,copy)NSString *frozenMoney;//冻结金额
@property(nonatomic,assign)NSInteger gender;
@property(nonatomic,copy)NSString *balance;//余额
@property(nonatomic,copy)NSString *createTime;
@property(nonatomic,copy)NSString *jointime;
@property(nonatomic,copy)NSString *token;
@property(nonatomic,assign)NSInteger agentFlag;//是否是代理

/**
 后台token
 */
@property(nonatomic,copy)NSString *fullToken;
@property(nonatomic,copy)NSString *nick;
@property(nonatomic,copy)NSString *userSalt;
@property(nonatomic,assign)NSInteger status;



//+ (void)getUserInfoObj:(id)obj
//               Success:(void (^)(NSDictionary *))success
//               Failure:(void (^)(NSError *))failue;

//-(void)saveToDisk;

@end

