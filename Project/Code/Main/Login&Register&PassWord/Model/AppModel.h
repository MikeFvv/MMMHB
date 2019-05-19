//
//  AppModel.h
//  Project
//
//  Created by mini on 2018/8/1.
//  Copyright © 2018年 CDJay. All rights reserved.
//

#import <Foundation/Foundation.h>


@class UserInfo;

@interface AppModel : NSObject<NSCoding>

@property (nonatomic ,assign) BOOL turnOnSound;///<声音
//@property (nonatomic ,strong) UserInfo *user;///<用户信息
@property (nonatomic ,strong) UserInfo *userInfo;///<用户信息
@property (nonatomic ,copy) NSString *rongYunToken;
@property (nonatomic ,assign) NSInteger unReadCount;  //< 未读总消息
@property (nonatomic ,strong) NSDictionary *commonInfo;
@property (nonatomic ,copy) NSString *appClientIdInCommonInfo;
@property (nonatomic ,strong) NSDictionary *noticeArray;

@property (nonatomic ,copy) NSString *serverUrl;
@property (nonatomic ,copy) NSString *rongYunKey;
@property (nonatomic ,copy) NSString *authKey;

// NO 正式版    YES 测试版
@property (nonatomic ,assign) BOOL debugMode;

// 我加入的群id
@property (nonatomic ,strong) NSArray *myGroupArray;

+ (instancetype)shareInstance;
- (void)saveAppModel;///<登录存档
- (void)logout;///<退出清理
- (UIViewController *)rootVc;
- (void)initSetUp;
-(void)reSetRootAnimation:(BOOL)b;
-(void)reSetTabBarAsRootAnimation;
-(NSArray *)ipArray;
@end
