//
//  MemberViewController.m
//  Project
//
//  Created by mini on 2018/7/31.
//  Copyright © 2018年 CDJay. All rights reserved.
//

#import "MemberViewController.h"
#import "MemberHeadView.h"
#import "WXShareModel.h"
#import "WXManage.h"
#import "MemberCell.h"
#import "RecommendedViewController.h"
#import "MakeMoneyViewController.h"
#import "BillViewController.h"
#import "WithdrawalViewController.h"
#import "MemberInfoViewController.h"
#import "SettingViewController.h"
#import "TopupViewController.h"
#import "ShareViewController.h"
#import "ReportFormsViewController.h"
#import "ActivityViewController.h"
#import "AlertViewCus.h"
#import "BecomeAgentViewController.h"
#import "WheelViewController.h"
#import "AddBankCardViewController.h"
#import "WithdrawMainViewController.h"
#import "RechargeViewController.h"
#import "DepositOrderController.h"
#import "WebViewController.h"
#import "HelpCenterWebController.h"

@implementation CellData

-(instancetype)initWithTitle:(NSString *)title subTitle:(NSString *)subTitle icon:(NSString *)icon showArrow:(BOOL)showArrow tag:(NSInteger)tag{
    if(self = [super init]){
        self.title = title;
        self.subTitle = subTitle;
        self.icon = icon;
        self.showArrow = showArrow;
        self.tag = tag;
    }
    return self;
}
@end

@interface MemberViewController ()<UITableViewDelegate,UITableViewDataSource>{
    UITableView *_tableView;
    MemberHeadView *_headView;
    NSInteger _headHeight;
}
@property(nonatomic,strong)NSMutableArray *dataArray;
@property(nonatomic,strong)UIImageView *imageBgView;

@end

@implementation MemberViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self initSubviews];
    [self initLayout];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    SVP_DISMISS;
    [_headView update];
    
    if(self.navigationController.navigationBarHidden == NO)
        [self.navigationController setNavigationBarHidden:YES animated:YES];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self getUserInfo];
}

#pragma mark ----- Data
- (void)initData{
    self.dataArray = [[NSMutableArray alloc] init];
    NSMutableArray *sectionArray1 = [[NSMutableArray alloc] init];
    
//    CellData *cellData1 = [[CellData alloc] initWithTitle:@"邀请码" subTitle:APP_MODEL.user.invitecode icon:@"my-code" showArrow:NO tag:1];
//    [sectionArray1 addObject:cellData1];

    CellData *cellData13 = [[CellData alloc] initWithTitle:@"保存下载页" subTitle:nil icon:@"me_down" showArrow:NO tag:13];
    [sectionArray1 addObject:cellData13];
    CellData *cellData14 = [[CellData alloc] initWithTitle:@"账单记录" subTitle:nil icon:@"my-zdjl" showArrow:NO tag:14];
    [sectionArray1 addObject:cellData14];
    
//    CellData *cellData12 = [[CellData alloc] initWithTitle:@"幸运大转盘" subTitle:nil icon:@"my-lottery" showArrow:NO tag:12];
//    [sectionArray1 addObject:cellData12];
    CellData *cellData10 = [[CellData alloc] initWithTitle:@"申请代理" subTitle:nil icon:@"my-2b" showArrow:NO tag:10];
    [sectionArray1 addObject:cellData10];
    CellData *cellData4 = [[CellData alloc] initWithTitle:@"下级玩家" subTitle:nil icon:@"my-player" showArrow:NO tag:4];
    [sectionArray1 addObject:cellData4];
    //if(APP_MODEL.user.agentFlag)
    {
        CellData *cellData8 = [[CellData alloc] initWithTitle:@"我的报表" subTitle:nil icon:@"my-report" showArrow:NO tag:8];
        [sectionArray1 addObject:cellData8];
    }
//    CellData *cellData9 = [[CellData alloc] initWithTitle:@"活动中心" subTitle:nil icon:@"my-huodong" showArrow:NO tag:9];
//    [sectionArray1 addObject:cellData9];
    CellData *cellData2 = [[CellData alloc] initWithTitle:@"充值中心" subTitle:nil icon:@"my-recharge" showArrow:NO tag:2];
    [sectionArray1 addObject:cellData2];
    CellData *cellData3 = [[CellData alloc] initWithTitle:@"提现中心" subTitle:nil icon:@"my-withdrawals" showArrow:NO tag:3];
    [sectionArray1 addObject:cellData3];
    
//    CellData *cellData11 = [[CellData alloc] initWithTitle:@"游戏介绍" subTitle:nil icon:@"my-withdrawals" showArrow:NO tag:11];
//    [sectionArray1 addObject:cellData11];
    
    [self.dataArray addObject:sectionArray1];
    
    NSString *s = [FUNCTION_MANAGER getApplicationVersion];
    CellData *cellData5 = [[CellData alloc] initWithTitle:@"版本" subTitle:s icon:@"my-version" showArrow:NO tag:5];
    CellData *cellData6 = [[CellData alloc] initWithTitle:@"设置" subTitle:nil icon:@"my-option" showArrow:NO tag:6];
    CellData *cellData7 = [[CellData alloc] initWithTitle:@"退出" subTitle:nil icon:@"my-exit" showArrow:NO tag:7];
    NSArray *sectionArray2 = [NSArray arrayWithObjects:cellData5,cellData6,cellData7, nil];
    [self.dataArray addObject:sectionArray2];
}

#pragma mark ----- Layout
- (void)initLayout{
    if(SCREEN_HEIGHT >= 812){
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self.view);
            make.top.equalTo(self.view).offset(-26);
        }];
    }else{
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self.view);
            make.top.equalTo(self.view).offset(-22);
        }];
    }
}

#pragma mark ----- subView
- (void)initSubviews{
    self.navigationItem.title = @"我的";
    CDWeakSelf(self);
    
    _headHeight = 200;
    if(SCREEN_HEIGHT >= 812)
        _headHeight += 4;
    self.imageBgView.frame = CGRectMake(0, 0, CDScreenWidth, _headHeight);
    
    _headView = [[MemberHeadView alloc]initWithFrame:CGRectMake(0, 0, CDScreenWidth, _headHeight)];
    [_headView addTarget:self action:@selector(action_info) forControlEvents:UIControlEventTouchUpInside];
    [_headView.zuanQianBtn addTarget:self action:@selector(zuanQian) forControlEvents:UIControlEventTouchUpInside];
    [_headView.zhangDanBtn addTarget:self action:@selector(helpCenter) forControlEvents:UIControlEventTouchUpInside];
    _headView.backgroundColor = [UIColor clearColor];

    _tableView = [UITableView groupTable];
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = BaseColor;
    _tableView.backgroundView = view;
    [self.view addSubview:_tableView];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.separatorColor = TBSeparaColor;
    _tableView.tableHeaderView = _headView;
    _tableView.rowHeight = 50.f;
    _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        CDStrongSelf(self);
        [self getUserInfo];
    }];
    
    self.imageBgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navBarBg"]];//me_Background
    [_tableView.backgroundView addSubview:self.imageBgView];
    
    if([_tableView.mj_header respondsToSelector:@selector(stateLabel)]){
        UILabel *label = (UILabel *)[_tableView.mj_header performSelector:@selector(stateLabel)];
        label.textColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.8];
    }
    if([_tableView.mj_header respondsToSelector:@selector(lastUpdatedTimeLabel)]){
        UILabel *label = (UILabel *)[_tableView.mj_header performSelector:@selector(lastUpdatedTimeLabel)];
        label.textColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.8];
    }
}

#pragma mark net
- (void)getUserInfo{
    CDWeakSelf(self);
    [NET_REQUEST_MANAGER requestUserInfoWithSuccess:^(id object) {
        [weakself update];
    } fail:^(id object) {
        [FUNCTION_MANAGER handleFailResponse:object];
    }];
}

- (void)update{
    [_headView update];
    [_tableView.mj_header endRefreshing];
    [_tableView reloadData];
}

#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataArray.count;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = BaseColor;
    return view;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = BaseColor;
    return view;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *list = self.dataArray[section];
    return list.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(section == 0)
        return 9;
    return 5.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CellData *cellData = self.dataArray[indexPath.section][indexPath.row];
    NSInteger row = indexPath.row;
    NSString *cellIdentifier = [NSString stringWithFormat:@"%ld_%ld",(long)indexPath.section,(long)row];
    MemberCell *cell =(MemberCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[MemberCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.backgroundColor = [UIColor whiteColor];
        [cell.itemIcon mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(@20);
        }];
        cell.itemIcon.image = [UIImage imageNamed:cellData.icon];
        cell.itemLabel.text = cellData.title;
        if(cellData.showArrow)
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        else
            cell.accessoryType = UITableViewCellAccessoryNone;
        
        if(cellData.tag == 1){
            cell.rightArrowImage.hidden = YES;
            UILabel *copyLabel = [[UILabel alloc] init];
            copyLabel.textColor = COLOR_X(245, 116, 35);
            copyLabel.layer.masksToBounds = YES;
            copyLabel.layer.borderColor = copyLabel.textColor.CGColor;
            copyLabel.layer.borderWidth = 0.5;
            copyLabel.textAlignment = NSTextAlignmentCenter;
            copyLabel.layer.cornerRadius = 4.0;
            [cell.contentView addSubview:copyLabel];
            copyLabel.text = @"复制";
            copyLabel.font = [UIFont systemFontOfSize2:13];
            [copyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(cell.contentView).offset(-15);
                make.centerY.equalTo(cell.contentView);
                make.width.equalTo(@60);
                make.height.equalTo(@26);
            }];

            [cell.rightLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(cell.contentView).offset(-83);
            }];
        }
        if(indexPath.section == 1 && indexPath.row == 0){
            cell.rightArrowImage.hidden = YES;
        }
    }
    cell.rightLabel.text = cellData.subTitle;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //    WXShareModel *model = [[WXShareModel alloc]init];
    //    model.title = WXShareTitle;
    //    model.imageIcon = [UIImage imageNamed:@"my-recharge"];
    //    model.link = WXShareLink;
    //    model.content = WXShareDescription;
    //    model.WXShareType = 1;
    //    [[WXManage shareInstance]wxShareObj:model Success:^{
    //    } Failure:^(NSError *error) {
    //    }];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    CellData *data = self.dataArray[indexPath.section][indexPath.row];
    if (data.tag == 1){
        UIPasteboard * pastboard = [UIPasteboard generalPasteboard];
        pastboard.string = APP_MODEL.user.invitecode;
        SVP_SUCCESS_STATUS(@"复制成功");
    } else if(data.tag == 2){
        PUSH_C(self, RechargeViewController, YES);
    } else if (data.tag == 3){
        PUSH_C(self, WithdrawMainViewController, YES);
    } else if(data.tag == 4){
        PUSH_C(self, RecommendedViewController, YES);
    } else if(data.tag == 5){
        SVP_SHOW;
        [FUNCTION_MANAGER checkVersion:YES];
    } else if(data.tag == 6){
        PUSH_C(self, SettingViewController, YES);
    }  else if(data.tag == 7){
        AlertViewCus *view = [AlertViewCus createInstanceWithView:nil];
        [view showWithText:@"是否退出？" button1:@"取消" button2:@"退出" callBack:^(id object) {
            NSInteger tag = [object integerValue];
            if(tag == 1){
                [self logout];
            }
        }];
        
//        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"是否退出？" preferredStyle:UIAlertControllerStyleAlert];
//        [alertController modifyColor];
//        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"退出" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//            [APP_MODEL logout];
//        }];
//        [okAction setValue:Color_0 forKey:@"_titleTextColor"];
//        [alertController addAction:okAction];
//        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
//        [cancelAction setValue:Color_0 forKey:@"_titleTextColor"];
//        [alertController addAction:cancelAction];
//        [self presentViewController:alertController animated:YES completion:nil];
        
    } else if(data.tag == 8){
        ReportFormsViewController *vc = [[ReportFormsViewController alloc] init];
        vc.hidesBottomBarWhenPushed = YES;
        vc.userId = APP_MODEL.user.userId;
        [self.navigationController pushViewController:vc animated:YES];
    } else if(data.tag == 9){
        ActivityViewController *vc = [[ActivityViewController alloc] init];
        vc.vcTitle = @"活动中心";
        vc.userId = APP_MODEL.user.userId;
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    } else if(data.tag == 10){
        BecomeAgentViewController *vc = [[BecomeAgentViewController alloc] init];
        vc.hidesBottomBarWhenPushed = YES;
        vc.hiddenNavBar = YES;
        vc.imageUrl = @"http://app.520qun.com/img/proxy_info.jpg";
        [self.navigationController pushViewController:vc animated:YES];
    } else if(data.tag == 11){
        GuideView *guideView = [[GuideView alloc] initWithArray:@[@"guide0",@"guide1",@"guide2"] target:nil selector:nil];
        [guideView showWithAnimationWithAni:YES];
    } else if(data.tag == 12){
        WheelViewController *vc = [[WheelViewController alloc] init];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    } else if(data.tag == 13){
        NSString *url = [NSString stringWithFormat:@"%@%@",kDownloadPageURL,APP_MODEL.user.invitecode];
        if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:url]])
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
//        WebViewController *vc = [[WebViewController alloc] initWithUrl:url];
//        vc.title = @"下载页";
//        vc.hidesBottomBarWhenPushed = YES;
//        [self.navigationController pushViewController:vc animated:YES];
    }else if(data.tag == 14)
        [self zhangDan];
}

-(void)logout{
    SVP_SHOW;
    [NET_REQUEST_MANAGER removeTokenWithSuccess:^(id object) {
        SVP_DISMISS;
        [APP_MODEL logout];
    } fail:^(id object) {
#ifdef DEBUG
        [APP_MODEL logout];
#endif
        [FUNCTION_MANAGER handleFailResponse:object];
    }];
}
#pragma mark action
- (void)action_info{
    PUSH_C(self, MemberInfoViewController, YES);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)zuanQian{
    //PUSH_C(self, MakeMoneyViewController, YES);
    PUSH_C(self, ShareViewController, YES);
}

-(void)zhangDan{
    PUSH_C(self, BillViewController, YES);
}

-(void)helpCenter{
//    AlertViewCus *view = [AlertViewCus createInstanceWithView:nil];
//    [view showWithText:@"等待更新，敬请期待" button:@"好的" callBack:nil];
//    return;
    
    NSString *url = [NSString stringWithFormat:@"%@/dist/#/index/helpCenter?accesstoken=%@", [AppModel shareInstance].commonInfo[@"website.address"], [AppModel shareInstance].user.token];
    HelpCenterWebController *vc = [[HelpCenterWebController alloc] initWithUrl:url];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    NSInteger offsetY = scrollView.contentOffset.y;
    CGRect rect = self.imageBgView.frame;
    //NSInteger width = SCREEN_WIDTH * (1 - offsetY/SCREEN_WIDTH);
    rect.size.height = _headHeight + 20 - offsetY + 35;
//    if(width < SCREEN_WIDTH)
//        width = SCREEN_WIDTH;
//    rect.size.width = width;
//    NSInteger a = SCREEN_WIDTH - width;
//    rect.origin.x = a;
    rect.origin.y = -35;
    self.imageBgView.frame = rect;
}
@end
