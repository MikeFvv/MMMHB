//
//  RecommendedViewController.m
//  Project
//
//  Created by mini on 2018/8/1.
//  Copyright © 2018年 CDJay. All rights reserved.
//

#import "RecommendedViewController.h"
#import "RecommendNet.h"

@interface RecommendedViewController ()<UITableViewDelegate,UITableViewDataSource>{
    UITableView *_tableView;
    RecommendNet *_model;
}

@end

@implementation RecommendedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
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
    
    _tableView = [UITableView normalTable];
    [self.view addSubview:_tableView];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = 94;
    _tableView.separatorColor = TBSeparaColor;
    
    _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        CDStrongSelf(self);
        weakModel.page = 1;
        [self getData];
    }];
    
    _tableView.StateView = [StateView StateViewWithHandle:^{
        
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

#pragma mark net
- (void)getData{

    CDWeakSelf(self);
    [_model getPlayerObj:@{@"uid":_uid,@"page":@(_model.page)} Success:^(NSDictionary *dic) {
        CDStrongSelf(self);
        [self reload];
    } Failure:^(NSError *error) {
        SV_ERROR(error);
        [self reload];
    }];
}

- (void)reload{
    [_tableView.mj_footer endRefreshing];
    [_tableView.mj_header endRefreshing];
    if(_model.IsNetError){
        [_tableView.StateView showNetError];
    }
    else if(_model.IsEmpty){
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
    return [tableView CDdequeueReusableCellWithIdentifier:_model.dataList[indexPath.row]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    RecommendedViewController *vc = [[RecommendedViewController alloc]init];
    CDTableModel *model = _model.dataList[indexPath.row];
    vc.uid = model.obj[@"id"];
    vc.title = [NSString stringWithFormat:@"%@的玩家",model.obj[@"nickname"]];
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
