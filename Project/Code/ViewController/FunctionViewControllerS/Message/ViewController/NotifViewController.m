//
//  NotifViewController.m
//  Project
//
//  Created by mini on 2018/8/15.
//  Copyright © 2018年 CDJay. All rights reserved.
//

#import "NotifViewController.h"
#import "NotifMessageNet.h"
#import "NotifDetailViewController.h"

@interface NotifViewController ()<UITableViewDelegate,UITableViewDataSource>{
    UITableView *_tableView;
    NotifMessageNet *_model;
}

@end

@implementation NotifViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self initSubviews];
    [self initLayout];
}

#pragma mark ----- Data
- (void)initData{
    _model = [NotifMessageNet new];
}


#pragma mark ----- Layout
- (void)initLayout{
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

#pragma mark ----- subView
- (void)initSubviews{
    
    self.view.backgroundColor = BaseColor;
    self.navigationItem.title = @"通知中心";
    __weak typeof(self) weakSelf = self;
    __weak NotifMessageNet *weakModel = _model;
    _tableView = [UITableView normalTable];
    [self.view addSubview:_tableView];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = 81;
    _tableView.backgroundColor = BaseColor;
    _tableView.separatorColor = TBSeparaColor;
    _tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
    _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        weakModel.page = 1;
        [weakSelf getData];
    }];
    
    _tableView.mj_footer = [MJRefreshAutoFooter footerWithRefreshingBlock:^{
        weakModel.page ++;
        [weakSelf getData];
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self->_tableView.mj_header beginRefreshing];
    });
}

- (void)getData{
    
    [_model getNotifMessageObj:@{@"uid":APP_MODEL.user.userId,@"is_read":@"0",@"page":@(_model.page)} Success:^(NSDictionary *dic) {
        [self->_tableView.mj_header endRefreshing];
        [self->_tableView.mj_footer endRefreshing];
        [self->_tableView reloadData];
    } Failure:^(NSError *error) {
        [self->_tableView.mj_header endRefreshing];
        SV_ERROR(error);
    }];
}


#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _model.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [tableView CDdequeueReusableCellWithIdentifier:_model.dataList[indexPath.row]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    CDTableModel *model = _model.dataList[indexPath.row];
    NotifDetailViewController *vc = [NotifDetailViewController detailVc:model.obj];
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
