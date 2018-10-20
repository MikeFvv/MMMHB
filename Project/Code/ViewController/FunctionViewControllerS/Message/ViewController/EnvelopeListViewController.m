//
//  EnvelopeListViewController.m
//  Project
//
//  Created by mini on 2018/8/13.
//  Copyright © 2018年 CDJay. All rights reserved.
//

#import "EnvelopeListViewController.h"
#import "EnvelopBackImg.h"
#import "EnvelopeNet.h"

#import "NetRequestManager.h"

@interface EnvelopeListViewController ()<UITableViewDataSource,UITableViewDelegate>{
    UITableView *_tableView;
    EnvelopBackImg *_redView;
    UIImageView *_icon;
    UILabel *_nameLabel;
    UILabel *_contentLabel;
    UILabel *_moneyLabel;
    UILabel *_yuanLabel;
    EnvelopeNet *_model;
}

@end

@implementation EnvelopeListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self initSubviews];
    [self initLayout];
}

#pragma mark ----- Data
- (void)initData{
    _model = [EnvelopeNet shareInstance];
    [_model.dataList removeAllObjects];
}

#pragma mark ----- Layout
- (void)initLayout{
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

#pragma mark ----- subView
- (void)initSubviews{
    self.navigationItem.title = @"红包详情";
    self.view.backgroundColor = BaseColor;
    __weak typeof(self) weakSelf = self;
    _tableView = [UITableView normalTable];
    [self.view addSubview:_tableView];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorColor = TBSeparaColor;
    _tableView.rowHeight = 71;
    CGFloat h = CD_Scal(68, 667)/0.665;
    
    UIView *headView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CDScreenWidth, 250)];
    headView.backgroundColor = COLOR_Y(250);
    _redView = [[EnvelopBackImg alloc]initWithFrame:CGRectMake(0, 0, CDScreenWidth, h) r:400 x:0 y:-(400-h)];
    _redView.backgroundColor = [UIColor clearColor];
    [headView addSubview:_redView];
    _tableView.tableHeaderView = headView;
    _icon = [UIImageView new];
    [headView addSubview:_icon];
    _icon.layer.cornerRadius = 28;
    _icon.layer.masksToBounds = YES;

    
    [_icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(headView);
        make.centerY.equalTo(self ->_redView.mas_bottom);
        make.height.width.equalTo(@(56));
    }];
    
    [_icon cd_setImageWithURL:[NSURL URLWithString:[NSString cdImageLink:APP_MODEL.user.userAvatar]] placeholderImage:[UIImage imageNamed:@"user-default"]];
    
    _nameLabel = [UILabel new];
    [headView addSubview:_nameLabel];
    _nameLabel.text = APP_MODEL.user.userNick;

    
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(headView);
        make.top.equalTo(self ->_icon.mas_bottom).offset(8);
    }];
    
    _contentLabel = [UILabel new];
    [headView addSubview:_contentLabel];
    _contentLabel.font = [UIFont scaleFont:15];
    _contentLabel.textColor = Color_3;
    [_contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self ->_nameLabel.mas_bottom).offset(4);
        make.centerX.equalTo(headView);
    }];
    
    _moneyLabel = [UILabel new];
    [headView addSubview:_moneyLabel];
    _moneyLabel.textColor = Color_3;
    _moneyLabel.font = [UIFont scaleFont:48];
    
    [_moneyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self ->_contentLabel.mas_bottom).offset(3);
        make.centerX.equalTo(headView);
    }];
    
    // 元
    _yuanLabel = [UILabel new];
    _yuanLabel.text = @"元";
    [headView addSubview:_yuanLabel];
    _yuanLabel.textColor = Color_3;
    _yuanLabel.font = [UIFont scaleFont:14];
    
    [_yuanLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self ->_moneyLabel.mas_bottom).offset(-10);
        make.left.equalTo(self -> _moneyLabel.mas_right).offset(8);
    }];
    
    _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf getData];
    }];
    
    _tableView.StateView = [StateView StateViewWithHandle:^{
        
    }];
    [self getData];
}

-(void)refreshUserInfo{
    CDTableModel *modelCur = [[CDTableModel alloc] init];
    for (int i = 0; i < _model.dataList.count; i++){
        CDTableModel *model = _model.dataList[i];
        NSString *userIdStr = [NSString stringWithFormat:@"%@", model.obj[@"userId"]];
        if ([userIdStr isEqualToString:APP_MODEL.user.userId]) {
            modelCur = model;
            break;
        }
    }
    
    _moneyLabel.text = [NSString stringWithFormat:@"%@",modelCur.obj[@"redbgMoney"]];
    [_icon cd_setImageWithURL:[NSURL URLWithString:[NSString cdImageLink:modelCur.obj[@"userAvatar"]]] placeholderImage:[UIImage imageNamed:@"user-default"]];
    _nameLabel.text = modelCur.obj[@"userNick"];
}

//-(void)viewDidAppear:(BOOL)animated{
//    [super viewDidAppear:animated];
//    [_tableView.mj_header beginRefreshing];
//}

// 获取红包信息
- (void)getData{
    __weak typeof(self) weakSelf = self;
    [_model getListWithPacketId:self.CDParam success:^(NSDictionary *dic) {
        [weakSelf reLoad];
    } failure:^(NSError *error) {
        [weakSelf reLoad];
        [FUNCTION_MANAGER handleFailResponse:error];
    }];
}

- (void)reLoad{
    [self refreshUserInfo];
    [_tableView.mj_header endRefreshing];
    [_tableView.mj_footer endRefreshing];
    [_tableView reloadData];
    if (_model.isNetError) {
        [_tableView.StateView showNetError];
    }
    else if (_model.isEmpty){
        [_tableView.StateView showEmpty];
    }else{
        [_tableView.StateView hidState];
    }
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    
    CGFloat curMoneyTotal;
    for (int i = 0; i < _model.dataList.count; i++){
        CDTableModel *model = _model.dataList[i];
        CGFloat money = [model.obj[@"redbgMoney"] floatValue];
        curMoneyTotal += money;
    }
    
    
    //    NSString *s = [NSString stringWithFormat:@"已领取%ld/%ld个",_model.dataList.count,[_model.user[@"redbTotal"] integerValue]];
    NSString *s = [NSString stringWithFormat:@"已领取%ld/%ld个，共%.2f/%@元",_model.dataList.count,[_model.user[@"redbTotal"] integerValue],curMoneyTotal, _model.user[@"redbMoney"]];
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CDScreenWidth, 35)];
    UILabel *label = [UILabel new];
    [view addSubview:label];
    label.font = [UIFont scaleFont:13];
    label.textColor = Color_9;
    label.text = s;
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view.mas_left).offset(15);
        make.top.bottom.equalTo(view).offset(10);
    }];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 35;
}

#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _model.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [tableView CDdequeueReusableCellWithIdentifier:_model.dataList[indexPath.row]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
