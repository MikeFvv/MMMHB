//
//  UserModel.h
//  Project
//
//  Created by mini on 2018/8/1.
//  Copyright © 2018年 CDJay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserModel : NSObject<NSCoding>

@property (nonatomic ,copy) NSString *userAvatar;///<NOT NULL DEFAULT '' COMMENT '头像',
@property (nonatomic ,copy) NSString *userBirthday;///<DEFAULT NULL COMMENT '生日'
@property (nonatomic ,copy) NSString *userCreateTime;///<DEFAULT '0' COMMENT '创建时间'
@property (nonatomic ,copy) NSString *userEmail;///<邮箱
@property (nonatomic ,copy) NSString *userFrozenMoney;///<DEFAULT '0.00' COMMENT '冻结金额',
@property (nonatomic ,assign) NSInteger userGender;///<性别
@property (nonatomic ,copy) NSString *userId;///<用户id
@property (nonatomic ,assign) NSInteger jointime;///<DEFAULT '0' COMMENT '加入时间',
@property (nonatomic ,copy) NSString *userMobile;///<DEFAULT '' COMMENT '手机',
@property (nonatomic ,copy) NSString *userBalance;///<DEFAULT '0.00' COMMENT '余额',两位小数
@property (nonatomic ,copy) NSString *userNick;///<NOT NULL DEFAULT '' COMMENT '昵称',
@property (nonatomic ,copy) NSString *userInvitecode;///<DEFAULT NULL COMMENT '分享码'
@property (nonatomic ,assign) NSInteger userStatus;///<DEFAULT '1' COMMENT '用户状态  1 正常  2 禁止',
@property (nonatomic ,copy) NSString *token;///<DEFAULT '' COMMENT 'Token',
@property (nonatomic ,copy) NSString *tokenType;
@property (nonatomic ,copy) NSString *userSalt;
@property (nonatomic ,copy) NSString *fullToken;
@property (nonatomic ,assign)BOOL isLogined;//是否登录

+ (void)getUserInfoObj:(id)obj
               Success:(void (^)(NSDictionary *))success
               Failure:(void (^)(NSError *))failue;

@end

