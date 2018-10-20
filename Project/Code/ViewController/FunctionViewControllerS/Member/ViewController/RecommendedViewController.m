//
//  RecommendedViewController.m
//  Project
//
//  Created by mini on 2018/8/1.
//  Copyright © 2018年 CDJay. All rights reserved.
//

#import "RecommendedViewController.h"
#import "RecommendNet.h"
#import "NetRequestManager.h"

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
    _model.page = 1;
    SV_SHOW;
    [self getData];
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
    _tableView.rowHeight = 66;//94;
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
        if (!weakModel.isMost) {
            weakModel.page ++;
            [self getData];
        }
    }];
}

//-(void)viewDidAppear:(BOOL)animated{
//    [super viewDidAppear:animated];
//    [self->_tableView.mj_header beginRefreshing];
//}
#pragma mark net
- (void)getData{
    WEAK_OBJ(weakSelf, self);
    [_model getMyPlayerWithSuccess:^(NSDictionary *dict) {
        SV_DISMISS;
        [weakSelf reload];
    } Failure:^(id object) {
        [FUNCTION_MANAGER handleFailResponse:object];
        [weakSelf reload];
    }];
}

- (void)reload{
    [_tableView.mj_footer endRefreshing];
    [_tableView.mj_header endRefreshing];
    if(_model.isNetError){
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
    return [tableView CDdequeueReusableCellWithIdentifier:_model.dataList[indexPath.row]];
}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    RecommendedViewController *vc = [[RecommendedViewController alloc]init];
//    CDTableModel *model = _model.dataList[indexPath.row];
//    vc.uid = model.obj[@"id"];
//    vc.title = [NSString stringWithFormat:@"%@的玩家",model.obj[@"userNick"]];
//    [self.navigationController pushViewController:vc animated:YES];
//}

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
