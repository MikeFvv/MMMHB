//
//  WithdrawalViewController.m
//  Project
//
//  Created by mini on 2018/8/1.
//  Copyright © 2018年 CDJay. All rights reserved.
//

#import "WithdrawalViewController.h"
#import "WithdrawalNet.h"
#import "WithHisListTableViewCell.h"

@interface WithdrawalViewController ()<UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate>{
    UITableView *_tableView;
    UITextField *_textField[6];
    NSArray *_rowList;
    UILabel *_typeLabel;
    WithdrawalNet *_model;
}

@end

@implementation WithdrawalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self initSubviews];
    [self initLayout];
}

#pragma mark ----- Data
- (void)initData{
    _rowList = @[@[@"金额"],@[@"卡号",@"持卡人",@"开户行",@"开户地址",@"备注"]];
    _model = [WithdrawalNet new];
}


#pragma mark ----- Layout
- (void)initLayout{
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

#pragma mark ----- subView
- (void)initSubviews{
    
    self.navigationItem.title = @"提现";
    
    CDWeakSelf(self);
    __weak WithdrawalNet *weakModel = _model;
    
    _tableView = [UITableView groupTable];
    [self.view addSubview:_tableView];
    _tableView.backgroundColor = BaseColor;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.rowHeight = 48;
    _tableView.tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CDScreenWidth, 1)];
    _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
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

- (void)getData{
    CDWeakSelf(self);
    [_model WithdrawalListObj:@{@"uid":APP_MODEL.user.userId,@"page":@(_model.page)} Success:^(NSDictionary *dic) {
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
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _rowList.count+_model.dataList.count;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIButton *view = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, CDScreenWidth, 48)];
    if (section == 1) {
        [view addTarget:self action:@selector(action_type) forControlEvents:UIControlEventTouchUpInside];
        UILabel *label = [UILabel new];
        [view addSubview:label];
        label.font = [UIFont scaleFont:14];
        label.textColor = Color_3;
        label.text = @"提现类型";
        
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(view.mas_left).offset(15);
            make.centerY.equalTo(view);
        }];
        
        _typeLabel = [UILabel new];
        [view addSubview:_typeLabel];
        _typeLabel.font = [UIFont scaleFont:12];
        _typeLabel.textColor = Color_3;
        _typeLabel.text = @"银行卡";
        
        [_typeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(view.mas_right).offset(-27);
            make.centerY.equalTo(view);
        }];
    }
    if (section == 2) {
        view.backgroundColor = HexColor(@"#D8D8D8");
        UILabel *label = [UILabel new];
        [view addSubview:label];
        label.text = @"历史提交账号列表";
        label.font = [UIFont scaleFont:12];
        label.textColor = Color_6;
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(view.mas_left).offset(15);
            make.centerY.equalTo(view);
        }];
    }
    
    return view;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [UIView new];//[[UIView alloc]initWithFrame:CGRectMake(0, 0, CDScreenWidth, 48)];
    if (section == 0) {
        view.frame = CGRectMake(0, 0, CDScreenWidth, 48);
        UILabel *label = [UILabel new];
        [view addSubview:label];
        label.font = [UIFont scaleFont:12];
        label.textColor = Color_6;
        label.text = APP_MODEL.user.userBalance;
        
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(view.mas_left).offset(15);
            make.centerY.equalTo(view);
        }];
    }
    else if (section == 1){
        view.frame = CGRectMake(0, 0, CDScreenWidth, 100);
        
        UIButton *btn = [UIButton new];
        [view addSubview:btn];
        btn.titleLabel.font = [UIFont scaleFont:15];
        [btn setTitle:@"申请提现" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(action_submit) forControlEvents:UIControlEventTouchUpInside];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn.layer.cornerRadius = 8.0f;
        btn.layer.masksToBounds = YES;
        btn.backgroundColor = MBTNColor;
        
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(16));
            make.right.equalTo(view.mas_right).offset(-16);
            make.height.equalTo(@(42));
            make.top.equalTo(view.mas_top).offset(10);
        }];
        
        UILabel *tip = [UILabel new];
        [view addSubview:tip];
        tip.textColor = Color_6;
        tip.text = @"申请后，请耐心等待审核";
        tip.font = [UIFont scaleFont:12];
        
        [tip mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(view);
            make.top.equalTo(btn.mas_bottom).offset(9);
        }];
    }
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section<_rowList.count) {
        return 48;
    }
    else
        return 116;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section <_rowList.count) {
        NSArray *list = _rowList[section];
        return list.count;
    }else
        return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return (section == 1||section == 2)?48:0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 0) {
        return 48;
    }
    if (section == 1) {
        return 100;
    }
    else
        return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    if (indexPath.section <_rowList.count) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc]initWithStyle:0 reuseIdentifier:@"cell"];
            NSInteger row = indexPath.section*1+indexPath.row;
            cell.textLabel.text = _rowList[indexPath.section][indexPath.row];
            cell.textLabel.font = [UIFont scaleFont:14];
            
            _textField[row] = [UITextField new];
            [cell.contentView addSubview:_textField[row]];
            _textField[row].font = [UIFont scaleFont:13];
            _textField[row].placeholder = (row == 0)?@"0.00":nil;
            _textField[row].textAlignment = NSTextAlignmentRight;
            if (row == 0) {
                UILabel *unit = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 30, 20)];
                unit.font = [UIFont scaleFont:14];
                unit.text = @"元";
                unit.textAlignment = NSTextAlignmentRight;
                unit.textColor = HexColor(@"#151515");
                _textField[row].rightView  = unit;
                _textField[row].rightViewMode = UITextFieldViewModeAlways;
            }
            
            [_textField[row] mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(@(120));
                make.right.equalTo(cell.contentView).offset(-15);
                make.top.bottom.equalTo(cell.contentView);
            }];
        }
        return cell;
    }
    else{
        WithHisListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WithHis"];
        if (cell == nil) {
            cell = [[WithHisListTableViewCell alloc]initWithStyle:0 reuseIdentifier:@"WithHis"];
        }
        CDTableModel *model = _model.dataList[indexPath.section - _rowList.count];
        cell.obj = model.obj;
        return cell;
    }
    return nil;
}

#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex >0) {
        return;
    }
    NSArray *list = @[@"银行卡"];
    _typeLabel.text = list[buttonIndex];
}

#pragma mark action
- (void)action_type{
    UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"银行卡", nil];
    [sheet showInView:self.view];
}

- (void)action_submit{
    if (_textField[0].text.length == 0) {
        SV_ERROR_STATUS(@"请输入金额");
        return;
    }
    if (_textField[1].text.length == 0) {
        SV_ERROR_STATUS(@"请输入卡号！");
        return;
    }
    if (_textField[2].text.length == 0) {
        SV_ERROR_STATUS(@"请输入持卡人姓名！");
        return;
    }
    if (_textField[3].text.length == 0) {
        SV_ERROR_STATUS(@"请输入开户行！");
        return;
    }
    if (_textField[4].text.length == 0) {
        SV_ERROR_STATUS(@"请输入开户行地址");
        return;
    }
    //    if (_textField[5].text.length == 0) {
    //        SV_ERROR_STATUS(@"请输入开户行地址");
    //        return;
    //    }
    SV_SHOW;
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithDictionary:@{@"money":_textField[0].text,@"uid":APP_MODEL.user.userId,@"accType":@"3",@"accNo":_textField[1].text,@"accUser":_textField[2].text,@"accTargetName":_textField[3].text,@"accAreaName":_textField[4].text}];
    if (_textField[5].text.length != 0) {
        [dic setObject:_textField[5].text forKey:@"cashRemarks"];
    }
    
    [WithdrawalNet WithdrawalObj:dic Success:^(NSDictionary *info) {
        CDPop(self.navigationController, YES);
    } Failure:^(NSError *error) {
        SV_ERROR(error);
    }];
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
