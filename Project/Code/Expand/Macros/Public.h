//
//  Public.h
//  FreeFare
//
//  Created by wc on 14-4-29.
//  Copyright (c) 2014年 wc All rights reserved.
//

#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

#define SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height//屏幕高
#define SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width//屏幕宽

#define INT_TO_STR(x) [NSString stringWithFormat:@"%ld",(long)x]

#define NUMBER_TO_STR(a) [a isKindOfClass:[NSString class]]?a:[a stringValue]

#define MERGE_String(x,y)[NSString stringWithFormat:@"%@%@",x,y]

#define NOTIF_CENTER [NSNotificationCenter defaultCenter]

#define WEAK_OBJ(weakObj,obj) __weak __typeof(obj)weakObj = obj;


typedef void (^CallbackBlock)(id object);

#define NOTIF_LOGIN_BACK @"NOTIF_LOGIN_BACK"
#define NOTIF_LOGOUT_BACK @"NOTIF_LOGOUT_BACK"

#define NOTIF_UPDATE_USER_INFO @"NOTIF_UPDATE_USER_INFO"

typedef NS_ENUM(NSUInteger, ResultCode) {
    ResultCodeSuccess = 0,//成功
};

typedef NS_ENUM(NSInteger, RewardType){
    //6000豹子顺子奖励 5000直推流水佣金 1110邀请好友充值 1100充值奖励 3000发包奖励 4000抢包奖励
    RewardType_nil,
    RewardType_bzsz = 6000,
    RewardType_ztlsyj = 5000,
    RewardType_yqhycz = 1110,
    RewardType_czjl = 1100,
    RewardType_fbjl = 3000,
    RewardType_qbjl = 4000,
};


#define WXShareDescription [NSString stringWithFormat:@"我的邀请码是%@",APP_MODEL.user.invitecode]

#define PUSH_C(viewController,targetViewController,animation) targetViewController *vc = [[targetViewController alloc] init]; vc.hidesBottomBarWhenPushed = YES; [viewController.navigationController pushViewController:vc animated:animation];


///<页面背景色
#define BaseColor HexColor(@"#F6F6F6")
///<导航栏背景色
#define Color_3 HexColor(@"#333333")
///<tab选项栏选中颜色
#define TABSelectColor HexColor(@"#a971fb")
///<分割线颜色
#define TBSeparaColor HexColor(@"#EBEBEB")
///<提交按钮颜色
#define MBTNColor HexColor(@"#FE3962")//ff3833  a971fb

#define MBTAColor(a) ApHexColor(@"#a971fb",a)
#define SexBack HexColor(@"#6cd1f1")

// 黑色
#define Color_0 HexColor(@"#1E1E1E")
#define Color_3 HexColor(@"#333333")
#define Color_6 HexColor(@"#666666")
#define Color_9 HexColor(@"#999999")
// 白色
#define Color_F HexColor(@"#FFFFFF")

// wx背景灰色
#define kBackgroundGrayColor [UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1.0]

#define COLOR_X(R,G,B) [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:1]

static NSString * const kJSPatchURL = @"https://www.520qun.com";

#define kSendRPTitleCellWidth 80


#if DEBUG
#define NSLog(FORMAT, ...) fprintf(stderr,"\nfunction:%s line:%d content:%s\n", __FUNCTION__, __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String])
#else
#define NSLog(FORMAT, ...) nil
#endif

#import "NSObject+CDCategory.h"
#import "NSObject+CDExtension.h"
#import "CDProtocol.h"
#import "UIView+CDSDImage.h"
#import "CDFunction.h"
#import "UIButton+Ani.h"
#import "Masonry.h"

#import "CDTableModel.h"
#import "MJRefresh.h"
#import "MJExtension.h"

#import "NetRequestManager.h"
#import "FunctionManager.h"

#import "Constants.h"
#import "Macros.h"
#import "VVAdaptUI.h"

#import "SuperViewController.h"

#import "AppModel.h"
#import "UserModel.h"

#import "SVProgressHUD+CDHUD.h"
#import "UIAlertController+Cus.h"

#import "AlertViewCus.h"
