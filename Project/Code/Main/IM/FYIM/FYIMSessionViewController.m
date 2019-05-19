//
//  FYIMSessionViewController.m
//  Project
//
//  Created by Mike on 2019/4/1.
//  Copyright © 2019 CDJay. All rights reserved.
//

#import "FYIMSessionViewController.h"

#import "SSAddImage.h"
#import "FYChatBaseCell.h"
#import "FYSystemBaseCell.h"
#import "SSChatLocationController.h"
#import "SSImageGroupView.h"
#import "SSChatMapController.h"

#import "SSChatDatas.h"
// 后面添加
#import "FYChatManagerProtocol.h"

#import "FYSocketManager.h"
#import "WHC_ModelSqlite.h"
#import "NSTimer+SSAdd.h"

#import "NotificationMessageCell.h"
#import "PushMessageModel.h"
#import "MessageSingle.h"


@interface FYIMSessionViewController ()<SSChatKeyBoardInputViewDelegate,UITableViewDelegate,UITableViewDataSource,FYChatBaseCellDelegate, FYChatManagerDelegate>
    
    //承载表单的视图 视图原高度
    @property (strong, nonatomic) UIView    *mBackView;
    @property (assign, nonatomic) CGFloat   backViewH;
    
    
    
    //访问相册 摄像头
    @property(nonatomic,strong)SSAddImage *mAddImage;
    @property (nonatomic ,assign) NSInteger page;
    // 是否最底部
    @property (nonatomic,assign) BOOL isTableViewBottom;
    // 未查看消息数量
    @property (nonatomic,assign) NSInteger notViewedMessagesCount;
    //
    @property (nonatomic,strong) UIButton *bottomMessageBtn;
    @property (nonatomic,strong) UILabel *bottomMessageLabel;
    @property (nonatomic,strong) UIView *topMessageView;
    @property (nonatomic,strong) UILabel *topMessageLabel;
    // top 未读消息条数
    @property (nonatomic,assign) NSInteger unreadMessageNum;
    @property (nonatomic,assign) NSInteger topNumIndex;
    
    @end

@implementation FYIMSessionViewController
    
    static FYIMSessionViewController *_chatVC;
    
    
    //-(instancetype)init{
    //    if(self = [super init]){
    //        _chatType = ConversationType_PRIVATE;
    //        _dataSource = [NSMutableArray new];
    //        [FYSocketMessageManager shareInstance].delegate = self;
    //    }
    //    return self;
    //}
    
    
    /*!
     初始化会话页面
     
     @param conversationType 会话类型
     @param targetId         目标会话ID
     
     @return 会话页面对象
     */
- (id)initWithConversationType:(FYChatConversationType)conversationType targetId:(NSString *)targetId {
    if(self = [super init]) {
        _chatType = conversationType;
        _sessionId = targetId;
        _dataSource = [NSMutableArray array];
        _page = 1;
        _notViewedMessagesCount = 0;
        [FYIMMessageManager shareInstance].delegate = self;
        self.delegate = self;
    }
    _chatVC = self;
    return self;
}
    
    
+ (FYIMSessionViewController *)currentChat {
    return _chatVC;
}
    
    
    //不采用系统的旋转
- (BOOL)shouldAutorotate {
    return NO;
}
    
- (void)viewDidLoad {
    [super viewDidLoad];
    //    self.navigationItem.title = _titleString;
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.reloadFinish = YES;
    // 初始化数据
    self.unreadMessageNum = 0;
    
    _sessionInputView = [SSChatKeyBoardInputView new];
    _sessionInputView.delegate = self;
    [self.view addSubview:_sessionInputView];
    
    _backViewH = FYSCREEN_Height-SSChatKeyBoardInputViewH-Height_NavBar-kiPhoneX_Bottom_Height;
    
    _mBackView = [UIView new];
    _mBackView.frame = CGRectMake(0, Height_NavBar, FYSCREEN_Width, _backViewH);
    _mBackView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.mBackView];
    
    
    [self initTableView];
    
    [self unreadMessageView];
    //    self.enableUnreadMessageIcon = YES;
    //    self.enableNewComingMessageIcon = YES;
    
    [self getUnreadMessageAction];
    
    NSInteger num = kMessagePageNumber -(self.unreadMessageNum % kMessagePageNumber);
    NSInteger numCount = self.unreadMessageNum + num;
    [self getHistoricalData:numCount > kMessagePageNumber ? numCount : kMessagePageNumber];
    NSInteger topNumIndex = num - (numCount - self.dataSource.count);
    _topNumIndex = topNumIndex;
    
    if (self.unreadMessageNum > kMessagePageNumber) {
        self.page = numCount / kMessagePageNumber;
    }
    
    [self scrollToBottom];
    
    
    // 通知 监听消息列表是否需要刷新
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(chatListreloadData:)
                                                 name:kChatListReloadDataNotification
                                               object:nil];
    
    // 单聊
    //    if(_chatType == FYConversationType_PRIVATE) {
    //        [_datas addObjectsFromArray:[SSChatDatas LoadingMessagesStartWithChat:_sessionId]];
    //    } else {  // 群聊
    //        [_datas addObjectsFromArray:[SSChatDatas LoadingMessagesStartWithGroupChat:_sessionId]];
    //    }
    //
    //    if (_datas.count > 0) {
    //        [_tableView reloadData];
    //    }
    
}
    
    
    /**
     获取未读消息数量
     */
- (void)getUnreadMessageAction {
    
    //    NSString *path = [NSString stringWithFormat:@"%@",[AppModel shareInstance].userInfo.userId];
    //    NSString *query = [NSString stringWithFormat:@"sessionId='%@' AND userId='%@'",self.sessionId,path];
    
    //    PushMessageModel *pmModel = [[WHC_ModelSqlite query:[PushMessageModel class] where:query] firstObject];
    NSString *queryId = [NSString stringWithFormat:@"%@-%@",self.sessionId,[AppModel shareInstance].userInfo.userId];
    PushMessageModel *pmModel = (PushMessageModel *)[MessageSingle shareInstance].myJoinGroupMessage[queryId];
    
    self.unreadMessageNum = pmModel.number;
    if (pmModel.number  > kMessagePageNumber) {
        self.topMessageView.hidden = NO;
        NSString *mgsStr = (pmModel.number - self.dataSource.count) > 99 ? @"99+条新消息" : [NSString stringWithFormat:@"%zd 条新消息",pmModel.number - self.dataSource.count];
        self.topMessageLabel.text = mgsStr;
    } else {
        self.topMessageView.hidden = YES;
        self.topMessageLabel.text = 0;
    }
}
    
    
#pragma mark - 获取历史消息 下拉刷新获取数据
- (void)getHistoricalData:(NSInteger)count {
    
    NSString *pageStr = [NSString stringWithFormat:@"%zd,%zd", (self.page -1)*count,count];
    NSString *whereStr = [NSString stringWithFormat:@"sessionId = %@ and isDeleted = 0", self.sessionId];
    NSArray *messageArray = [WHC_ModelSqlite query:[FYMessage class] where:whereStr order:@"by create_time desc" limit:pageStr];
    
    for (NSInteger index = 0; index < messageArray.count; index++) {
        FYMessage *message = (FYMessage *)messageArray[index];
        [self.dataSource insertObject:[SSChatDatas receiveMessage:message] atIndex:0];
    }
    [_tableView.mj_header endRefreshing];
    if (self.page > 1 && self.dataSource.count > 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->_tableView reloadData];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:messageArray.count inSection:0];
            [self->_tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
        });
    }
    if (messageArray.count == 0) {
        _tableView.mj_header.hidden = YES;
    }
}
    
    
- (void)initTableView {
    UITableView *tableView = [[UITableView alloc]initWithFrame:_mBackView.bounds style:UITableViewStylePlain];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.backgroundColor = SSChatCellColor;
    tableView.backgroundView.backgroundColor = SSChatCellColor;
    [_mBackView addSubview:tableView];
    _tableView = tableView;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    tableView.scrollIndicatorInsets = tableView.contentInset;
    if (@available(iOS 11.0, *)){
        tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        tableView.estimatedRowHeight = 0;
        tableView.estimatedSectionHeaderHeight = 0;
        tableView.estimatedSectionFooterHeight = 0;
    }
    __weak __typeof(self)weakSelf = self;
    tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        strongSelf.page++;
        [strongSelf getHistoricalData:kMessagePageNumber];
    }];
    
    [tableView registerClass:NSClassFromString(@"SSChatTextCell") forCellReuseIdentifier:SSChatTextCellId];
    [tableView registerClass:NSClassFromString(@"SSChatImageCell") forCellReuseIdentifier:SSChatImageCellId];
    [tableView registerClass:NSClassFromString(@"SSChatVoiceCell") forCellReuseIdentifier:SSChatVoiceCellId];
    [tableView registerClass:NSClassFromString(@"SSChatMapCell") forCellReuseIdentifier:SSChatMapCellId];
    [tableView registerClass:NSClassFromString(@"SSChatVideoCell") forCellReuseIdentifier:SSChatVideoCellId];
    [tableView registerClass:NSClassFromString(@"FYRedEnevlopeCell") forCellReuseIdentifier:FYRedEnevlopeCellId];
    [tableView registerClass:NSClassFromString(@"CowCowVSMessageCell") forCellReuseIdentifier:CowCowVSMessageCellId];
    [tableView registerClass:NSClassFromString(@"NotificationMessageCell") forCellReuseIdentifier:NotificationMessageCellId];
}
    
    
    
#pragma mark - 未读消息 和 未读新消息视图
- (void)unreadMessageView {
    
    UIView *topMessageView = [[UIView alloc] init];
    topMessageView.backgroundColor = [UIColor whiteColor];
    topMessageView.layer.cornerRadius = 35/2;
    topMessageView.layer.borderWidth = 0.5;
    topMessageView.layer.borderColor = [UIColor colorWithRed:0.863 green:0.863 blue:0.863 alpha:1.000].CGColor;
    topMessageView.hidden = YES;
    
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(topViewtapClick:)];
    [topMessageView addGestureRecognizer:gesture];
    
    [self.view addSubview:topMessageView];
    _topMessageView = topMessageView;
    
    [topMessageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.tableView.mas_right).offset(35/2);
        make.top.mas_equalTo(self.tableView.mas_top).offset(18);
        make.size.mas_equalTo(CGSizeMake(150, 35));
    }];
    
    UIImageView *backImageView = [[UIImageView alloc] init];
    backImageView.image = [UIImage imageNamed:@"mess_arrow"];
    [topMessageView addSubview:backImageView];
    
    [backImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(topMessageView.mas_centerY);
        make.left.mas_equalTo(topMessageView.left).offset(12);
        make.size.mas_equalTo(CGSizeMake(9.0, 8.5));
    }];
    
    UILabel *topMessageLabel = [[UILabel alloc] init];
    //    topMessageLabel.text = @"0 条新消息";
    topMessageLabel.font = [UIFont systemFontOfSize:14];
    topMessageLabel.textColor = [UIColor colorWithRed:0.059 green:0.608 blue:1.000 alpha:1.000];
    topMessageLabel.textAlignment = NSTextAlignmentCenter;
    [topMessageView addSubview:topMessageLabel];
    _topMessageLabel = topMessageLabel;
    
    [topMessageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(backImageView.mas_right).offset(15);
        make.centerY.mas_equalTo(topMessageView.mas_centerY);
    }];
    
    // ******************************
    
    UIButton *bottomMessageBtn = [[UIButton alloc] init];
    [bottomMessageBtn addTarget:self action:@selector(onNewMessageBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [bottomMessageBtn setBackgroundImage:[UIImage imageNamed:@"mess_bubble"] forState:UIControlStateNormal];
    [self.view addSubview:bottomMessageBtn];
    _bottomMessageBtn = bottomMessageBtn;
    bottomMessageBtn.hidden = YES;
    
    [bottomMessageBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.tableView.mas_right).offset(-10);
        make.bottom.mas_equalTo(self.mBackView.mas_bottom).offset(-15);
        make.size.equalTo(@(37.5));
    }];
    
    UILabel *bottomMessageLabel = [[UILabel alloc] init];
    //    bottomMessageLabel.text = @"1";
    bottomMessageLabel.font = [UIFont systemFontOfSize:14];
    bottomMessageLabel.textColor = [UIColor whiteColor];
    bottomMessageLabel.textAlignment = NSTextAlignmentCenter;
    [bottomMessageBtn addSubview:bottomMessageLabel];
    _bottomMessageLabel = bottomMessageLabel;
    
    [bottomMessageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(bottomMessageBtn.mas_centerX);
        make.centerY.mas_equalTo(bottomMessageBtn.mas_centerY).offset(-3);
    }];
}
    
- (void)onNewMessageBtnClick {
    [self scrollToBottom];
    [self hidBottomUnreadMessageView];
}
    
- (void)hidBottomUnreadMessageView {
    self.notViewedMessagesCount = 0;
    self.bottomMessageLabel.text = 0;
    self.bottomMessageBtn.hidden = YES;
}
    
#pragma mark - top未读消息点击事件
-(void)topViewtapClick:(UITapGestureRecognizer *)sender {
    
    if (self.dataSource.count > 0) {
        if ([self.tableView numberOfRowsInSection:0] > 0) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.topNumIndex >= 0 ? self.topNumIndex : 0 inSection:0];
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
    }
    self.topMessageView.hidden = YES;
    self.topMessageLabel.text = 0;
}
    
-(void)dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
    
    //处理监听触发事件
-(void)chatListreloadData:(NSNotificationCenter *)notification {
    NSLog(@"1");
}
    
#pragma mark - 接收消息
- (FYMessage *)willAppendAndDisplayMessage:(FYMessage *)message {
    // 更新数据   // 暂时不做
    //    if (message.deliveryState == FYMessageDeliveryStateDeliveried && message.isReceivedMsg == YES) {
    //
    //    }
    
    // 系统消息类型
    if (message.messageType == FYSystemMessage) {
        message.sessionId = self.sessionId;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // 更新数据源
        [self.dataSource addObject:[SSChatDatas receiveMessage:message]];
        // UI更新代码
        [self delayReload];
    });
    
    //    if(self.reloadFinish){
    //        self.reloadFinish = NO;
    //        [self performSelector:@selector(delayReload) withObject:nil afterDelay:0.2];
    //    }
    return message;
}
    
-(void)delayReload{
    FYMessagelLayoutModel *message = [self.dataSource lastObject];
    [self.tableView reloadData];
    if ([message.message.messageSendId isEqualToString:[AppModel shareInstance].userInfo.userId] || self.isTableViewBottom) {
        [self scrollToBottom];
    }
    // 未读新消息
    if (!self.isTableViewBottom) {
        self.notViewedMessagesCount++;
        NSString *mgsStr = self.notViewedMessagesCount > 99 ? @"99+" : [NSString stringWithFormat:@"%zd",self.notViewedMessagesCount];
        self.bottomMessageLabel.text = mgsStr;
        self.bottomMessageBtn.hidden = NO;
    }
    self.reloadFinish = YES;
}
    /**
     即将撤回消息
     
     @param messageId  消息ID
     */
- (void)willRecallMessage:(NSString *)messageId {
    [self onDeleteLocalMessage:messageId];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}
    
    /**
     撤回消息
     
     @param model 消息模型
     */
-(void)onWithdrawMessageCell:(FYMessage *)model {
    
    NSDictionary *parameters = @{
                                 @"id":model.messageId,  // 消息ID
                                 @"groupId":model.sessionId,   // 群ID
                                 @"cmd":@"15"      // 聊天命令
                                 };
    [[FYIMMessageManager shareInstance] sendMessageServer:parameters];
    
}
    
    
    
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
    {
        CGFloat height = scrollView.frame.size.height;
        CGFloat contentOffsetY = scrollView.contentOffset.y;
        CGFloat bottomOffset = scrollView.contentSize.height - contentOffsetY;
        
        if ((bottomOffset-150) <= height) {
            //在最底部
            self.isTableViewBottom = YES;
            [self hidBottomUnreadMessageView];
        } else {
            self.isTableViewBottom = NO;
        }
    }
    
    
    
    
#pragma mark - 发送消息
    //发送文本 列表滚动至底部
-(void)onChatKeyBoardInputViewSendText:(NSString *)text {
    if ([FYIMMessageManager shareInstance].isConnectFY) {
        NSMutableDictionary *userDict = [[NSMutableDictionary alloc] init];
        [userDict setObject:[AppModel shareInstance].userInfo.userId forKey:@"userId"];  // 用户ID
        [userDict setObject:[AppModel shareInstance].userInfo.nick forKey:@"nick"];   // 用户昵称
        [userDict setObject:[AppModel shareInstance].userInfo.avatar forKey:@"avatar"];  // 用户头像
        
        NSMutableDictionary *extrasDict = [[NSMutableDictionary alloc] init];
        [extrasDict setObject:self.sessionId forKey:@"groupId"];  // 用户ID
        
        NSDictionary *parameters = @{
                                     @"user":userDict,  // 发送者用户信息
                                     @"extras":extrasDict,  // 发送者用户信息
                                     @"from":[AppModel shareInstance].userInfo.userId,      // 发送者ID
                                     @"cmd":@"11",      // 聊天命令
                                     @"groupId":self.sessionId,   // 群ID
                                     @"chatType":@(FYConversationType_GROUP),  // 1 群聊   2  p2p
                                     @"msgType":@(FYMessageTypeText),   // 0 文本 6 红包  7 报奖信息
                                     @"content":text // 消息内容
                                     };
        
        
        FYMessage *message = [FYMessage mj_objectWithKeyValues:parameters];
        
        NSMutableDictionary *tempDict = [NSMutableDictionary dictionaryWithDictionary:parameters];
        if (self.delegate && [self.delegate respondsToSelector:@selector(willSendMessage:)]) {
            message = [self.delegate willSendMessage:message];
            if (message != nil) {
                [tempDict setObject:message.text forKey:@"content"];
            } else {
                [tempDict setObject:@"" forKey:@"content"];
            }
        }
        
        // 测试
//        [self testUse:tempDict text:message.text];
        
        [[FYIMMessageManager shareInstance] sendMessageServer:tempDict];
        
    } else {
        NSLog(@"🔴没有连接上socket");
    }
}
    
// 注意：只能测试时用
- (void)testUse:(NSMutableDictionary *)muDict text:(NSString *)text {
    // 测试
    for (NSInteger index = 0; index < 100; index++) {
        [muDict setObject:[NSString stringWithFormat:@"%@-%zd", text,index] forKey:@"content"];
        [[FYIMMessageManager shareInstance] sendMessageServer:muDict];
    }
}
    
    //发送消息
-(void)sendMessage:(FYMessage *)message {
    [SSChatDatas sendMessage:message messageBlock:^(FYMessagelLayoutModel *model, NSError *error, NSProgress *progress) {
        
        [self.dataSource addObject:model];
        [self.tableView reloadData];
        NSIndexPath *indexPath = [NSIndexPath     indexPathForRow:self.dataSource.count-1 inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        
    }];
}
    

    
#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}
    
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.topNumIndex) {
        self.topMessageView.hidden = YES;
        self.topMessageLabel.text = 0;
    }
    FYMessagelLayoutModel *model = _dataSource[indexPath.row];
    if (model.message.messageType == FYMessageTypeNoticeRewardInfo || model.message.messageType == FYSystemMessage) {
        
        FYSystemBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:model.message.cellString];
        if (cell == nil) {
            cell = [[FYSystemBaseCell alloc]initWithStyle:0 reuseIdentifier:model.message.cellString];
        }
        cell.model = model;
        return cell;
    } else {
        FYChatBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:model.message.cellString];
        if (cell == nil) {
            cell = [[FYChatBaseCell alloc]initWithStyle:0 reuseIdentifier:model.message.cellString];
        }
        cell.delegate = self;
        cell.indexPath = indexPath;
        cell.model = model;
        return cell;
    }
}
    
#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [(FYMessagelLayoutModel *)_dataSource[indexPath.row] cellHeight];
}
    
    //视图归位
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [_sessionInputView SetSSChatKeyBoardInputViewEndEditing];
}
    
#pragma mark - 删除消息
    // 删除消息
-(void)onDeleteMessageCell:(FYMessage *)model indexPath:(NSIndexPath *)indexPath {
    
    [self onDeleteLocalMessage:model.messageId];
    [self.tableView reloadData];
}
    
    /**
     删除本地消息方法
     
     @param messageId 消息ID
     */
- (void)onDeleteLocalMessage:(NSString *)messageId {
    for (FYMessagelLayoutModel *modelLayout in self.dataSource) {
        if ([messageId isEqualToString:modelLayout.message.messageId]) {
            [self.dataSource removeObject:modelLayout];
            [self deleteMessageUpdateSql:messageId];
            break;
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}
    
- (void)deleteMessageUpdateSql:(NSString *)messageId {
    NSString *whereStr = [NSString stringWithFormat:@"messageId='%@'", messageId];
    FYMessage *fyMessage = [[WHC_ModelSqlite query:[FYMessage class] where:whereStr] firstObject];
    fyMessage.isDeleted = YES;
    if (fyMessage != nil) {
        [WHC_ModelSqlite update:fyMessage where:whereStr];
    }
}
    
    
    
    
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [_sessionInputView SetSSChatKeyBoardInputViewEndEditing];
}
    
- (void)viewWillDisappear:(BOOL)animated
    {
        [super viewWillDisappear:animated];
        [self.sessionInputView endEditing:YES];
    }
    
#pragma SSChatKeyBoardInputViewDelegate 底部输入框代理回调
    //点击按钮视图frame发生变化 调整当前列表frame
-(void)SSChatKeyBoardInputViewHeight:(CGFloat)keyBoardHeight changeTime:(CGFloat)changeTime{
    
    CGFloat height = _backViewH - keyBoardHeight;
    [UIView animateWithDuration:changeTime animations:^{
        self.mBackView.frame = CGRectMake(0, Height_NavBar, FYSCREEN_Width, height);
        self.tableView.frame = self.mBackView.bounds;
        
        if (self.dataSource.count > 0) {
            [self.tableView reloadData];
            NSIndexPath *indexPath = [NSIndexPath     indexPathForRow:self.dataSource.count-1 inSection:0];
            dispatch_async(dispatch_get_main_queue(), ^{
                //刷新完成
                [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            });
        }
        
    } completion:^(BOOL finished) {
    }];
    
}
    
    // 滚动到最底部  https://www.jianshu.com/p/03c478adcae7
-(void)scrollToBottom {
    if (self.dataSource.count > 0) {
        if ([self.tableView numberOfRowsInSection:0] > 0) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:([self.tableView numberOfRowsInSection:0]-1) inSection:0];
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
    }
    self.notViewedMessagesCount = 0;
    self.isTableViewBottom = YES;
}
    
    
    // 发送语音
-(void)SSChatKeyBoardInputViewBtnClick:(SSChatKeyBoardInputView *)view sendVoice:(NSData *)voice time:(NSInteger)second{
    
    NSDictionary *dic = @{@"voice":voice,
                          @"second":@(second)};
    [self sendMessage:dic messageType:FYMessageTypeVoice];
}
    
    
    //多功能视图点击回调  图片10  视频11  位置12
-(void)fyChatFunctionBoardClickedItemWithTag:(NSInteger)tag {
    
    if(tag==10 || tag==11){
        if(!_mAddImage) _mAddImage = [[SSAddImage alloc]init];
        
        [_mAddImage getImagePickerWithAlertController:self modelType:SSImagePickerModelImage + tag-10 pickerBlock:^(SSImagePickerWayStyle wayStyle, SSImagePickerModelType modelType, id object) {
            
            if(tag==10){
                UIImage *image = (UIImage *)object;
                NSLog(@"%@",image);
                NSDictionary *dic = @{@"image":image};
                [self sendMessage:dic messageType:FYMessageTypeImage];
            }
            
            else{
                NSString *localPath = (NSString *)object;
                NSLog(@"%@",localPath);
                NSDictionary *dic = @{@"videoLocalPath":localPath};
                [self sendMessage:dic messageType:FYMessageTypeVideo];
            }
        }];
        
    } else {
        SSChatLocationController *vc = [SSChatLocationController new];
        vc.locationBlock = ^(NSDictionary *locationDic, NSError *error) {
            [self sendMessage:locationDic messageType:FYMessageTypeMap];
        };
        [self.navigationController pushViewController:vc animated:YES];
        
    }
}
    
    
    
    
    //发送消息
-(void)sendMessage:(NSDictionary *)dic messageType:(FYMessageType)messageType {
    
    //    [SSChatDatas sendMessage:dic sessionId:_sessionId messageType:messageType messageBlock:^(FYMessagelLayoutModel *model, NSError *error, NSProgress *progress) {
    //
    //        [self.dataSource addObject:model];
    //        [self.tableView reloadData];
    //        NSIndexPath *indexPath = [NSIndexPath     indexPathForRow:self.dataSource.count-1 inSection:0];
    //        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    //
    //    }];
}
    
    
#pragma - FYChatBaseCellDelegate
    
#pragma 点击Cell消息背景视图
- (void)didTapMessageCell:(FYMessage *)model {
    
}
    
#pragma 点击图片 点击短视频
-(void)didChatImageVideoCellIndexPatch:(NSIndexPath *)indexPath layout:(FYMessagelLayoutModel *)layout{
    
    NSInteger currentIndex = 0;
    NSMutableArray *groupItems = [NSMutableArray new];
    
    for(int i=0;i<self.dataSource.count;++i){
        
        NSIndexPath *ip = [NSIndexPath indexPathForRow:i inSection:0];
        FYChatBaseCell *cell = [_tableView cellForRowAtIndexPath:ip];
        FYMessagelLayoutModel *mLayout = self.dataSource[i];
        
        SSImageGroupItem *item = [SSImageGroupItem new];
        if(mLayout.message.messageType == FYMessageTypeImage){
            item.imageType = SSImageGroupImage;
            item.fromImgView = cell.mImgView;
            //            item.fromImage = mLayout.message.image;
        }
        else if (mLayout.message.messageType == FYMessageTypeVideo){
            item.imageType = SSImageGroupVideo;
            item.videoPath = mLayout.message.videoLocalPath;
            item.fromImgView = cell.mImgView;
            //            item.fromImage = mLayout.message.videoImage;
        }
        else continue;
        
        //        item.contentMode = mLayout.message.contentMode;
        item.itemTag = groupItems.count + 10;
        if([mLayout isEqual:layout])currentIndex = groupItems.count;
        [groupItems addObject:item];
        
    }
    
    SSImageGroupView *imageGroupView = [[SSImageGroupView alloc]initWithGroupItems:groupItems currentIndex:currentIndex];
    [self.navigationController.view addSubview:imageGroupView];
    
    __block SSImageGroupView *blockView = imageGroupView;
    blockView.dismissBlock = ^{
        [blockView removeFromSuperview];
        blockView = nil;
    };
    
    [self.sessionInputView SetSSChatKeyBoardInputViewEndEditing];
}
    
#pragma FYChatBaseCellDelegate 点击定位
-(void)didChatMapCellIndexPath:(NSIndexPath *)indexPath layout:(FYMessagelLayoutModel *)layout{
    
    SSChatMapController *vc = [SSChatMapController new];
    vc.latitude = layout.message.latitude;
    vc.longitude = layout.message.longitude;
    [self.navigationController pushViewController:vc animated:YES];
}
    
    
    
    @end
