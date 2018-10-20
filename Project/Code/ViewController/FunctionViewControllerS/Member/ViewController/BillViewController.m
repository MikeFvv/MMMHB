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
#import "NetRequestManager.h"

@interface BillViewController ()<UITableViewDelegate,UITableViewDataSource>{
    UITableView *_tableView;
}
@property(nonatomic,strong)BillNet *model;
@property(nonatomic,strong)BillHeadView *headView;
@end

@implementation BillViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self initSubviews];
    [self initLayout];
    [self getBillType];
    _model.page = 1;
    SV_SHOW;
    [self getData];
}

#pragma mark ----- Data
- (void)initData{
    _model = [[BillNet alloc]init];
    _model.type = 999;
}


#pragma mark ----- Layout
- (void)initLayout{
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

#pragma mark ----- subView
- (void)initSubviews{
    
    self.navigationItem.title = @"我的账单";
    
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
    _headView.billTypeArray = _model.billTypeArray;
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
        NSArray * typeList = self.model.billTypeArray;
        NSDictionary *typeDic = typeList[type];
        weakModel.type = [typeDic[@"billtId"] integerValue];
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
        if (!weakModel.isMost) {
            weakModel.page ++;
            [self getData];
        }
    }];
}

-(void)getBillType{
    WEAK_OBJ(weakObj, self);
    [NET_REQUEST_MANAGER requestBillTypeWithSuccess:^(id object) {
        NSArray *array = object[@"data"];
        NSMutableArray *newArr = [[NSMutableArray alloc] initWithArray:array];
        NSDictionary *dic = @{@"billtId":@"999",@"billtTitle":@"所有"};
        [newArr insertObject:dic atIndex:0];
        weakObj.model.billTypeArray = newArr;
        weakObj.headView.billTypeArray = weakObj.model.billTypeArray;
    } fail:^(id object) {
    }];
}

//-(void)viewDidAppear:(BOOL)animated{
//    [super viewDidAppear:animated];
//    [self->_tableView.mj_header beginRefreshing];
//}

- (void)datePickerByType:(NSInteger)type{
    __weak typeof(self) weakSelf = self;
    NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = nil;
    if(type == 1)
        date = [formatter dateFromString:_model.endTime];
    else
        date = [formatter dateFromString:_model.beginTime];
    double inv = [date timeIntervalSince1970];
    [CDAlertViewController showDatePikerDate:^(NSString *date) {
        [weakSelf updateType:type date:date];
    } defaultTime:inv];
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
    WEAK_OBJ(weakObj, self);
    [_model getBillListWithSuccess:^(id object) {
        SV_DISMISS;
        [weakObj reload];
    } Failure:^(id object) {
        [FUNCTION_MANAGER handleFailResponse:object];
        [weakObj reload];
    }];
}

- (void)reload{
    [_tableView.mj_footer endRefreshing];
    [_tableView.mj_header endRefreshing];
    [_tableView reloadData];
    if (_model.isMost) {
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
