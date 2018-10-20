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
#import "NetRequestManager.h"
#import "WithdrawalModel.h"
@interface WithdrawalViewController ()<UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate,UITextFieldDelegate>{
    UITableView *_tableView;
    UITextField *_textField[6];
    NSArray *_rowList;
    UILabel *_typeLabel;
    //WithdrawalNet *_model;
    NSInteger _tempSelect;//记录选择哪个历史帐号
}
@property(nonatomic,strong)NSArray *bankList;
@property(nonatomic,strong)NSArray *recordList;

@end

@implementation WithdrawalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [NET_REQUEST_MANAGER requestBankListWithSuccess:nil fail:nil];
    [self initData];
    [self initSubviews];
    [self initLayout];
    
    WEAK_OBJ(weakSelf, self);
    self.bankList = [FUNCTION_MANAGER readArchiveWithFileName:@"bankList"];
    [NET_REQUEST_MANAGER requestBankListWithSuccess:^(id object) {
        weakSelf.bankList = [FUNCTION_MANAGER readArchiveWithFileName:@"bankList"];
    } fail:^(id object) {
        
    }];
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
    
    self.navigationItem.title = @"提现";
    
    CDWeakSelf(self);
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
        [self requestRecordList];
    }];
    [self requestRecordList];
}

- (void)requestRecordList{
    WEAK_OBJ(weakSelf, self);
    [NET_REQUEST_MANAGER requestDrawRecordListWithSuccess:^(id object) {
        NSArray *array = object[@"data"];
        weakSelf.recordList = array;
        [weakSelf reload];
    } fail:^(id object) {
        [weakSelf reload];
        [FUNCTION_MANAGER handleFailResponse:object];
    }];
//    [_model withdrawalListObj:@{@"uid":APP_MODEL.user.userId,@"page":@(_model.page)} Success:^(NSDictionary *dic) {
//        CDStrongSelf(self);
//        [self reload];
//    } Failure:^(NSError *error) {
//        CDStrongSelf(self);
//        [self reload];
//        SV_ERROR(error);
//    }];
}

- (void)reload{
    [_tableView.mj_footer endRefreshing];
    [_tableView.mj_header endRefreshing];
    [_tableView reloadData];
}

#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _rowList.count+self.recordList.count;
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
        view.backgroundColor = COLOR_Y(240);
        UILabel *label = [UILabel new];
        [view addSubview:label];
        label.text = @"历史提交账号列表";
        label.font = [UIFont scaleFont:12];
        label.textColor = COLOR_Y(130);
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
        label.font = [UIFont scaleFont:14];
        label.textColor = Color_6;
        label.text = [NSString stringWithFormat:@"余额：%@ 元", APP_MODEL.user.userBalance];
        
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
        tip.textColor = COLOR_Y(130);
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
        return 126;
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
        return 48;
    else if(section == 2)
        return 30;
    else
        return 0;
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
            NSInteger index = indexPath.section*1+indexPath.row;
            cell.textLabel.text = _rowList[indexPath.section][indexPath.row];
            cell.textLabel.font = [UIFont scaleFont:14];
            
            _textField[index] = [UITextField new];
            [cell.contentView addSubview:_textField[index]];
            _textField[index].font = [UIFont scaleFont:13];
            _textField[index].placeholder = (index == 0)?@"0.00":nil;
            _textField[index].textAlignment = NSTextAlignmentRight;
            if(index == 0 && indexPath.section == 0)
                _textField[index].keyboardType = UIKeyboardTypeDecimalPad;
            _textField[index].clearButtonMode = UITextFieldViewModeWhileEditing;
            if (index == 0) {
                UILabel *unit = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 30, 20)];
                unit.font = [UIFont scaleFont:14];
                unit.text = @"元";
                unit.textAlignment = NSTextAlignmentRight;
                unit.textColor = HexColor(@"#151515");
                _textField[index].rightView  = unit;
                _textField[index].rightViewMode = UITextFieldViewModeAlways;
            }
            
            if(index == 5)
                _textField[index].returnKeyType = UIReturnKeyDone;
            else
                _textField[index].returnKeyType = UIReturnKeyNext;
            if(index == 3)
                _textField[index].userInteractionEnabled = NO;
            _textField[index].delegate = self;
            [_textField[index] mas_makeConstraints:^(MASConstraintMaker *make) {
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
        NSDictionary *dict = self.recordList[indexPath.section - _rowList.count];
        cell.obj = dict;
        return cell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.view endEditing:YES];
    if(indexPath.section == 1 && indexPath.row == 2){
        UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:nil];
        NSArray *bankList = [FUNCTION_MANAGER readArchiveWithFileName:@"bankList"];
        if(bankList.count == 0)
            [NET_REQUEST_MANAGER requestBankListWithSuccess:nil fail:nil];
        for (NSDictionary *dic in bankList) {
            [sheet addButtonWithTitle:dic[@"upaytTitle"]];
        }
        sheet.tag = 1;
        [sheet showInView:self.view];
    }else if(indexPath.section == 2){
        _tempSelect = indexPath.row;
        WEAK_OBJ(weakSelf, self);
        UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"提示" message:@"是否使用此账号进行提现？" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancle = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [vc addAction:cancle];
        UIAlertAction *make = [UIAlertAction actionWithTitle:@"使用" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf backfillInfo];
        }];
        [vc addAction:make];
        [self presentViewController:vc animated:YES completion:nil];
    }
}

-(void)backfillInfo{
    if(_tempSelect < self.recordList.count){
        NSDictionary *dic = self.recordList[_tempSelect];
        WithdrawalModel *model = [WithdrawalModel mj_objectWithKeyValues:dic];
        _textField[1].text = model.upayNo;
        _textField[2].text = model.upayUser;
        _textField[3].text = model.upayBankname;
        _textField[4].text = model.upayRegion;
    }
}
#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(actionSheet.tag == 0){
        if (buttonIndex >0) {
            return;
        }
        NSArray *list = @[@"银行卡"];
        _typeLabel.text = list[buttonIndex];
    }else{
        if(buttonIndex != 0)
            _textField[3].text = [actionSheet buttonTitleAtIndex:buttonIndex];
    }
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
    WEAK_OBJ(weakSelf, self);
    [NET_REQUEST_MANAGER widthDrawWithAmount:_textField[0].text userName:_textField[2].text bankName:_textField[3].text address:_textField[4].text uppayNO:_textField[1].text remark:_textField[5].text success:^(id object) {
        SV_SUCCESS_STATUS(object[@"data"]);
        CDPop(weakSelf.navigationController, YES);
    } fail:^(id object) {
        [FUNCTION_MANAGER handleFailResponse:object];
    }];
//    [WithdrawalNet WithdrawalObj:dic Success:^(NSDictionary *info) {
//        CDPop(self.navigationController, YES);
//    } Failure:^(NSError *error) {
//        SV_ERROR(error);
//    }];
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    for (NSInteger i = 0; i < 5; i ++) {
        if(textField == _textField[i]){
            if(i == 2)
                i += 1;
            [_textField[i + 1] becomeFirstResponder];
            return YES;
        }
    }
    [textField resignFirstResponder];
    return YES;
}
@end
