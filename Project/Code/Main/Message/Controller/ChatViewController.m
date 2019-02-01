//
//  ChatViewController.m
//  Project
//
//  Created by mini on 2018/8/1.
//  Copyright © 2018年 CDJay. All rights reserved.
//

#import "ChatViewController.h"
#import "RedPackedCollectionViewCell.h"
#import "EnvelopeMessage.h"
#import "MessageNet.h"
#import "EnvelopeTipCell.h"
#import "EnvelopeTipMessage.h"
#import "SendRedPacketController.h"
#import "MessageItem.h"
#import "RedPackedAnimationView.h"
#import "GroupRuleView.h"
#import "GroupInfoViewController.h"
#import "WebViewController.h"
#import "IQKeyboardManager.h"
#import "EnvelopeNet.h"
#import "BANetManager_OC.h"
#import "ChatUserInfoController.h"
#import "SqliteManage.h"
#import <AVFoundation/AVFoundation.h>
#import "RedPackedDetListController.h"
#import "CowCowVSMessageCell.h"
#import "CowCowVSMessageModel.h"
#import "ImageDetailViewController.h"

#define CowBackImageHeight (UIScreen.mainScreen.bounds.size.height <= 568.0 ? 90 : 120)

@interface ChatViewController ()<RCPluginBoardViewDelegate,RCMessageCellDelegate>

@property (nonatomic, strong) MessageItem *messageItem;
// 红包详情模型
@property (nonatomic,strong) EnvelopeNet *enveModel;
// 抢红包视图
@property (nonatomic,strong) RedPackedAnimationView *redpView;
// 红包动画是否结束
@property (nonatomic,assign) BOOL isAnimationEnd;
// 抢红包结果数据
@property (nonatomic,assign) id response;
// 消息ID
@property (nonatomic, assign) long messageId;
// 定时器
@property (nonatomic,strong) NSTimer *timerView;

@property(nonatomic, strong) UIBarButtonItem *leftBtn;
@property(nonatomic, strong) NSArray *rightBtnArray;
//
@property (nonatomic,assign) BOOL isCreateRpView;
// 播放音乐
@property (nonatomic,strong) AVAudioPlayer *player;

// 消息体数据
@property (nonatomic,strong) RCMessageModel *messageModel;
@property (nonatomic,copy) NSString *bankerId;


@end


// 群组类
@implementation ChatViewController

static ChatViewController *_chatVC;


+ (ChatViewController *)groupChatWithObj:(MessageItem *)obj{
    
    _chatVC = [[ChatViewController alloc] initWithConversationType:ConversationType_GROUP
                                                          targetId:obj.groupId];
    //设置会话的类型，如单聊、群聊、聊天室、客服、公众服务会话等
    _chatVC.messageItem = obj;
    //设置聊天会话界面要显示的标题
    if (obj.chatgName.length > 12) {
        _chatVC.title = [NSString stringWithFormat:@"%@...", [obj.chatgName substringToIndex:12]];
    } else {
        _chatVC.title = obj.chatgName;
    }
    return _chatVC;
}

+ (ChatViewController *)currentChat {
    return _chatVC;
}

+ (void)sendCustomMessage:(id)message {
    if (_chatVC == nil) {
        return;
    }
    [_chatVC sendMessage:message pushContent:nil];
}



- (void)notifyUpdateUnreadMessageCount {
    if (self.allowsMessageCellSelection) {
        [super notifyUpdateUnreadMessageCount];
        return;
    }
    // 解决点击 更多... 取消返回不了的bug
    self.navigationItem.leftBarButtonItem = self.leftBtn;
    self.navigationItem.rightBarButtonItems = self.rightBtnArray;
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self initSubviews];
    [self initLayout];
    
    self.enveModel = [EnvelopeNet shareInstance];
    self.enableUnreadMessageIcon = YES;
    self.enableNewComingMessageIcon = YES;
    
    [self unreadMessage];
    
    self.leftBtn = self.navigationItem.leftBarButtonItem;
    self.rightBtnArray = self.navigationItem.rightBarButtonItems;
    self.isCreateRpView = NO;
    
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(action_VSViewSeeDetails:) name:@"VSViewSeeDetailsNoticafication" object:nil];
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

/**
 VS 视图查看详情
 */
- (void)action_VSViewSeeDetails:(NSNotification *)notification {
    NSDictionary *infoDic = [notification object];
    RCMessageModel *model = (RCMessageModel *)[infoDic objectForKey:@"VS_messageModel"];
    CowCowVSMessageModel *cow = (CowCowVSMessageModel *)model.content;
    NSDictionary *dict = (NSDictionary *)cow.content.mj_JSONObject;
    self.bankerId = [NSString stringWithFormat:@"%@", [dict objectForKey:@"userId"]];
    
    [self vsViewGetRedPacketDetailsData:[dict objectForKey:@"id"]];
}


- (void)unreadMessage {
    [SqliteManage updateGroup:_messageItem.groupId number:0 lastMessage:@"暂无未读消息"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
    [[IQKeyboardManager sharedManager]setEnable:NO];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [IQKeyboardManager sharedManager].enableAutoToolbar = YES;
    [[IQKeyboardManager sharedManager]setEnable:YES];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"CDReadNumberChange" object:nil];
    self.isCreateRpView = NO;
}



#pragma mark - Layout
- (void)initLayout {
    
}


#pragma mark - subView
- (void)initSubviews {
    
    [self chatBarControl];
    [self setBtnUI];
    
}

- (void)chatBarControl {
    self.conversationMessageCollectionView.backgroundColor = BaseColor;
    self.chatSessionInputBarControl.pluginBoardView.pluginBoardDelegate = self;
    [self registerClass:[RedPackedCollectionViewCell class] forMessageClass:[EnvelopeMessage class]];
    [self registerClass:[EnvelopeTipCell class] forMessageClass:[EnvelopeTipMessage class]];
    [self registerClass:[CowCowVSMessageCell class] forMessageClass:[CowCowVSMessageModel class]];
    
    
#pragma mark pluginBoardView
    [self.chatSessionInputBarControl.pluginBoardView removeItemAtIndex:2];
    [self.chatSessionInputBarControl.pluginBoardView removeItemAtIndex:2];
    //    [self.chatSessionInputBarControl.pluginBoardView removeItemAtIndex:0];
    //    [self.chatSessionInputBarControl.pluginBoardView removeItemAtIndex:0];
    
    
    //    [self.chatSessionInputBarControl.pluginBoardView updateItemAtIndex:2 image:[UIImage imageNamed:@"chart-redpck"] title:@"红包"];
    //    NSInteger h  = 20;
    //    CGRect rect = self.chatSessionInputBarControl.frame;
    //    rect.size.height += h;
    //    self.chatSessionInputBarControl.frame = rect;
    //    rect = self.chatSessionInputBarControl.inputTextView.frame;
    //    rect.size.height += h;
    //    self.chatSessionInputBarControl.inputTextView.frame = rect;
    
    [self.chatSessionInputBarControl.pluginBoardView insertItemWithImage:[UIImage imageNamed:@"csb_welfare"] title:@"福利" atIndex:0 tag:2000];
    [self.chatSessionInputBarControl.pluginBoardView insertItemWithImage:[UIImage imageNamed:@"csb_rule"] title:@"群规" atIndex:1 tag:2001];
    [self.chatSessionInputBarControl.pluginBoardView insertItemWithImage:[UIImage imageNamed:@"csb_tuo_redpocket"] title:@"红包" atIndex:2 tag:2002];
    [self.chatSessionInputBarControl.pluginBoardView insertItemWithImage:[UIImage imageNamed:@"csb_Lord"] title:@"群主" atIndex:3 tag:2003];
    [self.chatSessionInputBarControl.pluginBoardView insertItemWithImage:[UIImage imageNamed:@"csb_tuo_bill"] title:@"账单" atIndex:4 tag:2004];
    [self.chatSessionInputBarControl.pluginBoardView insertItemWithImage:[UIImage imageNamed:@"csb_refill"] title:@"充值" atIndex:5 tag:2005];
    [self.chatSessionInputBarControl.pluginBoardView insertItemWithImage:[UIImage imageNamed:@"csb_extract"] title:@"提现" atIndex:6 tag:2006];
    [self.chatSessionInputBarControl.pluginBoardView insertItemWithImage:[UIImage imageNamed:@"csb_tuo_customer_service"] title:@"客服" atIndex:7 tag:2007];
    
    [self.chatSessionInputBarControl.pluginBoardView updateItemAtIndex:8 image:[UIImage imageNamed:@"csb_photo_album"] title:@"照片"];
    [self.chatSessionInputBarControl.pluginBoardView updateItemAtIndex:9 image:[UIImage imageNamed:@"csb_camera"] title:@"拍照"];
}

- (void)setBtnUI {
    UIButton *redpiconBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 44, 44)];
    [redpiconBtn setImage:[UIImage imageNamed:@"redPacketIcon"] forState:UIControlStateNormal];
    redpiconBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [redpiconBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [redpiconBtn addTarget:self action:@selector(goto_sendRedpiconEnt) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *exItem = [[UIBarButtonItem alloc]initWithCustomView:redpiconBtn];
    
    UIButton *info = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 44, 44)];
    [info setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [info setImage:[UIImage imageNamed:@"group-info"] forState:UIControlStateNormal];
    
    [info addTarget:self action:@selector(goto_GroupInfo) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *infoItem = [[UIBarButtonItem alloc]initWithCustomView:info];
    
    self.navigationItem.rightBarButtonItems = @[infoItem,exItem];
}



#pragma mark RCPluginBoardViewDelegate 聊天功能扩展拦
- (void)pluginBoardView:(RCPluginBoardView *)pluginBoardView clickedItemWithTag:(NSInteger)tag{
    NSLog(@"%ld",tag);
    [self.view endEditing:YES];
    if (tag == 2000) { //福利红包
        SendRedPacketController *vc = [[SendRedPacketController alloc] init];
        vc.isFu = YES;
        vc.CDParam = _messageItem;
        UINavigationController *navvc = [[UINavigationController alloc]initWithRootViewController:vc];
        [self presentViewController:navvc animated:YES completion:nil];
        
    } else if (tag == 2001){ // 群规
        [self groupRuleView];
    } else if (tag == 2002){
        UINavigationController *vc = [[UINavigationController alloc]initWithRootViewController:CDPVC(@"SendRedPacketController", _messageItem)];
        [self presentViewController:vc animated:YES completion:nil];
    } else if (tag == 2003){
        WebViewController *vc = [[WebViewController alloc]initWithUrl:ServiceLink];
        vc.title = @"在线客服";
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
        
    } else if (tag == 2004){
        UIViewController *vc = [[NSClassFromString(@"BillViewController")alloc]init];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
        
    } else if (tag == 2005){
        UIViewController *vc = [[NSClassFromString(@"TopupViewController")alloc]init];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    } else if (tag == 2006){
        UIViewController *vc = [[NSClassFromString(@"WithdrawalViewController")alloc]init];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    } else if (tag == 2007){
        WebViewController *vc = [[WebViewController alloc]initWithUrl:ServiceLink];
        vc.title = @"在线客服";
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    } else if (tag == 1001){
        SVP_ERROR_STATUS(@"此功能暂停使用");
    } else if (tag == 1002){
        SVP_ERROR_STATUS(@"此功能暂停使用");
    } else {
        [super pluginBoardView:pluginBoardView clickedItemWithTag:tag];
    }
    
}

#pragma mark -  群规
- (void)groupRuleView {
//    GroupRuleView *view = [[GroupRuleView alloc]initWithFrame:self.view.bounds];
//    [view updateView:self.messageItem];
//    [view showInView:self.view];
    
    ImageDetailViewController *vc = [[ImageDetailViewController alloc] init];
    vc.imageUrl = self.messageItem.ruleImg;
    vc.title = @"群规";
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark data
- (void)updateCustomMessageInfo:(RCMessageModel *)model{
    
}



#pragma mark - override Cell点击事件
// cell点击事件
- (void)didTapMessageCell:(RCMessageModel *)model {
    [super didTapMessageCell:model];
    self.messageModel = model;
    self.bankerId = self.messageModel.senderUserId;
    if ([model.content isKindOfClass:[EnvelopeMessage class]]) {
        if (self.isCreateRpView) {
            return;
        }
        self.isCreateRpView = YES;
        NSInteger cellStatus = [model.extra.mj_JSONObject[[NSString stringWithFormat:@"cellStatus-%@", APP_MODEL.user.userId]] integerValue];   // <默认0没有点击，1已点击
        //        EnvelopeMessage *message = (EnvelopeMessage *)model.content;
        //        NSString *redpId = [NSString stringWithFormat:@"%@", message.content.mj_JSONObject[@"redpacketId"]];
        
        [self getRedPacketDetailsData:model cellStatus:cellStatus];
    } else if ([model.content isKindOfClass:[CowCowVSMessageModel class]]) {
        // 查看详情
        NSLog(@"1111");
    }
}


#pragma mark 获取红包详情
/**
 获取红包详情
 
 @param messageModel RCMessageModel
 */
- (void)getRedPacketDetailsData:(RCMessageModel *)messageModel cellStatus:(NSInteger)cellStatus {
    
    EnvelopeMessage *enveMessageModel = (EnvelopeMessage*)messageModel.content;
    NSDictionary *dict = enveMessageModel.content.mj_JSONObject;
    NSLog(@"-----------%@", [NSThread currentThread]);
    SVP_SHOW;
    __weak __typeof(self)weakSelf = self;
    [_enveModel getRedpDetSendId:[dict objectForKey:@"redpacketId"] successBlock:^(NSDictionary *success) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        SVP_DISMISS;
        if ([[success objectForKey:@"code"] integerValue] == 0) {
            if (cellStatus == 1) {
                [strongSelf goto_RedPackedDetail:strongSelf.enveModel];
            } else {
                [strongSelf actionShowRedPackedView:messageModel packetId:strongSelf.enveModel.redPackedInfoDetail[@"id"]];
            }
        } else {
            strongSelf.isCreateRpView = NO;
            SVP_ERROR_STATUS([success objectForKey:@"msg"]);
        }
        
        
    } failureBlock:^(NSError *error) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        SVP_DISMISS;
        strongSelf.isCreateRpView = NO;
        //        __strong __typeof(weakSelf)strongSelf = weakSelf;
        SVP_ERROR_STATUS(kSystemBusyMessage);
    }];
    
}

- (void)vsViewGetRedPacketDetailsData:(NSString *)redpId {
    
    SVP_SHOW;
    __weak __typeof(self)weakSelf = self;
    [_enveModel getRedpDetSendId:redpId successBlock:^(NSDictionary *success) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        SVP_DISMISS;
        if ([[success objectForKey:@"code"] integerValue] == 0) {
            [strongSelf goto_RedPackedDetail:strongSelf.enveModel];
        } else {
            SVP_ERROR_STATUS([success objectForKey:@"msg"]);
        }
    } failureBlock:^(NSError *error) {
        SVP_DISMISS;
        //        __strong __typeof(weakSelf)strongSelf = weakSelf;
        SVP_ERROR_STATUS(kSystemBusyMessage);
    }];
    
}

- (void)didSendMessage:(NSInteger)status content:(RCMessageContent *)messageContent{
    [super didSendMessage:status content:messageContent];
    NSString *text = @"暂无未读消息";
    if ([messageContent isKindOfClass:[RCTextMessage class]]) {
        RCTextMessage *content = (RCTextMessage *)messageContent;
        text = content.content;
    }
    else if ([messageContent isKindOfClass:[RCImageMessage class]]){
        text = @"【图片】";
    }else if ([messageContent isKindOfClass:[RCVoiceMessage class]]){
        text = @"【语音】";
    }else if ([messageContent isKindOfClass:[EnvelopeMessage class]]){
        text = @"【红包】";
    } else if ([messageContent isKindOfClass:[EnvelopeTipMessage class]]){
        text = @"自定义系统通知";
    } else {
        text = @"暂无未读消息";
    }
    
}

#pragma mark - 点击头像事件
// 点击头像事件
- (void)didTapCellPortrait:(NSString *)userId {
    [self.view endEditing:YES];
    ChatUserInfoController *vc = [[ChatUserInfoController alloc] init];
    vc.userId = userId;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark 抢红包
- (void)action_tapCustom:(RCMessageModel *)messageModel {
    
    EnvelopeMessage *message = (EnvelopeMessage*)messageModel.content;
    NSDictionary *dic = message.content.mj_JSONObject;
    //    CGFloat multiple = [_messageItem.skRuleBombModel.ruleBombHandicap floatValue];
    
    //    if ([[dic objectForKey:@"type"] integerValue] == 1) {
    //        CGFloat money = [[dic objectForKey:@"money"] floatValue];
    //        CGFloat e = [APP_MODEL.user.balance floatValue];
    //        if ((money * multiple) > e) {
    //            SVP_ERROR_STATUS(kGrabpackageNoMoneyMessage);
    //            return;
    //        }
    //    }
    
    BADataEntity *entity = [BADataEntity new];
    entity.urlString = [NSString stringWithFormat:@"%@%@?type=%@&packetId=%@",APP_MODEL.serverUrl,@"social/redpacket/grab",[dic objectForKey:@"type"],[dic objectForKey:@"redpacketId"]];
    entity.needCache = NO;
    
    
    _timerView = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(uploadTimer:) userInfo:nil repeats:NO];
    
    //    SVP_SHOW;
    __weak __typeof(self)weakSelf = self;
    [BANetManager ba_request_POSTWithEntity:entity successBlock:^(id response) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        //        SVP_DISMISS;
        //        NSLog(@"post 请求数据结果： *** %@", response);
        
        strongSelf.response = response;
        strongSelf.messageId = messageModel.messageId;
        [strongSelf redPackedStatusJudgmentResponse:response messageModel:messageModel.messageId];
        
    } failureBlock:^(NSError *error) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        //        SVP_DISMISS;
        [strongSelf uploadTimer:nil];
        SVP_ERROR_STATUS(kSystemBusyMessage);
        [strongSelf.redpView disMissRedView];
        //        [FUNCTION_MANAGER handleFailResponse:error];
    } progressBlock:nil];
    
}


- (AVAudioPlayer *)player {
    if (!_player) {
        // 1. 创建播放器对象
        // 虽然传递的参数是NSURL地址, 但是只支持播放本地文件, 远程音乐文件路径不支持
        NSURL *url = [[NSBundle mainBundle]URLForResource:@"success.mp3" withExtension:nil];
        _player = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:nil];
        
        //允许调整速率,此设置必须在prepareplay 之前
        _player.enableRate = YES;
        //        _player.delegate = self;
        
        //指定播放的循环次数、0表示一次
        //任何负数表示无限播放
        [_player setNumberOfLoops:0];
        //准备播放
        [_player prepareToPlay];
        
    }
    return _player;
}



-(void)uploadTimer:(NSTimer*)timer {
    self.isAnimationEnd = YES;
    
    if (self.response != nil) {
        [self redPackedStatusJudgmentResponse:self.response messageModel:self.messageId];
    }
    
    if (_timerView != nil) {
        [_timerView invalidate];
    }
}


#pragma mark -  抢包视图动画结束
/**
 红包动画判断
 */
- (void)redpackedAnimationJudgment {
    if (self.response != nil) {
        [self redPackedStatusJudgmentResponse:self.response messageModel:self.messageId];
    }
}


#pragma mark -  抢包后红包状态判断
- (void)redPackedStatusJudgmentResponse:(id)response messageModel:(long)messageId {
    
    if (self.isAnimationEnd == NO) {
        return;
    }
    
    NSInteger code = [[response objectForKey:@"code"] integerValue];
    if (code == 0) {
        // 正常
        [self.redpView disMissRedView];
        [self goto_RedPackedDetail:self.enveModel];
        [self updateRedPackedStatus:messageId cellStatus:@"1"];
        
        NSString *switchKeyStr = [NSString stringWithFormat:@"%@-%@", APP_MODEL.user.userId,_messageItem.groupId];
        // 读取
        BOOL  isSwitch = [[NSUserDefaults standardUserDefaults] boolForKey:switchKeyStr];
        if (!isSwitch && ![AppModel shareInstance].turnOnSound) {
#if TARGET_IPHONE_SIMULATOR
#elif TARGET_OS_IPHONE
            [self.player play];
#endif
        }
        
    } else if (code == 11) {
        // 红包已抢完
        [self.redpView updateView:_enveModel.redPackedInfoDetail response:response];
        [self updateRedPackedStatus:messageId cellStatus:@"2"];
        
    } else if (code == 12) {
        // 已抢过红包
        [self.redpView updateView:_enveModel.redPackedInfoDetail response:response];
        [self updateRedPackedStatus:messageId cellStatus:@"1"];
        
    } else if (code == 13) {
        [self.redpView updateView:_enveModel.redPackedInfoDetail response:response];
        // 余额不足
    } else if (code == 14) {
        [self.redpView updateView:_enveModel.redPackedInfoDetail response:response];
        // 通讯异常，请重试
    } else if (code == 15) {
        [self.redpView updateView:_enveModel.redPackedInfoDetail response:response];
        // 单个红包金额不足0.01
    } else if (code == 16) {
        [self.redpView updateView:_enveModel.redPackedInfoDetail response:response];
        // 红包已逾期
        [self updateRedPackedStatus:messageId cellStatus:@"3"];
    } else if (code == 17) {
        [self.redpView updateView:_enveModel.redPackedInfoDetail response:response];
    } else {
        [self.redpView updateView:_enveModel.redPackedInfoDetail response:response];
    }
    
}


/**
 抢红包视图
 
 @param messageModel 红包信息
 @param packetId 红包ID
 */
- (void)actionShowRedPackedView:(RCMessageModel *)messageModel packetId:(NSString *)packetId {
    self.isAnimationEnd = NO;
    RedPackedAnimationView *view = [[RedPackedAnimationView alloc]initWithFrame:self.view.bounds];
    [view updateView:_enveModel.redPackedInfoDetail response:nil];
    self.redpView = view;
    
    __weak __typeof(self)weakSelf = self;
    
    // 开红包
    view.openBtnBlock = ^{
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf action_tapCustom:messageModel];
    };
    // 查看详情
    view.detailBlock = ^{
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf goto_RedPackedDetail:strongSelf.enveModel];
    };
    // 视图消失
    view.animationBlock = ^{
        //        [self updateRedPackedStatus:messageModel.messageId cellStatus:@"1"];
        return ;
    };
    // 动画结束Block
    view.animationEndBlock = ^{
        //        __strong __typeof(weakSelf)strongSelf = weakSelf;
        //        strongSelf.isAnimationEnd = YES;
        //        [strongSelf redpackedAnimationJudgment];
        return ;
    };
    // View消失Block
    view.disMissRedBlock = ^{
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        strongSelf.isCreateRpView = NO;
        return ;
    };
    
    NSInteger status = [[_enveModel.redPackedInfoDetail objectForKey:@"status"] integerValue];
    NSInteger left = [[_enveModel.redPackedInfoDetail objectForKey:@"left"] integerValue];
    
    if (status == 2) {
        [self updateRedPackedStatus:messageModel.messageId cellStatus:@"3"];
    }
    if (status == 1 && left == 0) {
        [self updateRedPackedStatus:messageModel.messageId cellStatus:@"2"];
    }
    
    [view showInView:self.view];
}

/**
 更新红包状态
 
 @param messageId 消息ID
 @param cellStatus 红包状态 0 没有点击(红包没抢)  1 已点击(红包已抢)  2 已点击(红包已抢完） 3 已点击(红包已过期)
 */
- (void)updateRedPackedStatus:(long)messageId cellStatus:(NSString *)cellStatus {
    
    for (RCMessageModel *model in self.conversationDataRepository) {
        if (messageId == model.messageId) {
            
            NSDictionary *dic = @{[NSString stringWithFormat:@"cellStatus-%@", APP_MODEL.user.userId]:cellStatus};
            NSString *str = [dic mj_JSONString];
            model.extra = str;
            [[RCIMClient sharedRCIMClient] setMessageExtra:messageId value:str];
            break;
        }
    }
    [self.conversationMessageCollectionView reloadData];
}

#pragma mark -  goto红包详情
- (void)goto_RedPackedDetail:(id)obj{
    [self.view endEditing:YES];
    //    CDPush(self.navigationController, CDPVC(@"RedPackedDetListController", obj), YES);
    
    RedPackedDetListController *vc = [[RedPackedDetListController alloc] init];
    vc.isRightBarButton = YES;
    vc.objPar = obj;
    vc.bankerId = self.bankerId;
    vc.returnPackageTime = [_messageItem.rpOverdueTime floatValue];
    [self.navigationController pushViewController:vc animated:YES];
    
}


#pragma mark goto发红包入口
/**
 发红包入口
 */
-(void)goto_sendRedpiconEnt {
    [self.view endEditing:YES];
    UINavigationController *vc = [[UINavigationController alloc]initWithRootViewController:CDPVC(@"SendRedPacketController", _messageItem)];
    [self presentViewController:vc animated:YES completion:nil];
    
}


#pragma mark Group info 群信息
/**
 Group Info
 */
- (void)goto_GroupInfo {
    [self.view endEditing:YES];
    GroupInfoViewController *vc = [GroupInfoViewController groupVc:_messageItem];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)leftBarButtonItemPressed:(id)sender{
    [super leftBarButtonItemPressed:sender];
}

- (void)didMoveToParentViewController:(UIViewController*)parent{
    [super didMoveToParentViewController:parent];
    NSLog(@"%s,%@",__FUNCTION__,parent);
    if(!parent){
        _chatVC = nil;
        
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGSize size = [super collectionView:collectionView layout:collectionViewLayout sizeForItemAtIndexPath:indexPath];
    NSLog(@"size = %@",NSStringFromCGSize(size));
    RCMessageModel *model = self.conversationDataRepository[indexPath.row];
    RCTextMessage *textMessage = (RCTextMessage *)model.content;
    RCUserInfo *user = textMessage.senderUserInfo;
    if([textMessage isKindOfClass:[RCTextMessage class]]){
        NSString *conten = textMessage.content;
        if([conten isEqualToString:RedPacketString]){
            NSString *extra = textMessage.extra;
            NSDictionary *dict = [extra mj_JSONObject];
            EnvelopeMessage *messageCus = [[EnvelopeMessage alloc] initWithObj:dict];
            if(user.userId == nil)
                user.userId = model.senderUserId;
            messageCus.senderUserInfo = user;
            model.content = messageCus;
        } else if([conten isEqualToString:CowCowMessageString]){
            NSString *extra = textMessage.extra;
            NSDictionary *dict = [extra mj_JSONObject];
            CowCowVSMessageModel *messageCus = [[CowCowVSMessageModel alloc] initWithObj:dict];
            if(user.userId == nil)
                user.userId = model.senderUserId;
            messageCus.senderUserInfo = user;
            model.content = messageCus;
        }
    }
    if([model.content isKindOfClass:[EnvelopeMessage class]]){
        NSInteger height = 94;
        model.content.senderUserInfo.userId = model.senderUserId;
        if(model.isDisplayMessageTime)
            height += 45;
        if(model.isDisplayNickname)
            height += 22;
        return CGSizeMake([[UIScreen mainScreen] bounds].size.width, height);
    } else if([model.content isKindOfClass:[CowCowVSMessageModel class]]){
        NSInteger height = 60 + 10;
        model.content.senderUserInfo.userId = model.senderUserId;
        if(model.isDisplayMessageTime) {
            height += 45;
        }
        return CGSizeMake([[UIScreen mainScreen] bounds].size.width, CowBackImageHeight + height);
    }
    return size;
}


/*!
 自定义消息Cell显示的回调
 
 @param collectionView  当前CollectionView
 @param indexPath       该Cell对应的消息Cell数据模型在数据源中的索引值
 @return                自定义消息需要显示的Cell
 
 @discussion 自定义消息如果需要显示，则必须先通过RCIM的registerMessageType:注册该自定义消息类型，
 并在聊天界面中通过registerClass:forCellWithReuseIdentifier:注册该自定义消息的Cell，否则将此回调将不会被调用。
 */
- (RCMessageBaseCell *)rcConversationCollectionView:(UICollectionView *)collectionView
                             cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    EnvelopeTipCell *cell = [[EnvelopeTipCell alloc] init];
    return cell;
}

/*!
 自定义消息Cell显示的回调
 
 @param collectionView          当前CollectionView
 @param collectionViewLayout    当前CollectionView Layout
 @param indexPath               该Cell对应的消息Cell数据模型在数据源中的索引值
 @return                        自定义消息Cell需要显示的高度
 
 @discussion 自定义消息如果需要显示，则必须先通过RCIM的registerMessageType:注册该自定义消息类型，
 并在聊天界面中通过registerClass:forCellWithReuseIdentifier:注册该自定义消息的Cell，否则将此回调将不会被调用。
 */
- (CGSize)rcConversationCollectionView:(UICollectionView *)collectionView
                                layout:(UICollectionViewLayout *)collectionViewLayout
                sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGSize size = [super rcConversationCollectionView:collectionView layout:collectionViewLayout sizeForItemAtIndexPath:indexPath];
    
    return CGSizeMake(size.width, 100);
}



- (RCMessage *)willAppendAndDisplayMessage:(RCMessage *)message {
    RCTextMessage *textMessage = (RCTextMessage *)message.content;
    RCUserInfo *user = textMessage.senderUserInfo;
    
    if([textMessage isKindOfClass:[RCTextMessage class]]){  // 推送一个消息过来
        NSString *conten = textMessage.content;
        if([conten isEqualToString:RedPacketString]){
            NSString *extra = textMessage.extra;
            NSDictionary *dict = [extra mj_JSONObject];
            EnvelopeMessage *messageCus = [[EnvelopeMessage alloc] initWithObj:dict];
            if(user.userId == nil)
                user.userId = message.senderUserId;
            messageCus.senderUserInfo = user;
            message.content = messageCus;
        } else  if([conten isEqualToString:CowCowMessageString]){
            NSString *extra = textMessage.extra;
            NSDictionary *dict = [extra mj_JSONObject];
            CowCowVSMessageModel *messageCus = [[CowCowVSMessageModel alloc] initWithObj:dict];
            if(user.userId == nil)
                user.userId = message.senderUserId;
            messageCus.senderUserInfo = user;
            message.content = messageCus;
        }
    }
    return message;
}
@end


