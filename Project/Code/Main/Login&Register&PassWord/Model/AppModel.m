//
//  AppModel.m
//  Project
//
//  Created by mini on 2018/8/1.
//  Copyright © 2018年 CDJay. All rights reserved.
//

#import "AppModel.h"
#import "CDBaseNet.h"
#import "RongCloudManager.h"
#import "UserModel.h"
#import "WXManage.h"
//#import "SqliteManage.h"
#import "LoginViewController.h"
#import "LoginBySMSViewController.h"
#import "BANetManager_OC.h"

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
        if(instance == nil)
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
            self.turnOnSound = [RCIM sharedRCIM].disableMessageAlertSound;
        }
        self.authKey = @"Basic YXBwOmFwcA==";
    }
    return self;
}

- (void)setTurnOnSound:(BOOL)Sound{ ///<YES关闭，No开启
    _turnOnSound = Sound;
    [RCIM sharedRCIM].disableMessageAlertSound = Sound;
}

- (void)saveAppModel {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* filename = [[paths objectAtIndex:0] stringByAppendingPathComponent:Path];
    [NSKeyedArchiver archiveRootObject:self toFile:filename];
}

-(UserModel *)user{
    if(_user == nil)
        _user = [[UserModel alloc] init];
    return _user;
}

- (void)logout {
    self.user = [UserModel new];
    APP_MODEL.unReadCount = 0;
    APP_MODEL.rongYunToken = nil;
    [APP_MODEL saveAppModel];
    [self reSetRootAnimation:YES];
    [[RongCloudManager shareInstance] disConnect];
}

#pragma mark method

- (void)initSetUp{
    //融云
    [[RongCloudManager shareInstance] initWithMode];
    
    //开启消息撤回功能
    [RCIM sharedRCIM].enableMessageRecall = YES;
    //开启消息@功能（只支持群聊和讨论组, App需要实现群成员数据源groupMemberDataSource）
//    [RCIM sharedRCIM].enableMessageMentioned = YES;
    
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
    [[UIBarButtonItem appearance]setBackButtonBackgroundImage:[UIImage imageNamed:@"nav_back"] forState:UIControlStateNormal barMetrics:UIBarMetricsCompact];
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(-1000,0)
                                                         forBarMetrics:UIBarMetricsDefault];
    
    [[UINavigationBar appearance] setBackgroundColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setBarTintColor:Color_3];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setBarStyle:UIBarStyleDefault];
    [[UINavigationBar appearance] setShadowImage:[UIImage new]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize2:18],NSForegroundColorAttributeName:Color_F}];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    if(![AppModel shareInstance].isReleaseOrBeta)
        [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"navBarBg"] forBarMetrics:UIBarMetricsDefault];
    else
        [[UINavigationBar appearance] setBarTintColor:COLOR_X(70, 70, 70)];
    //COLOR_X(235, 235, 235, 1.0)
    //    [[UITabBar appearance]setTintColor:TABSelectColor];
}

-(void)login{
    if([[FUNCTION_MANAGER currentViewController] isKindOfClass:[LoginBySMSViewController class]] || [[FUNCTION_MANAGER currentViewController] isKindOfClass:[LoginViewController class]])
        [self reSetRootAnimation:YES];
}

- (UIViewController *)rootVc{
    [BANetManager initialize];
    
    if (![[NSUserDefaults standardUserDefaults]objectForKey:[NSString appVersion]]) {
        return [[NSClassFromString(@"GuideViewController") alloc]init];
    }
    else{
        if (APP_MODEL.user.isLogined) {
            return [[NSClassFromString(@"BaseTabBarController")alloc]init];
        }else{
            UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:[[NSClassFromString(@"LoginViewController")alloc]init]];
            return nav;
        }
    }
}

-(void)reSetRootAnimation:(BOOL)b{
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    if (b) {
        [window.layer addAnimation:self.animation forKey:nil];
    }
    window.rootViewController = self.rootVc;
}

- (CATransition *)animation{
    CATransition *animation = [CATransition animation];
    animation.duration = 0.5;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    animation.type =  @"cube";  //立方体效果
    
    //设置动画子类型
    animation.subtype = kCATransitionFromTop;
    return animation;
}

-(NSString *)serverUrl {
    if(_serverUrl == nil) {
#if TARGET_IPHONE_SIMULATOR
        if ([AppModel shareInstance].testVersionIndex <= 0) {
            [AppModel shareInstance].testVersionIndex = 1;
        }
        NSDictionary *dict = self.ipArray[[AppModel shareInstance].testVersionIndex];
//        _serverUrl = kServerUrlTest1;
//        _rongYunKey = kRongfYunKeyTest1;
        
        _serverUrl = dict[@"url"];
        _rongYunKey = dict[@"rongYunKey"];
        self.isReleaseOrBeta = YES;
#elif TARGET_OS_IPHONE
        _serverUrl = kServerUrl;
        _rongYunKey = kRongYunKey;
        self.isReleaseOrBeta = NO;
#endif
    } else {
        if([_serverUrl rangeOfString:@"/api"].length > 0 || [_serverUrl rangeOfString:@".com"].length > 0) {
            self.isReleaseOrBeta = NO;
        } else {
            self.isReleaseOrBeta = YES;
        }
        
        if (self.isReleaseOrBeta && ![_rongYunKey isEqualToString:kRongfYunKeyTest1]) {
            if ([AppModel shareInstance].testVersionIndex <= 0) {
                [AppModel shareInstance].testVersionIndex = 1;
            }
            NSDictionary *dict = self.ipArray[[AppModel shareInstance].testVersionIndex];
            _rongYunKey = dict[@"rongYunKey"];
//            _rongYunKey = kRongfYunKeyTest1;
        } else {
            if (!self.isReleaseOrBeta && ![_rongYunKey isEqualToString:kRongYunKey]) {
                _rongYunKey = kRongYunKey;
            }
        }
    }
    return _serverUrl;
}

-(NSString *)rongYunKey {
    [self serverUrl];
    return _rongYunKey;
}

-(NSArray *)ipArray{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSArray *arr = [ud objectForKey:@"ipArray"];
    NSDictionary *dic1 = @{@"url":kServerUrl,@"rongYunKey":kRongYunKey, @"isReleaseOrBeta":@(NO)};
    NSDictionary *dic2 = @{@"url":kServerUrlTest1,@"rongYunKey":kRongfYunKeyTest1, @"isReleaseOrBeta":@(YES)};
    NSDictionary *dic3 = @{@"url":kServerUrlTest2,@"rongYunKey":kRongfYunKeyTest2, @"isReleaseOrBeta":@(YES)};

    NSMutableArray *array = [NSMutableArray arrayWithObjects:dic1,dic2,dic3, nil];
    if(arr)
        [array addObjectsFromArray:arr];
    return array;
}
@end
