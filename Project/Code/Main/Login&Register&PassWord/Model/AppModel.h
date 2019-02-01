//
//  AppModel.h
//  Project
//
//  Created by mini on 2018/8/1.
//  Copyright © 2018年 CDJay. All rights reserved.
//

#import <Foundation/Foundation.h>


@class UserModel;

#define APP_MODEL [AppModel shareInstance]

@interface AppModel : NSObject<NSCoding>

@property (nonatomic ,assign) BOOL turnOnSound;///<声音
@property (nonatomic ,strong) UserModel *user;///<用户信息
@property (nonatomic ,copy) NSString *rongYunToken;
@property (nonatomic ,assign) int unReadCount;///< 未读总消息
@property (nonatomic ,strong) NSDictionary *commonInfo;
@property (nonatomic ,copy) NSDictionary *noticeArray;

@property (nonatomic ,copy) NSString *serverUrl;
@property (nonatomic ,copy) NSString *rongYunKey;
@property (nonatomic ,copy) NSString *authKey;

+ (instancetype)shareInstance;
- (void)save;///<登录存档
- (void)logout;///<退出清理
- (UIViewController *)rootVc;
- (void)initSetUp;
-(void)reSetRootAnimation:(BOOL)b;

-(NSArray *)ipArray;
@end
