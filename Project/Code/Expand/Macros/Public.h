//
//  Public.h
//  FreeFare
//
//  Created by wc on 14-4-29.
//  Copyright (c) 2014年 wc All rights reserved.
//

#import "Reachability.h"

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

extern NetworkStatus networkStatus;


#define WXShareDescription [NSString stringWithFormat:@"我的邀请码是%@",APP_MODEL.user.invitecode]
//static NSString* const WXShareDescription  = @"下载抢红包,每天签到领红包最高88.88，诚招代理0成本0门槛代理每天拉群抢最高8888元";

#define PUSH_C(viewController,targetViewController,animation) targetViewController *vc = [[targetViewController alloc] init]; vc.hidesBottomBarWhenPushed = YES; [viewController.navigationController pushViewController:vc animated:animation];


///<页面背景色
#define BaseColor HexColor(@"#FAFAFA")
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

#define Color_0 HexColor(@"#1E1E1E")
#define Color_3 HexColor(@"#333333")
#define Color_6 HexColor(@"#666666")
#define Color_9 HexColor(@"#999999")
// 白色
#define Color_F HexColor(@"#FFFFFF")

// wx背景灰色
#define kBackgroundGrayColor [UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1.0]

#define COLOR_X(R,G,B) [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:1]
