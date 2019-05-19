//
//  MessageViewController.m
//  Project
//
//  Created by mini on 2018/7/31.
//  Copyright © 2018年 CDJay. All rights reserved.
//

#import "MessageViewController.h"
#import "MessageNet.h"
//#import <RongIMKit/RongIMKit.h>
#import "ChatViewController.h"
#import "MessageItem.h"
#import "ScrollBarView.h"
#import "EasyOperater.h"
#import "SystemAlertViewController.h"
#import "CustomerServiceAlertView.h"

#import "FYMenu.h"

#import "ShareViewController.h"
#import "Recharge2ViewController.h"
#import "BecomeAgentViewController.h"
#import "HelpCenterWebController.h"

#import "VVAlertModel.h"
#import "AgentCenterViewController.h"
#import "PushMessageModel.h"
#import "MessageSingle.h"
#import "SqliteManage.h"
#import "MsgHeaderView.h"
#import "CWCarousel.h"
#import "CWPageControl.h"
#import "UIImageView+WebCache.h"
#define kViewTag 666

@interface MessageViewController ()<UITableViewDelegate,UITableViewDataSource,CWCarouselDatasource, CWCarouselDelegate>
@property (nonatomic, strong) BannerModel* bannerModel;
@property (nonatomic, strong) CWCarousel *carousel;
@property (nonatomic, strong) UIView *animationView;
@property(nonatomic,strong) UITableView *tableView;
@property(nonatomic,strong) MessageNet *model;
@property(nonatomic,strong) ScrollBarView *scrollBarView;

@property(nonatomic, strong) NSMutableArray *menuItems;

//
@property (nonatomic,assign) BOOL isFirst;

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
    
//    [self announcementBar];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(action_reload) name:kReloadMyMessageGroupList object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateValue)name:@"CDReadNumberChange" object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reload) name:@"updateScrollBarView" object:nil];
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
    SystemAlertViewController *alertVC = [SystemAlertViewController alertControllerWithTitle:@"公告" dataArray:announcementArray];
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
    dispatch_async(dispatch_get_main_queue(), ^{
//        [self->_tableView reloadData];
        [self reload];
    });
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
    
    __weak __typeof(self)weakSelf = self;
    __weak MessageNet *weakModel = _model;
    self.navigationItem.title = @"消息";
    self.view.backgroundColor = BaseColor;
    _tableView = [UITableView normalTable];
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
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        weakModel.page = 1;
        [strongSelf getData];
        
    }];
    
    _tableView.mj_footer = [MJRefreshAutoFooter footerWithRefreshingBlock:^{
        if (!weakModel.isMost) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            weakModel.page++;
            [strongSelf getData];
        }
    }];
    
    _tableView.StateView = [StateView StateViewWithHandle:^{
       __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf getData];
    }];
    
    //SVP_SHOW;
    [NET_REQUEST_MANAGER requestSystemNoticeWithSuccess:^(id object) {
//        [self announcementBar];
        [self.tableView reloadData];
    } fail:^(id object) {
        
    }];
    weakModel.page = 1;
    [self getData];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    SVP_DISMISS;
    //    [self updateScrollBarView];
    //    [self.tableView reloadData];
    [self reload];//s1
    [self.tableView reloadData];
    [self.carousel controllerWillAppear];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [EasyOperater remove];
    [self.carousel controllerWillDisAppear];
}

-(UIView*)updateScrollBarView{
    if(self.scrollBarView) {
        [self.scrollBarView stop];
        [self.scrollBarView removeFromSuperview];
        self.scrollBarView = nil;
    }
    if([AppModel shareInstance].noticeArray.count > 0){
        ScrollBarView *view = [ScrollBarView createWithFrame:CGRectMake(0, 0, SCREEN_WIDTH-10, 40)];
        
        UITapGestureRecognizer *tapGesturRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(scrollBarViewAction)];
        [view addGestureRecognizer:tapGesturRecognizer];
        
        
        [self.view addSubview:view];
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        NSInteger nu = 0;
        for (NSDictionary *dic in [AppModel shareInstance].noticeArray) {
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
//        [_tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
//            make.left.right.bottom.equalTo(self.view);
//            make.top.equalTo(self.scrollBarView.mas_bottom).offset(3);
//        }];
    }else{
//        [_tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
//            make.edges.equalTo(self.view);
//        }];
    }
    return self.scrollBarView;
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

#pragma mark -  一、获取我加入的群组数据 二、通知列表
- (void)getData {
    __weak __typeof(self)weakSelf = self;
    [_model getMyJoinedGroupListSuccessBlock:^(NSDictionary *dic) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        SVP_DISMISS;
        if ([dic[@"status"] integerValue] >= 1) {
            SVP_ERROR_STATUS(dic[@"error"]);
        } else {
            [strongSelf delayReload];
            if (!strongSelf.isFirst) {
                strongSelf.isFirst = YES;
            }
        }
    } failureBlock:^(NSError *err) {
        [FUNCTION_MANAGER handleFailResponse:err];
        [weakSelf reload];
    }];
    
    [NET_REQUEST_MANAGER requestMsgBannerWithId:OccurBannerAdsTypeMsg WithPictureSpe:OccurBannerAdsPictureTypeNormal success:^(id object) {
        BannerModel* model = [BannerModel mj_objectWithKeyValues:object];
        if (model.data.skAdvDetailList.count>0) {
            self.bannerModel = model;
            
            //            self.animationView = [[UIView alloc] initWithFrame:CGRectMake( 0, 0, SCREEN_WIDTH-0, kGETVALUE_HEIGHT(1010, 315, SCREEN_WIDTH))];
            
            //            self.animationView = [[UIView alloc] initWithFrame:CGRectMake(-60,0, SCREEN_WIDTH+120, kGETVALUE_HEIGHT(1200, 280, SCREEN_WIDTH+120))];
            
            self.animationView = [[UIView alloc] initWithFrame:CGRectMake(7,0, SCREEN_WIDTH-14, kGETVALUE_HEIGHT(505, 107, SCREEN_WIDTH-14))];
            
            self.animationView.tag = 200;
//            self.animationView.backgroundColor = [UIColor whiteColor];
            [self.view addSubview:self.animationView];
            if(self.carousel) {
                [self.carousel releaseTimer];
                [self.carousel removeFromSuperview];
                self.carousel = nil;
            }
            CWFlowLayout *flowLayout = [[CWFlowLayout alloc] initWithStyle:CWCarouselStyle_Normal];
            CWCarousel *carousel = [[CWCarousel alloc] initWithFrame:CGRectZero
                                                            delegate:self
                                                          datasource:self
                                                          flowLayout:flowLayout];
            carousel.translatesAutoresizingMaskIntoConstraints = NO;
            [self.animationView addSubview:carousel];
            NSDictionary *dic = @{@"view" : carousel};
            [self.animationView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[view]-0-|"
                                                                                       options:kNilOptions
                                                                                       metrics:nil
                                                                                         views:dic]];
            [self.animationView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-3-[view]-0-|"
                                                                                       options:kNilOptions
                                                                                       metrics:nil
                                                                                         views:dic]];

            carousel.isAuto = YES;
            carousel.autoTimInterval = [model.data.carouselTime intValue];
            carousel.endless = YES;
            carousel.backgroundColor = BaseColor;
            
            /* 自定pageControl */
            
            //            CGRect frame = self.animationView.bounds;
            //
            //                CWPageControl *control = [[CWPageControl alloc] initWithFrame:CGRectMake(0, -10, 300, 20)];
            //                control.center = CGPointMake(CGRectGetWidth(frame) * 0.5, CGRectGetHeight(frame) - 20);
            //                control.pageNumbers = model.data.skAdvDetailList.count;
            //                control.currentPage = 0;
            //                carousel.customPageControl = control;
            
            [carousel registerViewClass:[UICollectionViewCell class] identifier:@"cellId"];
            [carousel freshCarousel];
            self.carousel = carousel;
            
            //            MsgHeaderView* uploadImageHV = [[MsgHeaderView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, kGETVALUE_HEIGHT(1080, 372, SCREEN_WIDTH)+6) WithModel:model.data];
            ////            weakSelf.tableView.tableHeaderView = uploadImageHV;
            //            uploadImageHV.tag = 200;
            //            [self.view addSubview:uploadImageHV];
            //            [uploadImageHV actionBlock:^(id data) {
            //                BannerItem* item = data;
            //                WebViewController *vc = [[WebViewController alloc] initWithUrl:item.advLinkUrl];
            //                vc.navigationItem.title = item.name;
            //                vc.hidesBottomBarWhenPushed = YES;
            //                //[vc loadWithURL:url];
            //                [self.navigationController pushViewController:vc animated:YES];
            //            }];
            
            [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.right.bottom.equalTo(self.view);
                make.top.equalTo(self.animationView.mas_bottom).offset(3);
            }];
            
        }else{
            //            UIView* view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0.1)];
            //            weakSelf.tableView.tableHeaderView = view;
            for (UIView* view in [self.view subviews]) {
                if (view.tag == 200) {
                    [view removeFromSuperview];
                }
            }
            [weakSelf.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self.view);
            }];
            
        }
    } fail:^(id object) {
        //        UIView* view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0.1)];
        //        weakSelf.tableView.tableHeaderView = view;
        for (UIView* view in [self.view subviews]) {
            if (view.tag == 200) {
                [view removeFromSuperview];
            }
        }
        [weakSelf.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        
    }];
    
}
- (NSInteger)numbersForCarousel {
    return self.bannerModel.data.skAdvDetailList.count;
}
#pragma mark - CWCarousel Delegate
- (UICollectionViewCell *)viewForCarousel:(CWCarousel *)carousel indexPath:(NSIndexPath *)indexPath index:(NSInteger)index{
    UICollectionViewCell *cell = [carousel.carouselView dequeueReusableCellWithReuseIdentifier:@"cellId" forIndexPath:indexPath];
    cell.backgroundView = [[UIView alloc] init];
    cell.contentView.backgroundColor = BaseColor;
    cell.contentView.layer.masksToBounds = YES;
    cell.contentView.layer.cornerRadius = 8;
    UIImageView *imgView = [cell.contentView viewWithTag:kViewTag];
    if(!imgView) {
        imgView = [[UIImageView alloc] initWithFrame:cell.contentView.bounds];
        imgView.tag = kViewTag;
        imgView.backgroundColor = BaseColor;
        [cell.contentView addSubview:imgView];
        
    }
    //    NSString *name = [NSString stringWithFormat:@"%02ld.jpg", index + 1];
    //    UIImage *img = [UIImage imageNamed:name];
    //    if(!img) {
    //        NSLog(@"%@", name);
    //    }
    BannerItem* item = self.bannerModel.data.skAdvDetailList[index];
    [imgView sd_setImageWithURL:[NSURL URLWithString:item.advPicUrl] placeholderImage:[UIImage imageNamed:@"common_placeholder"]];
    return cell;
}

- (void)CWCarousel:(CWCarousel *)carousel didSelectedAtIndex:(NSInteger)index {
    
    BannerItem* item = self.bannerModel.data.skAdvDetailList[index];
    if (![FunctionManager isEmpty:item.advLinkUrl]) {
        WebViewController *vc = [[WebViewController alloc] initWithUrl:item.advLinkUrl];
        vc.navigationItem.title = item.name;
        vc.hidesBottomBarWhenPushed = YES;
        //[vc loadWithURL:url];
        [self.navigationController pushViewController:vc animated:YES];
        [NET_REQUEST_MANAGER requestClickBannerWithAdvSpaceId:self.bannerModel.data.ID Id:item.ID success:^(id object) {
            
        } fail:^(id object) {
            
        }];
        
    }
}


- (void)CWCarousel:(CWCarousel *)carousel didStartScrollAtIndex:(NSInteger)index indexPathRow:(NSInteger)indexPathRow {
    //    NSLog(@"开始滑动: %ld", index);
}


- (void)CWCarousel:(CWCarousel *)carousel didEndScrollAtIndex:(NSInteger)index indexPathRow:(NSInteger)indexPathRow {
    //    NSLog(@"结束滑动: %ld", index);
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
//    NSInteger count = self.model.myJoinDataList.count;
//    if (count>0) {
//        NSMutableArray* mutaArr = [NSMutableArray array];
//
//        for (int i=0; i<count; i++) {
//            NSIndexPath *te=[NSIndexPath indexPathForRow:i inSection:0];
//            [mutaArr addObject:te];
//        }
//        NSArray * array = [mutaArr copy];
//        
//        [self->_tableView reloadRowsAtIndexPaths:array  withRowAnimation:UITableViewRowAnimationNone];
//    }else{
//        [self->_tableView reloadData];
//    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
//        [self->_tableView reloadData];
    
        [UIView performWithoutAnimation:^{
            [self->_tableView reloadSections:[[NSIndexSet alloc]initWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
        }];
        
    
    });
}

#pragma mark - SectonHeader
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return section==0? 43.1f:0.1f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return section==0?[self updateScrollBarView]:[UIView new];
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section==0?0:_model.myJoinDataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case 0:
            return Nil;
            break;
        case 1:
            return [tableView CDdequeueReusableCellWithIdentifier:_model.myJoinDataList[indexPath.row]];
        default:
            return Nil;
            break;
    }
    
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section==1) {
        
    
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
    
    SVP_SHOW;
    __weak __typeof(self)weakSelf = self;
    
    [[MessageNet shareInstance] checkGroupId:item.groupId Completed:^(BOOL complete) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (complete) {
            SVP_DISMISS;
            [strongSelf goto_groupChat:item];
        }
        else{
            //            [MessageNet joinGroup:@{@"groupId":item.groupId,@"uid":[AppModel shareInstance].user.userId} Success:^(NSDictionary *info) {
            //                SVP_DISMISS;
            //                [self groupChat:item];
            //            } Failure:^(NSError *error) {
            //                SVP_ERROR(error);
            //            }];
        }
    }];
    }
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
//    return 0.1f;
//}
//
//- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
//    UIView *view = [[UIView alloc] init];
//    view.backgroundColor = BaseColor;
//    return view;
//}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [EasyOperater remove];
}


#pragma mark - goto群组聊天界面
- (void)goto_groupChat:(id)obj {
    ChatViewController *vc = [ChatViewController groupChatWithObj:obj];
    vc.isNewMember = NO;
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

#pragma mark - 客服弹框  常见问题
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
                                             UIViewController *vc = [[Recharge2ViewController alloc]init];
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
                                          title:@"代理中心"
                                         action:^(FYMenuItem *item) {
//                                             BecomeAgentViewController *vc = [[BecomeAgentViewController alloc] init];
//                                             vc.hidesBottomBarWhenPushed = YES;
//                                             vc.hiddenNavBar = YES;
//                                             vc.imageUrl = @"http://app.520qun.com/img/proxy_info.jpg";
//                                             [weakSelf.navigationController pushViewController:vc animated:YES];
                                             AgentCenterViewController *vc = [[AgentCenterViewController alloc] init];
                                             vc.hidesBottomBarWhenPushed = YES;
                                             [weakSelf.navigationController pushViewController:vc animated:YES];

                                         }],
                      [FYMenuItem itemWithImage:[UIImage imageNamed:@"nav_help"]
                                          title:@"帮助中心"
                                         action:^(FYMenuItem *item) {
                                             //                                              AlertViewCus *view = [AlertViewCus createInstanceWithView:nil];
                                             //                                              [view showWithText:@"等待更新，敬请期待" button:@"好的" callBack:nil];

                                             HelpCenterWebController *vc = [[HelpCenterWebController alloc] initWithUrl:nil];
                                             vc.hidesBottomBarWhenPushed = YES;
                                             [weakSelf.navigationController pushViewController:vc animated:YES];
                                             
                                         }],
//                      [FYMenuItem itemWithImage:[UIImage imageNamed:@"nav_redp_play"]
//                                          title:@"红包玩法"
//                                         action:^(FYMenuItem *item) {
////                                             HelpCenterWebController *vc = [[HelpCenterWebController alloc] initWithUrl:nil];
////                                             vc.hidesBottomBarWhenPushed = YES;
////                                             [weakSelf.navigationController pushViewController:vc animated:YES];
//                                             NSString *url = [AppModel shareInstance].commonInfo[@"chat_howplay_img"];
//                                             ImageDetailViewController *vc = [[ImageDetailViewController alloc] init];
//                                             vc.imageUrl = url;
//                                             vc.hiddenNavBar = YES;
//                                             vc.hidesBottomBarWhenPushed = YES;
//                                             vc.title = @"红包玩法";
//                                             [weakSelf.navigationController pushViewController:vc animated:YES];
//                                         }],
                      nil];
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
