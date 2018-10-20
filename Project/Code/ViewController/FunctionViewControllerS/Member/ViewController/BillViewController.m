//
//  BillViewController.m
//  Project
//
//  Created by mini on 2018/8/1.
//  Copyright © 2018年 CDJay. All rights reserved.
//

#import "BillViewController.h"
#import "BillHeadView.h"
#import "BillNet.h"
#import "CDAlertViewController.h"

@interface BillViewController ()<UITableViewDelegate,UITableViewDataSource>{
    UITableView *_tableView;
    BillHeadView *_headView;
    BillNet *_model;
}

@end

@implementation BillViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self initSubviews];
    [self initLayout];
}

#pragma mark ----- Data
- (void)initData{
    _model = [[BillNet alloc]init];
}


#pragma mark ----- Layout
- (void)initLayout{
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

#pragma mark ----- subView
- (void)initSubviews{
    
    self.navigationItem.title = @"我的明细";
    
    CDWeakSelf(self);
    __weak BillNet *weakModel = _model;
    
    _tableView = [UITableView groupTable];
    [self.view addSubview:_tableView];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = 109;
    _headView = [BillHeadView headView];
    _headView.beginTime = _model.beginTime;
    _headView.endTime = _model.endTime;
    _headView.endChange = ^(id time) {
        CDStrongSelf(self);
        [self datePickerByType:1];
    };
    _headView.beginChange = ^(id time) {
        CDStrongSelf(self);
        [self datePickerByType:0];
    };
    _headView.TypeChange = ^(NSInteger type) {
        CDStrongSelf(self);
        weakModel.type = type;
        weakModel.page = 1;
        [self getData];
    };
    
    _tableView.tableHeaderView = _headView;
    
    _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        CDStrongSelf(self);
        weakModel.page = 1;
        [self getData];
    }];
    
    _tableView.mj_footer = [MJRefreshAutoFooter footerWithRefreshingBlock:^{
        CDStrongSelf(self);
        if (!weakModel.IsMost) {
            weakModel.page ++;
            [self getData];
        }
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self->_tableView.mj_header beginRefreshing];
    });
}

- (void)datePickerByType:(NSInteger)type{
    __weak typeof(self) weakSelf = self;
    [CDAlertViewController showDatePikerDate:^(NSString *date) {
        [weakSelf updateType:type date:date];
    }];
}

- (void)updateType:(NSInteger)type date:(NSString *)date{
    if (type == 0) {
        _headView.beginTime = date;
        _model.beginTime = date;
    }else{
        _headView.endTime = date;
        _model.endTime = date;
    }
    _model.page = 1;
    [self getData];
}

- (void)getData{
    
    CDWeakSelf(self);//
    NSString *range_time = [NSString stringWithFormat:@"%ld|%ld",timeStamp_string(_model.beginTime, CDDateDay),timeStamp_string(_model.endTime, CDDateDay)];
    [_model GetBillObj:@{@"range_time":range_time,@"uid":APP_MODEL.user.userId,@"type":@(_model.type),@"page":@(_model.page)} Success:^(NSDictionary *info) {
        CDStrongSelf(self);
        [self reload];
    } Failure:^(NSError *error) {
        CDStrongSelf(self);
        [self reload];
        SV_ERROR(error);
    }];
}

- (void)reload{
    [_tableView.mj_footer endRefreshing];
    [_tableView.mj_header endRefreshing];
    [_tableView reloadData];
    if (_model.IsMost) {
        [_tableView.mj_footer endRefreshingWithNoMoreData];
    }
}


#pragma mark UITableViewDataSource
- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CDScreenWidth, 25)];
        UILabel *label = [UILabel new];
        [view addSubview:label];
        label.font = [UIFont scaleFont:13];
        label.textColor = Color_9;
        label.text = @"账单记录";
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(view.mas_left).offset(15);
            make.top.bottom.equalTo(view);
        }];
        return view;
    }
    else
        return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return (section == 0)?25:8;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _model.dataList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [tableView CDdequeueReusableCellWithIdentifier:_model.dataList[indexPath.section]];
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
