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
#import "SqliteManage.h"
#import "ModelHelper.h"

@interface GroupViewController ()<UITableViewDelegate,UITableViewDataSource>{
    UITableView *_tableView;
}

@end

@implementation GroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self initSubviews];
    [self initLayout];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self reload];
}

#pragma mark ----- Data
- (void)initData{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(CDDidReceiveMessageNotification:)name:RCKitDispatchMessageNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reload)name:@"reloadMyGroupList" object:nil];
}

#pragma mark ----- Layout
- (void)initLayout{
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

#pragma mark ----- subView
- (void)initSubviews{
    
    self.navigationItem.title = @"群组";
    CDWeakSelf(self);
    __weak MessageNet *weakModel = MESSAGE_NET;
    _tableView = [UITableView normalTable];
    [self.view addSubview:_tableView];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = 80;
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
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self->_tableView.mj_header beginRefreshing];
    });
    
}

#pragma mark 收到消息重新刷新
- (void)CDDidReceiveMessageNotification:(NSNotification *)notification{
    [self reload];
}

- (void)reload{
    [_tableView.mj_footer endRefreshing];
    [_tableView.mj_header endRefreshing];
    if(MESSAGE_NET.isNetError){
        [_tableView.StateView showNetError];
    }
    else if(MESSAGE_NET.isEmpty){
        [_tableView.StateView showEmpty];
    }else{
        [_tableView.StateView hidState];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self->_tableView reloadData];
    });
}

- (void)getData{
    
    WEAK_OBJ(weakObj, self);
    [MESSAGE_NET requestMyJoinedGroupListWithSuccess:^(NSDictionary *info) {
        [weakObj reload];
    } Failure:^(NSError *error) {
        [FUNCTION_MANAGER handleFailResponse:error];
        [weakObj reload];
    }];
}

#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return MESSAGE_NET.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [tableView CDdequeueReusableCellWithIdentifier:MESSAGE_NET.dataList[indexPath.row]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CDTableModel *model = MESSAGE_NET.dataList[indexPath.row];
    //MessageItem *item = [MessageItem mj_objectWithKeyValues:model.obj];
    MessageItem *item = [MODEL_HELPER getMessageItem:model.obj];
//    float min = [item.minMoney floatValue];
//    float user = [APP_MODEL.user.money floatValue];
//    if (user < min) {
//        SV_ERROR_STATUS(@"余额不足。");
//        return;
//    }
    [self groupChat:item];
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

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
