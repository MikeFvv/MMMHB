//
//  WithdrawalViewController.m
//  Project
//
//  Created by mini on 2018/8/1.
//  Copyright © 2018年 CDJay. All rights reserved.
//

#import "WithdrawalViewController.h"
#import "WithHisListTableViewCell.h"

@interface WithdrawalViewController ()<UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate,ActionSheetDelegate>{
    UITextField *_textField[6];
    NSArray *_rowList;
    UILabel *_typeLabel;
}
@property(nonatomic,strong)NSArray *bankList;
@property(nonatomic,strong)NSArray *historyList;
@property(nonatomic,strong)UITableView *tableView;
@property(nonatomic,strong)NSString *bankId;
@property(nonatomic,strong)UIButton *submitBtn;

@end

@implementation WithdrawalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    self.bankList = [ud objectForKey:@"bankList"];
    
    [self requestBankList];
    [self initData];
    [self initSubviews];
    [self initLayout];
}

#pragma mark ----- Data
- (void)initData{
    _rowList = @[@[@"金额"],@[@"卡号",@"持卡人",@"开户行",@"开户地址",@"备注"]];
}

#pragma mark ----- Layout
- (void)initLayout{
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

#pragma mark ----- subView
- (void)initSubviews{
    self.navigationItem.title = @"提现中心";
    self.view.backgroundColor = BaseColor;
    WEAK_OBJ(weakSelf, self);
    
    _tableView = [UITableView normalTable];
    [self.view addSubview:_tableView];
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = BaseColor;
    _tableView.backgroundView = view;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.rowHeight = 50;
    _tableView.tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CDScreenWidth, 1)];
    _tableView.tableFooterView = [self footView];
    _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    _tableView.separatorColor = TBSeparaColor;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf getData];
    }];
    
    [self getData];
}

-(void)requestBankList{
    WEAK_OBJ(weakObj, self);
    [NET_REQUEST_MANAGER requestBankListWithSuccess:^(id object) {
        NSArray *arr = [object objectForKey:@"data"];
        weakObj.bankList = arr;
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        [ud setObject:arr forKey:@"bankList"];
        [ud synchronize];
    } fail:^(id object) {
    }];
}

- (void)getData{
    WEAK_OBJ(weakObj, self);
    [NET_REQUEST_MANAGER requestDrawRecordListWithSuccess:^(id object) {
        SVP_DISMISS;
        weakObj.historyList = object[@"data"];
        [weakObj reload];
    } fail:^(id object) {
        [weakObj reload];
        //[FUNCTION_MANAGER handleFailResponse:object];
    }];
}

- (void)reload{
    [_tableView.mj_header endRefreshing];
    [_tableView reloadData];
}

#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _rowList.count+self.historyList.count;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIButton *view = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, CDScreenWidth, 48)];
    view.backgroundColor = BaseColor;
    if (section == 1) {
        //[view addTarget:self action:@selector(action_type) forControlEvents:UIControlEventTouchUpInside];
        UILabel *label = [UILabel new];
        [view addSubview:label];
        label.font = [UIFont systemFontOfSize2:13];
        label.textColor = Color_6;
        label.text = @"提现类型";
        
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(view.mas_left).offset(15);
            make.centerY.equalTo(view);
        }];
        
        _typeLabel = [UILabel new];
        [view addSubview:_typeLabel];
        _typeLabel.font = [UIFont systemFontOfSize2:13];
        _typeLabel.textColor = Color_6;
        _typeLabel.text = @"银行卡";
        
        [_typeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(view.mas_right).offset(-27);
            make.centerY.equalTo(view);
        }];
    }
    if (section == 2) {
        UILabel *label = [UILabel new];
        [view addSubview:label];
        label.text = @"历史提交账号列表";
        label.font = [UIFont systemFontOfSize2:13];
        label.textColor = COLOR_X(150, 150, 150);
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
        view.backgroundColor = [UIColor whiteColor];
        view.frame = CGRectMake(0, 0, CDScreenWidth, 48);
        UILabel *label = [UILabel new];
        [view addSubview:label];
        label.font = [UIFont systemFontOfSize2:12];
        label.textColor = Color_6;
        label.text = [NSString stringWithFormat:@"余额：%@元",APP_MODEL.user.balance];
        
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(view.mas_left).offset(16);
            make.centerY.equalTo(view).offset(0);
        }];
    }
    else if (section == 1){
    }
    return view;
}

-(UIView *)footView{
    UIView *view = [UIView new];
    view.frame = CGRectMake(0, 0, CDScreenWidth, 100);
    view.backgroundColor = [UIColor whiteColor];
    UIButton *btn = [UIButton new];
    [view addSubview:btn];
    btn.titleLabel.font = [UIFont boldSystemFontOfSize2:17];
    [btn setTitle:@"申请提现" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(action_submit) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.layer.cornerRadius = 8.0f;
    btn.layer.masksToBounds = YES;
    btn.backgroundColor = MBTNColor;
    [btn delayEnable];
    self.submitBtn = btn;
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(16));
        make.right.equalTo(view.mas_right).offset(-16);
        make.height.equalTo(@(44));
        make.top.equalTo(view.mas_top).offset(10);
    }];
    
    UILabel *tip = [UILabel new];
    [view addSubview:tip];
    tip.textColor = Color_6;
    tip.text = @"申请后，请耐心等待审核";
    tip.font = [UIFont systemFontOfSize2:12];
    
    [tip mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(view);
        make.top.equalTo(btn.mas_bottom).offset(13);
    }];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section<_rowList.count) {
        return 50;
    }
    else
        return 100;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section <_rowList.count) {
        NSArray *list = _rowList[section];
        return list.count;
    }else
        return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(section == 1)
        return 36;
    else if(section == 2)
        return 36;
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 0) {
        return 30;
    }
    if (section == 1) {
        return 0;
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
            cell.textLabel.font = [UIFont systemFontOfSize2:16];
            cell.textLabel.textColor = Color_0;
            _textField[row] = [UITextField new];
            [cell.contentView addSubview:_textField[row]];
            _textField[row].font = [UIFont systemFontOfSize2:16];
            _textField[row].placeholder = (row == 0)?@"0":nil;
            _textField[row].textAlignment = NSTextAlignmentRight;
            _textField[row].delegate = self;
            if (row == 0) {
                UILabel *unit = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 30, 20)];
                unit.font = [UIFont systemFontOfSize2:16];
                unit.text = @"元";
                unit.textAlignment = NSTextAlignmentRight;
                unit.textColor = HexColor(@"#151515");
                _textField[row].rightView  = unit;
                _textField[row].rightViewMode = UITextFieldViewModeAlways;
                _textField[row].keyboardType = UIKeyboardTypeNumberPad;
            }else if(row == 3){
                _textField[row].userInteractionEnabled = NO;
            }
            
            [_textField[row] mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(@(120));
                make.right.equalTo(cell.contentView).offset(-15);
                make.top.bottom.equalTo(cell.contentView);
            }];
            if(row == 5){
                _textField[row].returnKeyType = UIReturnKeyDone;
            }else
                _textField[row].returnKeyType = UIReturnKeyNext;
            
            UIView *lineView = [[UIView alloc] init];
            lineView.backgroundColor = TBSeparaColor;
            [cell.contentView addSubview:lineView];
            [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.bottom.equalTo(cell.contentView);
                make.left.equalTo(cell.contentView).offset(17);
                make.height.equalTo(@0.5);
            }];
        }
        return cell;
    }
    else{
        WithHisListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WithHis"];
        if (cell == nil) {
            cell = [[WithHisListTableViewCell alloc]initWithStyle:0 reuseIdentifier:@"WithHis"];
            cell.backgroundColor = [UIColor clearColor];
        }
        NSDictionary *dict = self.historyList[indexPath.section - _rowList.count];
        cell.obj = dict;
        return cell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if(indexPath.section <_rowList.count){
        NSInteger row = indexPath.section*1+indexPath.row;
        if(row == 3){
            [self selectBank];
        }
    }else{
        NSInteger index = indexPath.section - _rowList.count;
        NSDictionary *dic = self.historyList[index];
        _textField[1].text = dic[@"upayNo"];
        _textField[2].text = dic[@"user"];
        _textField[3].text = dic[@"bankName"];
        _textField[4].text = dic[@"bankRegion"];
        NSInteger bankId = [dic[@"bankId"] integerValue];
        self.bankId = INT_TO_STR(bankId);
    }
}

#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        return;
    }else{
        NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
        _textField[3].text = title;
    }
}

#pragma mark action
- (void)selectBank{
    NSMutableArray *arr = [NSMutableArray array];
    for (NSDictionary *dic in self.bankList) {
        NSString *bankName = dic[@"title"];
        [arr addObject:bankName];
    }
    ActionSheetCus *sheet = [[ActionSheetCus alloc] initWithArray:arr];
    sheet.titleLabel.text = @"请选择银行";
    sheet.delegate = self;
    [sheet showWithAnimationWithAni:YES];
}

- (void)action_submit{
    if (_textField[0].text.length == 0) {
        SVP_ERROR_STATUS(@"请输入金额");
        return;
    }
    if (![FUNCTION_MANAGER checkIsNum:_textField[0].text]) {
        SVP_ERROR_STATUS(@"请输入正确的金额");
        return;
    }
    if([_textField[0].text doubleValue] > [APP_MODEL.user.balance doubleValue]){
        SVP_ERROR_STATUS(@"余额不足");
        return;
    }
    if (_textField[1].text.length == 0) {
        SVP_ERROR_STATUS(@"请输入卡号");
        return;
    }
    if (_textField[2].text.length == 0) {
        SVP_ERROR_STATUS(@"请输入持卡人姓名");
        return;
    }
    if (_textField[3].text.length == 0) {
        SVP_ERROR_STATUS(@"请输入开户行");
        return;
    }
    if (_textField[4].text.length == 0) {
        SVP_ERROR_STATUS(@"请输入开户行地址");
        return;
    }
    //    if (_textField[5].text.length == 0) {
    //        SVP_ERROR_STATUS(@"请输入开户行地址");
    //        return;
    //    }
    SVP_SHOW;
    WEAK_OBJ(weakSelf, self);
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithDictionary:@{@"money":_textField[0].text,@"uid":APP_MODEL.user.userId,@"accType":@"3",@"accNo":_textField[1].text,@"accUser":_textField[2].text,@"accTargetName":_textField[3].text,@"accAreaName":_textField[4].text}];
    if (_textField[5].text.length != 0) {
        [dic setObject:_textField[5].text forKey:@"cashRemarks"];
    }
    SVP_SHOW;
    self.submitBtn.userInteractionEnabled = NO;
    [NET_REQUEST_MANAGER withDrawWithAmount:_textField[0].text userName:_textField[2].text bankName:_textField[3].text bankId:self.bankId address:_textField[4].text uppayNO:_textField[1].text remark:_textField[5].text success:^(id object) {
        SVP_SUCCESS_STATUS(@"申请成功");
        [NET_REQUEST_MANAGER requestUserInfoWithSuccess:nil fail:nil];
        [weakSelf.navigationController popViewControllerAnimated:YES];
    } fail:^(id object) {
        weakSelf.submitBtn.userInteractionEnabled = YES;
        [FUNCTION_MANAGER handleFailResponse:object];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if(textField == _textField[0])
        [_textField[1] becomeFirstResponder];
    else if(textField == _textField[1])
        [_textField[2] becomeFirstResponder];
    else if(textField == _textField[2])
        [_textField[4] becomeFirstResponder];
    else if(textField == _textField[4])
        [_textField[5] becomeFirstResponder];
    else
        [textField resignFirstResponder];
    return YES;
}

-(void)actionSheetDelegateWithActionSheet:(ActionSheetCus *)actionSheet index:(NSInteger)index{
    if(index == self.bankList.count)
        return;
    NSDictionary *dic = self.bankList[index];
    NSString *bankName = dic[@"title"];
    NSInteger bankId = [dic[@"id"] integerValue];
    self.bankId = INT_TO_STR(bankId);
    _textField[3].text = bankName;
}
@end
