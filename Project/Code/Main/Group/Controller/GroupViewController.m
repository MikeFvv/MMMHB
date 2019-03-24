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

#import "FYMenu.h"

#import "RechargeViewController.h"
#import "ShareViewController.h"
#import "BecomeAgentViewController.h"
#import "HelpCenterWebController.h"
#import "SystemAlertViewController.h"
#import "VVAlertModel.h"


@interface GroupViewController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong) UITableView *tableView;
@property(nonatomic,strong) MessageNet *model;
@property(nonatomic,strong) ScrollBarView *scrollBarView;

@property(nonatomic, strong) NSMutableArray *menuItems;

@end

@implementation GroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self initData];
    [self initSubviews];
    [self initLayout];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateScrollBarView) name:@"updateScrollBarView" object:nil];

    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_add_r"] style:UIBarButtonItemStyleDone target:self action:@selector(rightBarButtonDown:)];
    [self.navigationItem setRightBarButtonItem:rightBarButtonItem];
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
                } else if ([[dict objectForKey:@"code"] integerValue] == 19) {
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
    } error:^(RCErrorCode nErrorCode, long messageId) {
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

        UITapGestureRecognizer *tapGesturRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(scrollBarViewAction)];
        [view addGestureRecognizer:tapGesturRecognizer];
        
        view.tapBlock = ^(id object) {
            
        };
        [self.view addSubview:view];
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        NSInteger nu = 0;
        for (NSDictionary *dic in APP_MODEL.noticeArray) {
            NSString *title = dic[@"title"];
            NSString *content = dic[@"content"];
            NSMutableString *s = [[NSMutableString alloc] initWithString:@""];
            if(title.length > 0)
                [s appendString:title];
            if(content.length > 0){
                if(s.length > 0)
                    [s appendString:@"："];
                [s appendString:content];
            }
            [arr addObject:s];
            nu += 1;
            if(nu == 2)
                break;
        }
        view.textArray = arr;
        [view start];
        self.scrollBarView = view;
        [_tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self.view);
            make.top.equalTo(self.scrollBarView.mas_bottom).offset(3);
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

#pragma mark - 下拉菜单
- (NSMutableArray *)menuItems {
    if (!_menuItems) {
        
        __weak __typeof(self)weakSelf = self;
        
        _menuItems = [[NSMutableArray alloc] initWithObjects:
                      
                      [FYMenuItem itemWithImage:[UIImage imageNamed:@"nav_recharge"]
                                          title:@"快速充值"
                                         action:^(FYMenuItem *item) {
                                             UIViewController *vc = [[RechargeViewController alloc]init];
                                             vc.hidesBottomBarWhenPushed = YES;
                                             [weakSelf.navigationController pushViewController:vc animated:YES];
                                         }],
                      [FYMenuItem itemWithImage:[UIImage imageNamed:@"nav_share"]
                                          title:@"分享赚钱"
                                         action:^(FYMenuItem *item) {
                                             ShareViewController *vc = [[ShareViewController alloc] init];
                                             vc.hidesBottomBarWhenPushed = YES;
                                             [weakSelf.navigationController pushViewController:vc animated:YES];
                                         }],
                      [FYMenuItem itemWithImage:[UIImage imageNamed:@"nav_agent"]
                                          title:@"申请代理"
                                         action:^(FYMenuItem *item) {
                                             BecomeAgentViewController *vc = [[BecomeAgentViewController alloc] init];
                                             vc.hidesBottomBarWhenPushed = YES;
                                             vc.hiddenNavBar = YES;
                                             vc.imageUrl = @"http://app.520qun.com/img/proxy_info.jpg";
                                             [weakSelf.navigationController pushViewController:vc animated:YES];
                                         }],
                      [FYMenuItem itemWithImage:[UIImage imageNamed:@"nav_help"]
                                          title:@"帮助中心"
                                         action:^(FYMenuItem *item) {
                                             //                                              AlertViewCus *view = [AlertViewCus createInstanceWithView:nil];
                                             //                                              [view showWithText:@"等待更新，敬请期待" button:@"好的" callBack:nil];
                                             
                                             NSString *url = [NSString stringWithFormat:@"%@/dist/#/index/helpCenter?accesstoken=%@", [AppModel shareInstance].commonInfo[@"website.address"], [AppModel shareInstance].user.token];
                                             HelpCenterWebController *vc = [[HelpCenterWebController alloc] initWithUrl:url];
                                             vc.hidesBottomBarWhenPushed = YES;
                                             [weakSelf.navigationController pushViewController:vc animated:YES];
                                             
                                         }], nil];
    }
    
    return _menuItems;
}


//导航栏弹出
- (void)rightBarButtonDown:(UIBarButtonItem *)sender
{
    FYMenu *menu = [[FYMenu alloc] initWithItems:self.menuItems];
    menu.menuCornerRadiu = 5;
    menu.showShadow = NO;
    menu.minMenuItemHeight = 48;
    menu.titleColor = [UIColor darkGrayColor];
    menu.menuBackGroundColor = [UIColor whiteColor];
    [menu showFromNavigationController:self.navigationController WithX:[UIScreen mainScreen].bounds.size.width-32];
}

#pragma mark - 系统公告栏
- (void)announcementBar {
    NSMutableArray *announcementArray = [NSMutableArray array];
    if([AppModel shareInstance].noticeArray.count > 0){
        for (NSDictionary *dic in [AppModel shareInstance].noticeArray) {
            NSString *title = dic[@"title"];
            NSString *content = dic[@"content"];
            VVAlertModel *model = [[VVAlertModel alloc] init];
            model.name = title;
            if (content.length > 0) {
                model.friends = @[content];
            }
            [announcementArray addObject:model];
        }
    } else {
        return;
    }
    SystemAlertViewController *alertVC = [SystemAlertViewController alertControllerWithTitle:@"平台公告" dataArray:announcementArray];
    [self presentViewController:alertVC animated:NO completion:nil];
}

- (void)scrollBarViewAction {
    [self announcementBar];
}

@end
