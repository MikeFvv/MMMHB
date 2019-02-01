//
//  GroupViewController.m
//  Project
//
//  Created by mini on 2018/7/31.
//  Copyright © 2018年 CDJay. All rights reserved.
//

#import "GroupViewController.h"
#import "MessageNet.h"
#import "ChatViewController.h"
#import "MessageItem.h"
//#import "SqliteManage.h"
#import "BANetManager_OC.h"
#import "MessageNet.h"
#import "ScrollBarView.h"

@interface GroupViewController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong) UITableView *tableView;
@property(nonatomic,strong) MessageNet *model;
@property(nonatomic,strong) ScrollBarView *scrollBarView;

@end

@implementation GroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self initData];
    [self initSubviews];
    [self initLayout];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateScrollBarView) name:@"updateScrollBarView" object:nil];

}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    SVP_DISMISS;
    [self reload];
    [self updateScrollBarView];
}

#pragma mark ----- Data
- (void)initData{
    _model = [MessageNet shareInstance];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(CDDidReceiveMessageNotification:)name:RCKitDispatchMessageNotification object:nil];
}

#pragma mark ----- Layout
- (void)initLayout{
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

#pragma mark ----- subView
- (void)initSubviews {
    
    self.navigationItem.title = @"群组";
    CDWeakSelf(self);
    __weak MessageNet *weakModel = _model;
    self.view.backgroundColor = BaseColor;
    _tableView = [UITableView groupTable];
    [self.view addSubview:_tableView];
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = BaseColor;
    _tableView.backgroundView = view;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = 70;
    _tableView.separatorInset = UIEdgeInsetsMake(0, 80, 0, 0);
    _tableView.separatorColor = TBSeparaColor;
    _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        CDStrongSelf(self);
        weakModel.page = 1;
        [self getData];
    }];
    
    _tableView.mj_footer = [MJRefreshAutoFooter footerWithRefreshingBlock:^{
        CDStrongSelf(self);
        if (!weakModel.isMost) {
            weakModel.page ++;
            [self getData];
        }
    }];
    
    _tableView.StateView = [StateView StateViewWithHandle:^{
        CDStrongSelf(self);
        [self getData];
    }];
    //SVP_SHOW;
    weakModel.page = 1;
    [self getData];
}

#pragma mark 收到消息重新刷新
- (void)CDDidReceiveMessageNotification:(NSNotification *)notification{
    [self reload];
}

- (void)reload{
    [_tableView.mj_footer endRefreshing];
    [_tableView.mj_header endRefreshing];
    if(_model.isNetError){
        [_tableView.StateView showNetError];
    }
    else if(_model.isEmpty){
        [_tableView.StateView showEmpty];
    }else{
        [_tableView.StateView hidState];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self->_tableView reloadData];
    });
}


#pragma mark -  获取所有群组列表
/**
 获取所有群组列表
 */
- (void)getData{
    
    __weak __typeof(self)weakSelf = self;
    [_model getGroupListWithSuccessBlock:^(NSDictionary *dic) {
        SVP_DISMISS;
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf reload];
    } failureBlock:^(NSError *err) {
        [FUNCTION_MANAGER handleFailResponse:err];
    }];
    
}

#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _model.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView CDdequeueReusableCellWithIdentifier:_model.dataList[indexPath.row]];
    cell.backgroundColor = [UIColor whiteColor];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CDTableModel *model = _model.dataList[indexPath.row];
    MessageItem *item = [MessageItem mj_objectWithKeyValues:model.obj];
    
    //    float min = [item.minMoney floatValue];
    //    float user = [APP_MODEL.user.balance floatValue];
    //    if (user < min) {
    //        SVP_ERROR_STATUS(@"余额不足。");
    //        return;
    //    }
    
    SVP_SHOW;
    __weak __typeof(self)weakSelf = self;
    [[MessageNet shareInstance] checkGroupId:item.groupId Completed:^(BOOL complete) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (complete) {
            SVP_DISMISS;
            [strongSelf groupChat:item];
        } else {
            // 加入群组
            [[MessageNet shareInstance] joinGroup:item.groupId successBlock:^(NSDictionary *dict) {
                SVP_DISMISS;
                 __strong __typeof(weakSelf)strongSelf = weakSelf;
                [strongSelf sendWelcomeMessage:item.groupId];
                
                if ([[dict objectForKey:@"code"] integerValue] == 0) {
                     [strongSelf groupChat:item];
                } else if ([[dict objectForKey:@"code"] integerValue] == 1) {
                    SVP_ERROR_STATUS([dict objectForKey:@"msg"]);
                    [strongSelf groupChat:item];
                } else {
                     SVP_ERROR_STATUS([dict objectForKey:@"msg"]);
                }
                
            } failureBlock:^(NSError *error) {
                SVP_ERROR(error);
            }];
        }
    }];
    
}

- (void)sendWelcomeMessage:(NSString *)groupId {

    NSString *content = [NSString stringWithFormat:@"大家好，我是%@", [AppModel shareInstance].user.nick];
    RCTextMessage *txtMsg = [RCTextMessage messageWithContent:content];
    [[RCIM sharedRCIM] sendMessage:ConversationType_GROUP targetId:groupId content:txtMsg pushContent:nil pushData:nil success:^(long messageId) {
        NSLog(@"1");
    } error:^(RCErrorCode nErrorCode, long messageId) {
        NSLog(@"1");
    }];
}



- (void)groupChat:(id)obj{
    ChatViewController *vc = [ChatViewController groupChatWithObj:obj];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.1f;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = BaseColor;
    return view;
}

-(void)updateScrollBarView{
    if(self.scrollBarView) {
        [self.scrollBarView stop];
        [self.scrollBarView removeFromSuperview];
        self.scrollBarView = nil;
    }
    if(APP_MODEL.noticeArray.count > 0){
        ScrollBarView *view = [ScrollBarView createWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
        [self.view addSubview:view];
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        for (NSDictionary *dic in APP_MODEL.noticeArray) {
            NSString *s = dic[@"title"];
            [arr addObject:s];
        }
        view.textArray = arr;
        [view start];
        self.scrollBarView = view;
        [_tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self.view);
            make.top.equalTo(self.scrollBarView.mas_bottom).offset(0);
        }];
    }else{
        [_tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if(self.scrollBarView) {
        [self.scrollBarView stop];
        [self.scrollBarView removeFromSuperview];
        self.scrollBarView = nil;
    }
}
@end
