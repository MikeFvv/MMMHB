//
//  AllUserViewController.m
//  Project
//
//  Created by mini on 2018/8/16.
//  Copyright © 2018年 CDJay. All rights reserved.
//

#import "AllUserViewController.h"
#import "UserTableViewCell.h"
#import "GroupNet.h"

// 群成员控制器
@interface AllUserViewController ()<UITableViewDataSource,UITableViewDelegate>{
    UITableView *_tableView;
}
@property (nonatomic ,strong) GroupNet *model;

@end

@implementation AllUserViewController
+ (AllUserViewController *)allUser:(id)obj {
    AllUserViewController *vc = [[AllUserViewController alloc]init];
    vc.model = obj;
    return vc;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self initSubviews];
    [self initLayout];
}

#pragma mark ----- Data
- (void)initData{
    if (_model == nil) {
        _model = [GroupNet new];
    }
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
    self.navigationItem.title = @"所有成员";
    
    _tableView = [UITableView groupTable];
    [self.view addSubview:_tableView];
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = BaseColor;
    _tableView.backgroundView = view;
    _tableView.separatorInset = UIEdgeInsetsMake(0, 73, 0, 0);
    _tableView.separatorColor = TBSeparaColor;
    _tableView.rowHeight = 70;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView reloadData];
    
    __weak GroupNet *weakModel = _model;
    __weak __typeof(self)weakSelf = self;
    _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        weakModel.page = 1;
        [strongSelf getGroupUsersData];
    }];
    
    _tableView.mj_footer = [MJRefreshAutoFooter footerWithRefreshingBlock:^{
       __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (!weakModel.isMost) {
            weakModel.page++;
            [strongSelf getGroupUsersData];
        }
    }];
}

- (void)getGroupUsersData {
    __weak __typeof(self)weakSelf = self;
    [_model queryGroupUserGroupId:self.groupId successBlock:^(NSDictionary *info) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
         [strongSelf->_tableView.mj_header endRefreshing];
         [strongSelf->_tableView.mj_footer endRefreshing];
         [strongSelf->_tableView reloadData];
        
    } failureBlock:^(NSError *error) {
        SVP_ERROR(error);
    }];
}


#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _model.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"user"];
    if (cell == nil) {
        cell = [[UserTableViewCell alloc]initWithStyle:0 reuseIdentifier:@"user"];
    }
    cell.obj = _model.dataList[indexPath.row];
    return cell;//[tableView CDdequeueReusableCellWithIdentifier:_dataList[indexPath.row]];
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

@end
