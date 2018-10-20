//
//  ChatViewController.m
//  Project
//
//  Created by mini on 2018/8/1.
//  Copyright © 2018年 CDJay. All rights reserved.
//

#import "ChatViewController.h"
#import "EnvelopeCollectionViewCell.h"
#import "EnvelopeMessage.h"
#import "MessageNet.h"
#import "EnvelopeTipCell.h"
#import "EnvelopeTipMessage.h"
#import "EnvelopeViewController.h"
#import "MessageItem.h"
#import "EnvelopAnimationView.h"
#import "GroupInfoViewController.h"
#import "WebViewController.h"
#import "IQKeyboardManager.h"
#import "EnvelopeNet.h"
#import "SqliteManage.h"

@interface ChatViewController ()<RCPluginBoardViewDelegate,RCMessageCellDelegate>

@property (nonatomic, strong) MessageItem *messageItem;

@end

@implementation ChatViewController

static ChatViewController *_chatVC;


+ (ChatViewController *)groupChatWithObj:(MessageItem *)obj{
    
    _chatVC = [[ChatViewController alloc] initWithConversationType:ConversationType_GROUP
                                                          targetId:obj.groupId];
    //设置会话的类型，如单聊、群聊、聊天室、客服、公众服务会话等
    
    _chatVC.messageItem = obj;
    //设置聊天会话界面要显示的标题
    [SqliteManage updateGroup:obj.groupId number:0 lastMessage:nil];
    _chatVC.title = obj.groupName;
    return _chatVC;
}

+ (ChatViewController *)currentChat{
    return _chatVC;
}

+ (void)sendCustomMessage:(id)message{
    if (_chatVC == nil) {
        return;
    }
    [_chatVC sendMessage:message pushContent:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self initSubviews];
    [self initLayout];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
    [[IQKeyboardManager sharedManager]setEnable:NO];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [IQKeyboardManager sharedManager].enableAutoToolbar = YES;
    [[IQKeyboardManager sharedManager]setEnable:YES];
}

#pragma mark ----- Data
- (void)initData{
    
}


#pragma mark ----- Layout
- (void)initLayout{
    
}


#pragma mark ----- subView
- (void)initSubviews{
    
    self.conversationMessageCollectionView.backgroundColor = BaseColor;
    self.chatSessionInputBarControl.pluginBoardView.pluginBoardDelegate = self;
    [self registerClass:[EnvelopeCollectionViewCell class] forMessageClass:[EnvelopeMessage class]];
    [self registerClass:[EnvelopeTipCell class] forMessageClass:[EnvelopeTipMessage class]];
    
#pragma mark pluginBoardView
    [self.chatSessionInputBarControl.pluginBoardView removeItemAtIndex:2];
    [self.chatSessionInputBarControl.pluginBoardView updateItemAtIndex:0 image:[UIImage imageNamed:@"chart-pic"] title:@"照片"];
    [self.chatSessionInputBarControl.pluginBoardView updateItemAtIndex:1 image:[UIImage imageNamed:@"chart-phone"] title:@"拍照"];
    [self.chatSessionInputBarControl.pluginBoardView updateItemAtIndex:2 image:[UIImage imageNamed:@"chart-redpck"] title:@"红包"];
    [self.chatSessionInputBarControl.pluginBoardView insertItemWithImage:[UIImage imageNamed:@"chart-group"] title:@"群主" atIndex:4 tag:2000];
    [self.chatSessionInputBarControl.pluginBoardView insertItemWithImage:[UIImage imageNamed:@"chart-bill"] title:@"账单" atIndex:5 tag:2001];
    [self.chatSessionInputBarControl.pluginBoardView insertItemWithImage:[UIImage imageNamed:@"chart-pay"] title:@"充值" atIndex:6 tag:2002];
    [self.chatSessionInputBarControl.pluginBoardView insertItemWithImage:[UIImage imageNamed:@"chart-cash"] title:@"提现" atIndex:7 tag:2003];
    [self.chatSessionInputBarControl.pluginBoardView insertItemWithImage:[UIImage imageNamed:@"chart-service"] title:@"客服" atIndex:8 tag:2004];
    
    UIButton *exBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 44, 30)];
    [exBtn setImage:[UIImage imageNamed:@"delete-icon"] forState:UIControlStateNormal];
    exBtn.titleLabel.font = [UIFont scaleFont:12];
    [exBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [exBtn addTarget:self action:@selector(action_exitGroup) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *exItem = [[UIBarButtonItem alloc]initWithCustomView:exBtn];
    
    UIButton *info = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 44, 30)];
    [info setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [info setImage:[UIImage imageNamed:@"group-info"] forState:UIControlStateNormal];
    
    [info addTarget:self action:@selector(action_info) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *infoItem = [[UIBarButtonItem alloc]initWithCustomView:info];
    
    self.navigationItem.rightBarButtonItems = @[infoItem,exItem];
}

#pragma mark RCPluginBoardViewDelegate
- (void)pluginBoardView:(RCPluginBoardView *)pluginBoardView clickedItemWithTag:(NSInteger)tag{
    NSLog(@"%ld",tag);
    if (tag == 1104) {//红包        
        UINavigationController *vc = [[UINavigationController alloc]initWithRootViewController:CDPVC(@"EnvelopeViewController", _messageItem)];
        [self presentViewController:vc animated:YES completion:nil];
    }
    else if (tag == 2000){
        WebViewController *vc = [[WebViewController alloc]initWithUrl:ServiceLink];
        vc.title = @"在线客服";
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (tag == 2001){
        UIViewController *vc = [[NSClassFromString(@"BillViewController")alloc]init];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (tag == 2002){
        UIViewController *vc = [[NSClassFromString(@"TopupViewController")alloc]init];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (tag == 2003){
        UIViewController *vc = [[NSClassFromString(@"TopupViewController")alloc]init];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (tag == 2004){
        WebViewController *vc = [[WebViewController alloc]initWithUrl:ServiceLink];
        vc.title = @"在线客服";
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else
        [super pluginBoardView:pluginBoardView clickedItemWithTag:tag];
}

#pragma mark data
- (void)updateCustomMessageInfo:(RCMessageModel *)model{
    
}

#pragma mark override
//cell点击事件
- (void)didTapMessageCell:(RCMessageModel *)model {
    [super didTapMessageCell:model];
    if ([model.content isKindOfClass:[EnvelopeMessage class]]) {
        NSInteger type = [model.extra.mj_JSONObject[@"type"] integerValue];///<默认0没有点击，1已点击
        if (type == 0) {
            [self action_tapCustom:model];
        }else{
            EnvelopeMessage *message = (EnvelopeMessage *)model.content;
            [self actionEnvelopDetail:message.content.mj_JSONObject[@"redpacketId"]];
        }
    }
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
    }
    else
        text = @"暂无未读消息";
    [SqliteManage updateGroup:_messageItem.groupId number:0 lastMessage:text];
}

//头像点击事件
- (void)didTapCellPortrait:(NSString *)userId {
    NSLog(@"点击了头像");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark action
- (void)action_tapCustom:(RCMessageModel *)obj{
    EnvelopeMessage *message = (EnvelopeMessage*)obj.content;
    NSDictionary *dic = message.content.mj_JSONObject;
    CGFloat multiple = [_messageItem.multiple floatValue];
    CGFloat money = [[dic objectForKey:@"money"] floatValue];
    CGFloat e = [APP_MODEL.user.userBalance floatValue];
    if ((money * multiple) >e) {
        SV_ERROR_STATUS(@"余额不足，请充值~");
        return;
    }
    SV_SHOW;
    CDWeakSelf(self);
    [EnvelopeNet getEnvelopInfo:@{@"uid":APP_MODEL.user.userId,@"redpacketId":[dic objectForKey:@"redpacketId"]} Success:^(NSDictionary *info) {
        CDStrongSelf(self);
        SV_DISMISS;
        NSMutableDictionary *eMessage = [[NSMutableDictionary alloc]initWithDictionary:info];
        [eMessage setObject:@(obj.messageId) forKey:@"messageId"];
        [self actionShowEnvelop:eMessage];
    } Failure:^(NSError *error) {
        SV_ERROR(error);
    }];
}

- (void)actionShowEnvelop:(id)obj{
    
    NSInteger num = [[obj objectForKey:@"num"] integerValue];
    NSInteger messageId = [[obj objectForKey:@"messageId"] integerValue];
    NSInteger left = [[obj objectForKey:@"left"] integerValue];
    NSInteger status = [[obj objectForKey:@"status"] integerValue];
    
    EnvelopAnimationView *view = [[EnvelopAnimationView alloc]initWithFrame:self.view.bounds];
    [view updateView:obj];
    
    CDWeakSelf(self);
    view.block = ^{
        CDStrongSelf(self);
        for (RCMessageModel *model in self.conversationDataRepository) {
            if (messageId == model.messageId) {
                NSDictionary *dic = @{@"type":@"1"};
                NSString *str = [dic mj_JSONString];
                model.extra = str;
                [[RCIMClient sharedRCIMClient]setMessageExtra:messageId value:str];
                break;
            }
        }
        [self.conversationMessageCollectionView reloadData];
        [self actionEnvelopDetail:obj[@"id"]];
        return ;
    };
    view.detail = ^{
        CDStrongSelf(self);
        [self actionEnvelopDetail:obj[@"id"]];
    };
    if ((status == 0) | (left == num)) {///<已过期、已被领取
        CDStrongSelf(self);
        for (RCMessageModel *model in self.conversationDataRepository) {
            if (messageId == model.messageId) {
                NSDictionary *dic = @{@"type":@"1"};
                model.extra = [dic mj_JSONString];
                [[RCIMClient sharedRCIMClient]setMessageExtra:messageId value:[dic mj_JSONString]];
                break;
            }
        }
        [self.conversationMessageCollectionView reloadData];
        [self actionEnvelopDetail:obj[@"id"]];
        return;
    }
    [view showInView:self.view];
}


- (void)actionEnvelopDetail:(id)obj{
    CDPush(self.navigationController, CDPVC(@"EnvelopeListViewController", obj), YES);
}

- (void)action_exitGroup{
    [MESSAGE_NET quitGroup:self.targetId success:^(NSDictionary *info) {
        CDPop(self.navigationController, YES);
    } failure:^(NSError *error) {
        [FUNCTION_MANAGER handleFailResponse:error];
    }];
}

- (void)action_info{
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
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
