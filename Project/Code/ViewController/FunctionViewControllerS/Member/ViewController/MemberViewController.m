//
//  MemberViewController.m
//  Project
//
//  Created by mini on 2018/7/31.
//  Copyright © 2018年 CDJay. All rights reserved.
//

#import "MemberViewController.h"
#import "MemberNet.h"
#import "MemberHeadView.h"
#import "MemberRow.h"
#import "WXShareModel.h"
#import "WXManage.h"

@interface MemberViewController ()<UITableViewDelegate,UITableViewDataSource>{
    UITableView *_tableView;
    MemberHeadView *_headView;
    MemberNet *_model;
}

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
    [_headView update];
}

#pragma mark ----- Data
- (void)initData{
    _model = [[MemberNet alloc]init];
}


#pragma mark ----- Layout
- (void)initLayout{
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

#pragma mark ----- subView
- (void)initSubviews{
    
    self.navigationItem.title = @"我的";
    CDWeakSelf(self);
    _headView = [[MemberHeadView alloc]initWithFrame:CGRectMake(0, 0, CDScreenWidth, 90)];
    [_headView addTarget:self action:@selector(action_info) forControlEvents:UIControlEventTouchUpInside];
    _headView.backgroundColor = [UIColor whiteColor];
    _tableView = [UITableView groupTable];
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
}

#pragma mark net
- (void)getUserInfo{
    CDWeakSelf(self);
    [AppModel getUserInfoSuccess:^(NSDictionary *info) {
        CDStrongSelf(self);
        [self update];
    } Failure:^(NSError *error) {
        CDStrongSelf(self);
        SV_ERROR(error);
        [self update];
    }];
}

- (void)update{
    [_headView update];
    [_tableView.mj_header endRefreshing];
    [_tableView reloadData];
}

#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _model.dataList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *list = _model.dataList[section];
    return list.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 8.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [tableView CDdequeueReusableCellWithIdentifier:_model.dataList[indexPath.section][indexPath.row]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            CDWeakSelf(self);
            WXShareModel *model = [[WXShareModel alloc]init];
            model.title = WXShareTitle;
            model.imageIcon = [UIImage imageNamed:@"my-recharge"];
            model.link = WXShareLink;
            model.content = WXShareDescription;
            model.WXShareType = 1;
            [[WXManage shareInstance]wxShareObj:model Success:^{
                CDStrongSelf(self);
                [self action_sign];
            } Failure:^(NSError *error) {
                SV_ERROR(error);
            }];
            
        }
        else if (indexPath.row == 1){
            
        }
        
        else if (indexPath.row == 7){
            
        }
        else{
            CDTableModel *model = _model.dataList[indexPath.section][indexPath.row];
            MemberRow *row = (MemberRow *)model.obj;
            UIViewController *vc = [[NSClassFromString(row.vcName)alloc]init];
            if ([row.vcName isEqualToString:@"RecommendedViewController"]) {
                vc.title = [NSString stringWithFormat:@"%@的玩家",APP_MODEL.user.userNick];
            }
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
        }
        
    }
    else{//退出
        [AppModel loginOut];
    }
}

#pragma mark action
- (void)action_sign{
    [MemberNet SignObj:@{@"uid":APP_MODEL.user.userId} Success:^(NSDictionary *info) {
        NSLog(@"%@",info);
        SV_SUCCESS_STATUS(@"红包已领取");
    } Failure:^(NSError *error) {
        SV_ERROR(error);
    }];
}

- (void)action_info{
    UIViewController *vc = [[NSClassFromString(@"MemberInfoViewController")alloc]init];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
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
