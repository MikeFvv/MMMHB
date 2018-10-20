//
//  AppModel.m
//  Project
//
//  Created by mini on 2018/8/1.
//  Copyright © 2018年 CDJay. All rights reserved.
//

#import "AppModel.h"
#import "CDBaseNet.h"
#import "RonYun.h"
#import "UserModel.h"
#import "WXManage.h"
#import "SqliteManage.h"


static NSString *Path = @"COM.XMFX.path";

@implementation AppModel

MJCodingImplementation

+ (void)load{
    [self performSelectorOnMainThread:@selector(shareInstance) withObject:nil waitUntilDone:NO];
}

+ (instancetype)shareInstance{
    static AppModel *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString* filename = [[paths objectAtIndex:0] stringByAppendingPathComponent:Path];
        if ([NSKeyedUnarchiver unarchiveObjectWithFile:filename]) {
            self = [NSKeyedUnarchiver unarchiveObjectWithFile:filename];
        }else{
            _Sound = [RCIM sharedRCIM].disableMessageAlertSound;
        }
    }
    return self;
}

- (void)setSound:(BOOL)Sound{ ///<YES关闭，No开启
    _Sound = Sound;
    [RCIM sharedRCIM].disableMessageAlertSound = Sound;
}

-(UserModel *)user{
    if(_user == nil)
        _user = [[UserModel alloc] init];
    return _user;
}
- (void)saveToDisk{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* filename = [[paths objectAtIndex:0] stringByAppendingPathComponent:Path];
    [NSKeyedArchiver archiveRootObject:self toFile:filename];
}

- (void)loginOut{
    self.user = [UserModel new];
}

#pragma mark method

+ (void)initSetUp{
    
    
    //融云
    [RonYun initWithMode:isLine];
    
    //开启消息撤回功能
    //    [RCIM sharedRCIM].enableMessageRecall = YES;
    //svp
    [SVProgressHUD setMinimumDismissTimeInterval:1.2f];
    [SVProgressHUD setMaximumDismissTimeInterval:1.2f];
    
    //去掉底部和适配11
    [[UITableView appearance] setTableFooterView:[UIView new]];
    [[UITableView appearance] setEstimatedSectionFooterHeight:0];
    [[UITableView appearance] setEstimatedSectionHeaderHeight:0];
    [[UITableViewCell appearance] setSelectionStyle:0];
    
    [[UIWindow appearance]setBackgroundColor:BaseColor];
    [[UIButton appearance]setExclusiveTouch:YES];
    [[UIBarButtonItem appearance]setBackButtonBackgroundImage:[UIImage imageNamed:@"navback"] forState:0 barMetrics:UIBarMetricsCompact];
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(-1000,0)
                                                         forBarMetrics:UIBarMetricsDefault];
    
    [[UINavigationBar appearance] setBackgroundColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setBarTintColor:Color_3];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setBarStyle:UIBarStyleDefault];
    [[UINavigationBar appearance] setShadowImage:[UIImage new]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSFontAttributeName:[UIFont scaleFont:17],NSForegroundColorAttributeName:Color_F}];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    //    [[UITabBar appearance]setTintColor:TABSelectColor];
    
}

+ (void)loginOut{
    [APP_MODEL loginOut];
    APP_MODEL.unReadNumber = 0;
    [APP_MODEL saveToDisk];
    [self resetRootAnimation:YES];
    [RONG_YUN disConnect];
    
}

+ (void)login{
    [APP_MODEL saveToDisk];
    [self resetRootAnimation:YES];
}

+ (void)hidGuide{
    [[NSUserDefaults standardUserDefaults]setObject:@(YES) forKey:[NSString appVersion]];
    [[NSUserDefaults standardUserDefaults]synchronize];
    [self resetRootAnimation:NO];
}


+ (UIViewController *)rootVc{
    if (![[NSUserDefaults standardUserDefaults]objectForKey:[NSString appVersion]]) {
        return [[NSClassFromString(@"GuideViewController") alloc]init];
    }
    else{
        if (APP_MODEL.user.isLogined) {
            return [[NSClassFromString(@"ViewController")alloc]init];
        }else{
            UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:[[NSClassFromString(@"LoginViewController")alloc]init]];
            return nav;
        }
    }
}

+ (void)resetRootAnimation:(BOOL)b{
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    if (b) {
        [window.layer addAnimation:self.animation forKey:nil];
    }
    
    window.rootViewController = self.rootVc;
}

+ (CATransition *)animation{
    CATransition *animation = [CATransition animation];
    animation.duration = 0.5;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    animation.type =  @"cube";  //立方体效果
    
    //设置动画子类型
    animation.subtype = kCATransitionFromTop;
    return animation;
}


#pragma mark net
+ (void)getUserInfoSuccess:(void (^)(NSDictionary *))success
                   Failure:(void (^)(NSError *))failue{
    CDBaseNet *net = [CDBaseNet normalNet];
    net.param = @{@"uid":APP_MODEL.user.userId};
    net.path = Line_MemberInfo;
    CDWeakSelf(self);
    [net doGetSuccess:^(NSDictionary *dic) {
        CDStrongSelf(self);
        CDLog(@"%@",dic);
        if (CD_Success([dic objectForKey:@"status"], 1)) {
            UserModel *user = [UserModel mj_objectWithKeyValues:dic[@"data"]];
            APP_MODEL.user = user;
            [APP_MODEL saveToDisk];
            success(dic);
        }
        else{
            failue(tipError(dic[@"msg"], 0));
        }
    } failure:^(NSError *error) {
        failue(error);
    }];
}

//+ (void)sendSMSObj:(id)obj
//           Success:(void (^)(NSDictionary *))success
//           Failure:(void (^)(NSError *))failue{
//    CDBaseNet *net = [CDBaseNet normalNet];
//    net.param = obj;
//    net.path = Line_SMS;
//    [net doGetSuccess:^(NSDictionary *dic) {
//        NSLog(@"%@",dic);
//        if (CD_Success([dic objectForKey:@"status"], 1)) {
//            success(dic);
//        }
//        else{
//            failue(tipError(dic[@"msg"], 0));
//        }
//    } failure:^(NSError *error) {
//        NSLog(@"%@",[error debugDescription]);
//        failue(error);
//    }];
//}
//
//+ (void)registerObj:(id)obj
//            Success:(void (^)(NSDictionary *))success
//            Failure:(void (^)(NSError *))failue{
//    CDBaseNet *net = [CDBaseNet normalNet];
//    net.param = obj;
//    net.path = Line_register;
//    [net doGetSuccess:^(NSDictionary *dic) {
//        NSLog(@"%@",dic);
//        success(dic);
//        if (CD_Success([dic objectForKey:@"status"], 1)) {
//            success(dic);
//        }
//        else{
//            failue(tipError(dic[@"msg"], 0));
//        }
//    } failure:^(NSError *error) {
//        NSLog(@"%@",[error debugDescription]);
//        failue(error);
//    }];
//}


//+ (void)loginObj:(id)obj
//         Success:(void (^)(NSDictionary *))success
//         Failure:(void (^)(NSError *))failue{
//    CDBaseNet *net = [CDBaseNet normalNet];
//    net.param = obj;
//    net.path = Line_Login;
//    CDWeakSelf(self);
//    [net doGetSuccess:^(NSDictionary *dic) {
//        CDLog(@"%@",dic);
//        CDStrongSelf(self);
//        if (CD_Success([dic objectForKey:@"status"], 1)) {
//            UserModel *user = [UserModel mj_objectWithKeyValues:dic[@"data"]];
//            APP_MODEL.user = user;
//            APP_MODEL.user.isLogined = YES;
//            APP_MODEL.rongYunToken = nil;
//            [self login];
//            success(dic);
//        }
//        else{
//            failue(tipError(dic[@"msg"], 0));
//        }
//    } failure:^(NSError *error) {
//        failue(error);
//    }];
//}

//+ (void)getRYTokenSuccess:(void (^)(NSDictionary *))success
//                  Failure:(void (^)(NSError *))failue{
//    CDBaseNet *net = [CDBaseNet normalNet];
//    UserModel *user = APP_MODEL.user;
//    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
//    if (user.userId.length) {
//        [dic setObject:user.userId forKey:@"uid"];
//    }
//    if (user.userNick.length) {
//        [dic setObject:user.userNick forKey:@"name"];
//    }
//    if (user.userAvatar.length) {
//        [dic setObject:user.userAvatar forKey:@"portraitUri"];
//    }
//    net.param = dic;
//    net.path = Line_RyToken;
//    [net doGetSuccess:^(NSDictionary *dic) {
//        NSLog(@"%@",dic);
//        if (CD_Success([dic objectForKey:@"status"], 1)) {
//            APP_MODEL.rongYunToken = dic[@"data"][@"token"];
//            [APP_MODEL saveToDisk];
//            success(nil);
//        }else{
//            failue(tipError(dic[@"msg"], 0));
//        }
//    } failure:^(NSError *error) {
//        failue(error);
//    }];
//}

+ (void)updataUserObj:(id)obj
              Success:(void (^)(NSDictionary *))success
              Failure:(void (^)(NSError *))failue{
    CDBaseNet *net = [CDBaseNet normalNet];
    net.param = obj;
    net.path = Line_UpdateUserInfo;
    [net doGetSuccess:^(NSDictionary *dic) {
        CDLog(@"%@",dic);
        if (CD_Success([dic objectForKey:@"status"], 1)) {
            success(dic);
        }else{
            failue(tipError(dic[@"msg"], 0));
        }
    } failure:^(NSError *error) {
        failue(error);
    }];
}

+ (void)updataPasswordObj:(id)obj
                  Success:(void (^)(NSDictionary *))success
                  Failure:(void (^)(NSError *))failue{
    CDBaseNet *net = [CDBaseNet normalNet];
    net.param = obj;
    net.path = Line_UpdatePassword;
    [net doGetSuccess:^(NSDictionary *dic) {
        CDLog(@"%@",dic);
        if (CD_Success([dic objectForKey:@"status"], 1)) {
            success(nil);
        }else{
            failue(tipError(dic[@"msg"], 0));
        }
    } failure:^(NSError *error) {
        failue(error);
    }];
}

+ (void)wxLoginSuccess:(void (^)(NSDictionary *))success
               Failure:(void (^)(NSError *))failue{
    
    [[WXManage shareInstance] wxAuthSuccess:^(NSDictionary *info) {
        if (info != NULL) {
            [self wxLoginObj:info Success:success Failure:failue];
        }
        else{
            failue(tipError(@"服务器出错，稍后尝试~", 0));
        }
    } Failure:^(NSError *error) {
        failue(error);
    }];
}

+ (void)wxLoginObj:(id)obj
           Success:(void (^)(NSDictionary *))success
           Failure:(void (^)(NSError *))failue{
    NSDictionary *param = @{@"nickname":[obj objectForKey:@"nickname"],@"sex":[obj objectForKey:@"sex"],@"headimgurl":[obj objectForKey:@"headimgurl"],@"unionid":[obj objectForKey:@"unionid"]};
    CDBaseNet *net = [CDBaseNet normalNet];
    net.param = param;
    net.path = Line_wxLogin;
    CDWeakSelf(self);
    [net doGetSuccess:^(NSDictionary *dic) {
        CDLog(@"%@",dic);
        CDStrongSelf(self);
        if (CD_Success([dic objectForKey:@"status"], 1)) {
            UserModel *user = [UserModel mj_objectWithKeyValues:dic[@"data"]];
            APP_MODEL.user = user;
            APP_MODEL.user.isLogined = YES;
            APP_MODEL.rongYunToken = nil;
            [self login];
            success(nil);
        }
        else if (CD_Success([dic objectForKey:@"status"], 0)){
            success (param);
        }
        else{
            failue(tipError(dic[@"msg"], 0));
        }
    } failure:^(NSError *error) {
        failue(error);
    }];
}

+ (void)wxResterObj:(id)obj
            Success:(void (^)(NSDictionary *))success
            Failure:(void (^)(NSError *))failue{
    CDBaseNet *net = [CDBaseNet normalNet];
    net.param = obj;
    net.path = Line_wxRE;
    CDWeakSelf(self);
    [net doGetSuccess:^(NSDictionary *dic) {
        CDLog(@"%@",dic);
        CDStrongSelf(self);
        if (CD_Success([dic objectForKey:@"status"], 1)) {
            UserModel *user = [UserModel mj_objectWithKeyValues:dic[@"data"]];
            APP_MODEL.user = user;
            APP_MODEL.user.isLogined = YES;
            APP_MODEL.rongYunToken = nil;
            [self login];
            success(nil);
        }
        else{
            failue(tipError(dic[@"msg"], 0));
        }
    } failure:^(NSError *error) {
        failue(error);
    }];
}

+ (void)uploadIconObj:(UIImage *)icon
              Success:(void (^)(NSDictionary *))success
              Failure:(void (^)(NSError *))failue{
    CDBaseNet *net = [CDBaseNet normalNet];
    net.param = UIImagePNGRepresentation(icon);;
    net.path = Line_UpdateHead;
    [net upLoadSuccess:^(NSDictionary *dic) {
        success(dic);
    } failure:^(NSError *error) {
        failue(error);
    }];
}

+ (void)getShareConfigObj:(id)obj
                  Success:(void (^)(NSDictionary *))success
                  Failure:(void (^)(NSError *))failue{
    CDBaseNet *net = [CDBaseNet normalNet];
    net.param = obj;
    net.path = Line_Share;
    [net upLoadSuccess:^(NSDictionary *dic) {
        success(dic);
    } failure:^(NSError *error) {
        failue(error);
    }];
}

@end
