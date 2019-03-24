//
//  MessageViewController.m
//  Project
//
//  Created by mini on 2018/7/31.
//  Copyright © 2018年 CDJay. All rights reserved.
//

#import "MessageViewController.h"
#import "MessageNet.h"
#import <RongIMKit/RongIMKit.h>
#import "ChatViewController.h"
#import "MessageItem.h"
#import "ScrollBarView.h"
#import "EasyOperater.h"
#import "SystemAlertViewController.h"
#import "CustomerServiceAlertView.h"

#import "FYMenu.h"

#import "ShareViewController.h"
#import "RechargeViewController.h"
#import "BecomeAgentViewController.h"
#import "HelpCenterWebController.h"

#import "VVAlertModel.h"


@interface MessageViewController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong) UITableView *tableView;
@property(nonatomic,strong) MessageNet *model;
@property(nonatomic,strong) ScrollBarView *scrollBarView;

@property(nonatomic, strong) NSMutableArray *menuItems;

@end

@implementation MessageViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self initData];
    [self initSubviews];
    [self initLayout];
    
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_add_r"] style:UIBarButtonItemStyleDone target:self action:@selector(rightBarButtonDown:)];
    [self.navigationItem setRightBarButtonItem:rightBarButtonItem];
    
    [self announcementBar];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(action_reload) name:@"ReloadMyMessageGroupList" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateValue)name:@"CDReadNumberChange" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateScrollBarView) name:@"updateScrollBarView" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterFore) name:UIApplicationWillEnterForegroundNotification object:[UIApplication sharedApplication]];
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

-(void)enterFore {
    [self performSelector:@selector(getData) withObject:nil afterDelay:1.0];
    NSLog(@"进入前台");
}
#pragma mark 收到消息重新刷新
- (void)updateValue{
    //    dispatch_async(dispatch_get_main_queue(), ^{
    //        [self->_tabbar[1] setBadeValue:(APP_MODEL.unReadCount>0)?@"1":@"null"];
    //    });
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self->_tableView reloadData];
    });
}

-(void)viewDidAppear:(BOOL)animated{
}

- (void)initData{
    _model = [MessageNet shareInstance];
}


- (void)initLayout {
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)initSubviews {
    
    CDWeakSelf(self);
    __weak MessageNet *weakModel = _model;
    if(![AppModel shareInstance].isReleaseOrBeta)
        self.navigationItem.title = @"消息";
    else
        self.navigationItem.title = APP_MODEL.serverUrl;
    self.view.backgroundColor = BaseColor;
    _tableView = [UITableView groupTable];
    [self.view addSubview:_tableView];
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = BaseColor;
    _tableView.backgroundView = view;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = 70;
    _tableView.separatorColor = TBSeparaColor;
    _tableView.separatorInset = UIEdgeInsetsMake(0, 80, 0, 0);
    _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        CDStrongSelf(self);
        weakModel.page = 1;
        [self getData];
    }];
    
    _tableView.mj_footer = [MJRefreshAutoFooter footerWithRefreshingBlock:^{
        if (!weakModel.isMost) {
            CDStrongSelf(self);
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

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    SVP_DISMISS;
    [self updateScrollBarView];
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
- (void)action_reload {
    [self getData];
}

#pragma mark -  获取我加入的群组数据
- (void)getData {
    
    __weak __typeof(self)weakSelf = self;
    [_model getMyJoinedGroupListSuccessBlock:^(NSDictionary *dic) {
        SVP_DISMISS;
        [weakSelf delayReload];
    } failureBlock:^(NSError *err) {
        [FUNCTION_MANAGER handleFailResponse:err];
        [weakSelf reload];
    }];
    
    [NET_REQUEST_MANAGER requestSystemNoticeWithSuccess:^(id object) {
        [weakSelf delayReload];
    } fail:^(id object) {
        
    }];
}

- (void)delayReload {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(reload) withObject:nil afterDelay:0.2];
}

- (void)reload {
    [_tableView.mj_footer endRefreshing];
    [_tableView.mj_header endRefreshing];
    if(_model.isNetError){
        [_tableView.StateView showNetError];
    }
    else if(_model.isEmptyMyJoin){
        [_tableView.StateView showEmpty];
    }else{
        [_tableView.StateView hidState];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self->_tableView reloadData];
    });
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _model.myJoinDataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [tableView CDdequeueReusableCellWithIdentifier:_model.myJoinDataList[indexPath.row]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CDTableModel *model = _model.myJoinDataList[indexPath.row];
    
    MessageItem *item = [model.obj isKindOfClass:[NSDictionary class]] ? [MessageItem mj_objectWithKeyValues:model.obj] : (MessageItem *)model.obj;
    if ([item.chatgName isEqualToString:@"通知消息"]) {
        CDPush(self.navigationController, CDVC(@"NotifViewController"), YES);
        return;
    }
    if ([item.chatgName isEqualToString:@"在线客服"]) {
        
        [self actionShowCustomerServiceAlertView:nil];
        return;
    }
    
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
            [strongSelf goto_groupChat:item];
        }
        else{
            //            [MessageNet joinGroup:@{@"groupId":item.groupId,@"uid":APP_MODEL.user.userId} Success:^(NSDictionary *info) {
            //                SVP_DISMISS;
            //                [self groupChat:item];
            //            } Failure:^(NSError *error) {
            //                SVP_ERROR(error);
            //            }];
        }
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.1f;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = BaseColor;
    return view;
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [EasyOperater remove];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [EasyOperater remove];
}

#pragma mark - goto群组聊天界面
- (void)goto_groupChat:(id)obj{
    ChatViewController *vc = [ChatViewController groupChatWithObj:obj];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)showMenu{
    if([EasyOperater isExist]){
        [EasyOperater remove];
    }else
        [[EasyOperater sharedInstance] show];
}

#pragma mark - 客服弹框
- (void)actionShowCustomerServiceAlertView:(NSString *)messageModel {
    
    NSString *imageUrl = [AppModel shareInstance].commonInfo[@"customer.service.window"];
    if (imageUrl.length == 0) {
        [self webCustomerService];
        return;
    }
    CustomerServiceAlertView *view = [[CustomerServiceAlertView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    
    
    [view updateView:@"常见问题" imageUrl:imageUrl];
    
    __weak __typeof(self)weakSelf = self;
    
    // 查看详情
    view.customerServiceBlock = ^{
        [weakSelf webCustomerService];
    };
    [view showInView:self.view];
}
- (void)webCustomerService {
    WebViewController *vc = [[WebViewController alloc] initWithUrl:[AppModel shareInstance].commonInfo[@"pop"]];
    vc.title = @"在线客服";
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
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

@end
