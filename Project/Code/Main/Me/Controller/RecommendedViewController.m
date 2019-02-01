//
//  RecommendedViewController.m
//  Project
//
//  Created by mini on 2018/8/1.
//  Copyright © 2018年 CDJay. All rights reserved.
//

#import "RecommendedViewController.h"
#import "RecommendNet.h"
#import "RecommendCell.h"
#import "ReportForms2ViewController.h"

@interface RecommendedViewController ()<UITableViewDelegate,UITableViewDataSource>{
    UITableView *_tableView;
    RecommendNet *_model;
}

@end

@implementation RecommendedViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"代理";
    [self initData];
    [self initSubviews];
    [self initLayout];
}

#pragma mark ----- Data
- (void)initData{
    _model = [[RecommendNet alloc]init];
    if (_uid == nil) {
        _uid = APP_MODEL.user.userId;
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
    
//    self.navigationItem.title = @"我的玩家";
    CDWeakSelf(self);
    __weak RecommendNet *weakModel = _model;
    
    _tableView = [UITableView groupTable];
    [self.view addSubview:_tableView];
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = BaseColor;
    _tableView.backgroundView = view;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = 114;
    _tableView.separatorColor = TBSeparaColor;
    _tableView.separatorInset = UIEdgeInsetsMake(0, 70, 0, 0);

    _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        CDStrongSelf(self);
        [self getData:0];
    }];
    
    _tableView.StateView = [StateView StateViewWithHandle:^{
        
    }];
    
    _tableView.mj_footer = [MJRefreshAutoFooter footerWithRefreshingBlock:^{
        CDStrongSelf(self);
        if (!weakModel.isMost) {
            [self getData:weakModel.page];
        }
    }];
    SVP_SHOW;
    [self getData:0];
}

#pragma mark net
- (void)getData:(NSInteger)page{
    WEAK_OBJ(weakObj, self);
    [_model getPlayerWithPage:page success:^(NSDictionary *obj){
        SVP_DISMISS;
        [weakObj reload];
    } failure:^(NSError *error) {
        [FUNCTION_MANAGER handleFailResponse:error];
    }];
}

- (void)reload{
    [_tableView.mj_footer endRefreshing];
    [_tableView.mj_header endRefreshing];
    if(_model.IsNetError){
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

#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _model.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    RecommendCell *cell = (RecommendCell *)[tableView CDdequeueReusableCellWithIdentifier:_model.dataList[indexPath.row]];
    [cell.detailButton addTarget:self action:@selector(detailAction:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    RecommendedViewController *vc = [[RecommendedViewController alloc]init];
//    CDTableModel *model = _model.dataList[indexPath.row];
//    vc.uid = model.obj[@"id"];
//    vc.title = [NSString stringWithFormat:@"%@的玩家",model.obj[@"nickname"]];
//    [self.navigationController pushViewController:vc animated:YES];
//}

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

-(void)detailAction:(UIButton *)btn{
    UITableViewCell *cell = [FUNCTION_MANAGER cellForChildView:btn];
    NSIndexPath *path = [_tableView indexPathForCell:cell];
    CDTableModel *model = _model.dataList[path.row];
    NSDictionary *dic = model.obj;
    ReportForms2ViewController *vc = [[ReportForms2ViewController alloc] init];
    vc.userId = dic[@"userId"];
    vc.isAgent = [dic[@"agentFlag"] boolValue];
    [self.navigationController pushViewController:vc animated:YES];
}
@end
