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
#import "BillTableViewCell.h"
#import "EnvelopeNet.h"
#import "RedPackedDetListController.h"

@interface BillViewController ()<UITableViewDelegate,UITableViewDataSource>{
    UITableView *_tableView;
}
@property(nonatomic,strong)NSMutableArray *billTypeList;
@property(nonatomic,strong)BillNet *model;
@property(nonatomic,strong)BillHeadView *headView;

@property(nonatomic, copy) NSString *sendPId;

@end

@implementation BillViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.billTypeList = [[NSMutableArray alloc] init];
    NSDictionary *dic = @{@"id":@"999",@"title":@"全部"};
    [self.billTypeList addObject:dic];
    [self initData];
    [self initSubviews];
    [self initLayout];
    [self getBillType];
    SVP_SHOW;
    [self getData];
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
    self.navigationItem.title = @"账单记录";
    WEAK_OBJ(weakSelf, self);
    __weak BillNet *weakModel = _model;
    
    _tableView = [UITableView groupTable];
    [self.view addSubview:_tableView];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = 119;
    _tableView.separatorColor = TBSeparaColor;
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = BaseColor;
    _tableView.backgroundView = view;
    _headView = [BillHeadView headView];
    _headView.billTypeList = self.billTypeList;
    _headView.beginTime = _model.beginTime;
    _headView.endTime = _model.endTime;
    _headView.endChange = ^(id time) {
        [weakSelf datePickerByType:1];
    };
    _headView.beginChange = ^(id time) {
        [weakSelf datePickerByType:0];
    };
    _headView.TypeChange = ^(NSInteger type) {
        NSDictionary *dic = weakSelf.billTypeList[type];
        NSInteger tt = [dic[@"id"] integerValue];
        weakModel.type = tt;
        [weakSelf performSelector:@selector(getData) withObject:nil afterDelay:0.5];
    };
    
    _tableView.tableHeaderView = _headView;
    
    _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf getData];
    }];
    
    _tableView.mj_footer = [MJRefreshAutoFooter footerWithRefreshingBlock:^{
        if (!weakModel.isMost) {
            [weakSelf getDataByPage:weakModel.page];
        }
    }];
}

-(void)getBillType{
    WEAK_OBJ(weakSelf, self);
    [NET_REQUEST_MANAGER requestBillTypeWithSuccess:^(id object) {
        NSArray *arr = object[@"data"];
        [weakSelf.billTypeList addObjectsFromArray:arr];
    } fail:^(id object) {
        [FUNCTION_MANAGER handleFailResponse:object];
    }];
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
    [self getData];
}

- (void)getData{
    [self getDataByPage:0];
}

-(void)getDataByPage:(NSInteger)page{
    WEAK_OBJ(weakSelf, self);
    [_model getBillListWithPage:page success:^(NSDictionary *info) {
        if(weakSelf.model.dataList.count == 0)
            SVP_SUCCESS_STATUS(@"无相关数据");
        else
            SVP_DISMISS;
        [weakSelf reload];
    } failure:^(NSError *error) {
        [weakSelf reload];
        [FUNCTION_MANAGER handleFailResponse:error];
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
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CDScreenWidth, 36)];
        UILabel *label = [UILabel new];
        [view addSubview:label];
        label.font = [UIFont systemFontOfSize2:13];
        label.textColor = Color_9;
        label.text = @"账单";
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
    return (section == 0)?36:8;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CDTableModel *model = [_model.dataList objectAtIndex:indexPath.section];
    NSDictionary *dic = model.obj;
    NSMutableString *tStr = [[NSMutableString alloc] initWithString:@""];
    NSString *title = dic[@"title"];
    if(title.length > 0)
        [tStr appendString:dic[@"title"]];
    NSString *intro = dic[@"intro"];
    if(intro.length > 0){
        if(tStr.length > 0){
            [tStr appendFormat:@"(%@)",dic[@"intro"]];
        }else
            [tStr appendString:dic[@"intro"]];
    }
    if(tStr.length > 0){
        CGSize size = CGSizeMake(SCREEN_WIDTH - 15, 999);
        CGSize titleSize;
        titleSize = [tStr sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:size lineBreakMode:0];
        return titleSize.height + 108;
    }
    return 125;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _model.dataList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    BillTableViewCell *cell = (BillTableViewCell *)[tableView CDdequeueReusableCellWithIdentifier:_model.dataList[indexPath.section]];
    cell.detailBtn.userInteractionEnabled = NO;
    //[cell.detailBtn addTarget:self action:@selector(detailAction:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CDTableModel *model = _model.dataList[indexPath.section];
    self.sendPId = [model.obj[@"userId"] stringValue];
    NSLog(@"%zd", indexPath.section);
    switch ([model.obj[@"billtId"] integerValue]) {
        case 3:
        case 4:
        case 16:
        case 17:
            [self getRedpDetGrabId:model.obj[@"bizId"]];
            break;
        case 5:
        case 6:
        case 18:
            [self getRedpDetSendId:model.obj[@"bizId"]];
            break;
        default:
            break;
    }
}

-(void)getRedpDetSendId:(id)packetId {
    __weak __typeof(self)weakSelf = self;
    SVP_SHOW;
    [[EnvelopeNet shareInstance] getRedpDetSendId:packetId successBlock:^(NSDictionary *dic) {
        if (([[dic objectForKey:@"code"] integerValue] == 0)) {
            SVP_DISMISS;
            [weakSelf onGotoRedPackedDet];
        } else {
            SVP_ERROR_STATUS([dic objectForKey:@"msg"]);
        }
        
    } failureBlock:^(NSError *error) {
        [FUNCTION_MANAGER handleFailResponse:error];
    }];
}

-(void)getRedpDetGrabId:(id)packetId {
    __weak __typeof(self)weakSelf = self;
    SVP_SHOW;
    [[EnvelopeNet shareInstance] getRedpDetGrabId:packetId successBlock:^(NSDictionary *dic) {
        if (([[dic objectForKey:@"code"] integerValue] == 0)) {
            [weakSelf onGotoRedPackedDet];
            SVP_DISMISS;
        } else {
            SVP_ERROR_STATUS([dic objectForKey:@"msg"]);
        }
    } failureBlock:^(NSError *error) {
        [FUNCTION_MANAGER handleFailResponse:error];
    }];
}

#pragma mark -  goto红包详情
- (void)onGotoRedPackedDet {
    [self.view endEditing:YES];
    //    CDPush(self.navigationController, CDPVC(@"RedPackedDetListController", obj), YES);
    
    RedPackedDetListController *vc = [[RedPackedDetListController alloc] init];
    vc.objPar = @(-1);
    vc.bankerId = self.sendPId;
    [self.navigationController pushViewController:vc animated:YES];
    
}

-(void)detailAction:(id)sender{
    //    UITableViewCell *cell = [FUNCTION_MANAGER cellForChildView:sender];
    //    NSIndexPath *path = [_tableView indexPathForCell:cell];
    //    NSInteger section = path.section;
    //    CDTableModel *model = _model.dataList[section];
    //    NSDictionary *dic = model.obj;
    NSLog(@"去红包详情");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated{
    WEAK_OBJ(weakSelf, self);
    [NET_REQUEST_MANAGER requestUserInfoWithSuccess:^(id object) {
        weakSelf.headView.balanceLabel.text = [NSString stringWithFormat:@"余额：%@元",APP_MODEL.user.balance];
    } fail:^(id object) {
    
    }];

}
@end
