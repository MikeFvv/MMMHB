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

@interface EnvelopeListViewController ()<UITableViewDataSource,UITableViewDelegate>{
    UITableView *_tableView;
    EnvelopBackImg *_redView;
    UIImageView *_icon;
    UILabel *_nameLabel;
    UILabel *_contentLabel;
    UILabel *_moneyLabel;
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
    __weak EnvelopeNet *weakModel = _model;
    _tableView = [UITableView normalTable];
    [self.view addSubview:_tableView];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorColor = TBSeparaColor;
    _tableView.rowHeight = 71;
    CGFloat h = CD_Scal(68, 667)/0.665;
    
    UIView *headView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CDScreenWidth, CD_Scal(208, 667))];
    _redView = [[EnvelopBackImg alloc]initWithFrame:CGRectMake(0, 0, CDScreenWidth, h) r:400 x:0 y:-(400-h)];
    [headView addSubview:_redView];
    _redView.backgroundColor = [UIColor whiteColor];
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
    _moneyLabel.font = [UIFont scaleFont:46];
    
    [_moneyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self ->_contentLabel.mas_bottom).offset(10);
        make.centerX.equalTo(headView);
    }];
    
    _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        weakModel.page = 1;
        [weakSelf getData];
    }];
    
    _tableView.mj_footer = [MJRefreshAutoFooter footerWithRefreshingBlock:^{
        if (!weakModel.IsMost) {
            weakModel.page ++;
            [weakSelf getData];
        }
    }];
    
    _tableView.StateView = [StateView StateViewWithHandle:^{

    }];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self->_tableView.mj_header beginRefreshing];
    });
}

- (void)getData{
    
    __weak typeof(self) weakSelf = self;
    [_model getListObj:@{@"page":@(_model.page),@"redpacketId":self.CDParam,@"uid":APP_MODEL.user.userId} Success:^(NSDictionary *dic) {
        [weakSelf reLoad];
    } Failure:^(NSError *error) {
        [weakSelf reLoad];
        SV_ERROR(error);
    }];
}

- (void)reLoad{
    [_tableView.mj_header endRefreshing];
    [_tableView.mj_footer endRefreshing];
    [_tableView reloadData];
    if (_model.IsNetError) {
        [_tableView.StateView showNetError];
    }
    else if (_model.IsEmpty){
        [_tableView.StateView showEmpty];
    }else{
        [_tableView.StateView hidState];
    }

    
    if (_model.page == 1) {
        if (![_model.user isKindOfClass:[NSNull class]]) {
            NSString *string = _model.user[@"grap_money"];
            if ([string isKindOfClass:[NSNull class]]) {
                return;
            }
            _moneyLabel.text =[NSString stringWithFormat:@"%@元",string];
            NSMutableAttributedString *AttributedStr = [[NSMutableAttributedString alloc]initWithString:_moneyLabel.text];
            NSRange r = [_moneyLabel.text rangeOfString:@"元"];
            [AttributedStr addAttribute:NSFontAttributeName value:[UIFont scaleFont:15] range:r];
            _moneyLabel.attributedText = AttributedStr;
        }
    }
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

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
