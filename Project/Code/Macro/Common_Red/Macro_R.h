//
//  Macro.h
//  Project
//
//  Created by zhyt on 2018/7/10.
//  Copyright © 2018年 CDJay. All rights reserved.
//

#ifndef Macro_h
#define Macro_h



#define Line(a) [NSString stringWithFormat:@"%@%@",Line_pre,a]


//短信
#define Line_SMS Line(@"Login/send_sms")//c
//登录
#define Line_Login Line(@"login/login")
//WX登录
#define Line_wxLogin Line(@"Login/wxLogin")
//WX注册
#define Line_wxRE Line(@"Login/wxReg")
//注册
#define Line_register Line(@"login/index")//index.php/
//融云token
#define Line_RyToken Line(@"Rongcloud/getToken")//index.php/
//客服列表
#define Line_Servicers Line(@"index/index")
//获取用户信息
#define Line_UserInfo Line(@"index/userInfo")
//更改用户信息
#define Line_UpdateUserInfo Line(@"User/update")
//上传图片
#define Line_UpdateHead Line(@"Uploader/upload")
//群组列表
#define Line_ChatGroup Line(@"Rongcloud/groupList")
//检测是否有该群组的权限
#define Line_CheckGroupState Line(@"Rongcloud/groupCheck")
//获取群组信息
#define Line_GetGroupInfo Line(@"Rongcloud/groupUserQuery")
//加入群组
#define Line_JoinGroup Line(@"Rongcloud/groupJoin")
//退出群组
#define Line_QuitGroup Line(@"Rongcloud/groupQuit")
//修改密码
#define Line_UpdatePassword Line(@"User/modifypwd")
//用户中心
#define Line_MemberInfo Line(@"User/index")
//我的玩家
#define Line_Recommended Line(@"Commission/playerList")
//消息列表
#define Line_MessageList Line(@"User/message")
//消息详情
#define Line_MessageDetail Line(@"User/detail")
//流水列表-下级玩家
#define Line_Bill Line(@"User/rebate_logs")
//转账
#define Line_Transfer Line(@"User/transferAccounts")
//流水列表-用户
#define Line_BillSELF Line(@"User/bill_logs")
//流水列表-用户(新)
#define Line_NEWBillSELF Line(@"User/bill_logs_new")
//申请提现
#define Line_Withdrawal Line(@"User/withdrawals")
//充值（新）
#define Line_TopupNew Line(@"New_pay/index")
//充值
#define Line_Topup Line(@"Pay/index")
//银行列表
#define Line_BankList Line(@"User/bank")
//发红包
#define Line_Packet Line(@"Redpacket/send")
//抢包
#define Line_GetPacket Line(@"Redpacket/grap")
//获取红包信息
#define Line_PacketInfo Line(@"Redpacket/redpacketLogs")
//获取红包状态
#define Line_PacketState Line(@"Redpacket/redpacketCheck")
//获取红包记录
#define Line_PacketHis Line(@"Redpacket/index")
//执行当天签到
#define Line_SIGN Line(@"User/sign")
//分享
#define Line_Share Line(@"Index/config")
#endif /* Macro_h */
