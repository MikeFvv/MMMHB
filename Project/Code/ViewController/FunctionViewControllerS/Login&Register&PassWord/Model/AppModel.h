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

@property (nonatomic ,assign) BOOL Sound;///<声音
@property (nonatomic ,strong) UserModel *user;///<用户信息
@property (nonatomic ,copy) NSString *rongYunToken;///
@property (nonatomic ,strong) NSMutableArray *unReadNumberArray;///<未读数据

//app通用数据，启动时会请求
@property (nonatomic ,strong)NSDictionary *appConfig;//
+ (instancetype)shareInstance;
- (UIViewController *)rootVc;
- (void)initSetUp;
- (void)resetRootAnimation:(BOOL)b;
- (void)hidGuide;

- (void)loginOut;///<退出清理

//+ (void)getUserInfoSuccess:(void (^)(NSDictionary *))success
//                   Failure:(void (^)(NSError *))failue;

//+ (void)sendSMSObj:(id)obj
//           Success:(void (^)(NSDictionary *))success
//           Failure:(void (^)(NSError *))failue;
//
//+ (void)registerObj:(id)obj
//            Success:(void (^)(NSDictionary *))success
//            Failure:(void (^)(NSError *))failue;


//+ (void)loginObj:(id)obj
//         Success:(void (^)(NSDictionary *))success
//         Failure:(void (^)(NSError *))failue;

//+ (void)getRYTokenSuccess:(void (^)(NSDictionary *))success
//                  Failure:(void (^)(NSError *))failue;

//+ (void)updataPasswordObj:(id)obj
//                  Success:(void (^)(NSDictionary *))success
//                  Failure:(void (^)(NSError *))failue;

//+ (void)updataUserObj:(id)obj
//              Success:(void (^)(NSDictionary *))success
//              Failure:(void (^)(NSError *))failue;

//+ (void)wxLoginSuccess:(void (^)(NSDictionary *))success
//               Failure:(void (^)(NSError *))failue;

//+ (void)wxResterObj:(id)obj
//            Success:(void (^)(NSDictionary *))success
//            Failure:(void (^)(NSError *))failue;

//+ (void)uploadIconObj:(UIImage *)icon
//              Success:(void (^)(NSDictionary *))success
//              Failure:(void (^)(NSError *))failue;

//+ (void)getShareConfigObj:(id)obj
//                  Success:(void (^)(NSDictionary *))success
//                  Failure:(void (^)(NSError *))failue;

- (void)saveToDisk;///<登录存档
@end
