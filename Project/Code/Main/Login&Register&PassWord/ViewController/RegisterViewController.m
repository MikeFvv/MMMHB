//
//  RegisterViewController.m
//  Project
//
//  Created by mini on 2018/7/31.
//  Copyright © 2018年 CDJay. All rights reserved.
//

#import "RegisterViewController.h"
#import "WebViewController.h"

@interface RegisterViewController ()<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,UITextFieldDelegate>{
    UITableView *_tableView;
    NSArray *_dataList;
    UITextField *_textField[5];
    UILabel *_sexLabel;
    NSInteger _sexType;
}
@property(nonatomic,strong)UIButton *codeBtn;
@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self initSubviews];
    [self initLayout];
}

#pragma mark ----- Data
- (void)initData{
    _dataList = @[@[@{@"title":@"请输入手机号",@"img":@"icon_phone"},@{@"title":@"请输入验证码",@"img":@"icon_security"},@{@"title":@"请输入密码",@"img":@"icon_lock"},@{@"title":@"请确认密码",@"img":@"icon_lock"}],@[@{@"title":@"邀请码",@"img":@"icon_recommend"}]];
    _sexType = 1;
}


#pragma mark ----- Layout
- (void)initLayout{
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

#pragma mark ----- subView
- (void)initSubviews{
    
    self.navigationItem.title = @"注册";
    
    _tableView = [UITableView groupTable];
    [self.view addSubview:_tableView];
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = BaseColor;
    _tableView.backgroundView = view;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = 52;
    _tableView.sectionFooterHeight = 8.0f;
    _tableView.tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 1)];
    _tableView.backgroundColor = BaseColor;
    _tableView.separatorColor = TBSeparaColor;
    
    UIView *fotView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 200)];
    _tableView.tableFooterView = fotView;
    
    
    UIButton *btn = [UIButton new];
    [fotView addSubview:btn];
    btn.titleLabel.font = [UIFont boldSystemFontOfSize2:17];
    [btn setTitle:@"注册" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(action_submit) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.layer.cornerRadius = 8.0f;
    btn.layer.masksToBounds = YES;
    btn.backgroundColor = MBTNColor;
    [btn delayEnable];
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(16));
        make.right.equalTo(self.view.mas_right).offset(-16);
        make.height.equalTo(@(44));
        make.top.equalTo(fotView.mas_top).offset(38);
    }];
    
    UIView *thirdView = [UIView new];
    [fotView addSubview:thirdView];
    //    BOOL b = [WXManage isWXAppInstalled];
    //
    //    thirdView.hidden = [WXManage isWXAppInstalled];///<yes安装
    
    [thirdView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(fotView);
        make.top.equalTo(btn.mas_bottom).offset(50);
    }];
    
    UILabel *thirdLabel = [UILabel new];
    [thirdView addSubview:thirdLabel];
    thirdLabel.font = [UIFont systemFontOfSize2:14];
    thirdLabel.text = @"没有邀请码请联系客服";
    thirdLabel.textColor = Color_9;
    
    [thirdLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.top.equalTo(thirdView);
    }];
    
    UIView *lineleft = [UIView new];
    [thirdView addSubview:lineleft];
    lineleft.backgroundColor = COLOR_X(210, 210, 210);
    
    [lineleft mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(thirdView.mas_left).offset(15);
        make.right.greaterThanOrEqualTo(thirdLabel.mas_left).offset(-15);
        make.centerY.equalTo(thirdLabel.mas_centerY);
        make.height.equalTo(@(1.0));
    }];
    
    UIView *lineright = [UIView new];
    [thirdView addSubview:lineright];
    lineright.backgroundColor = COLOR_X(210, 210, 210);
    [lineright mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.lessThanOrEqualTo(thirdLabel.mas_right).offset(15);
        make.right.equalTo(thirdView.mas_right).offset(-15);
        make.height.equalTo(@(1.0));
        make.centerY.equalTo(thirdLabel.mas_centerY);
    }];
    
    UIButton *wx = [UIButton new];
    [thirdView addSubview:wx];
    [wx setBackgroundImage:[UIImage imageNamed:@"serverIcon"] forState:UIControlStateNormal];
    [wx addTarget:self action:@selector(feedback) forControlEvents:UIControlEventTouchUpInside];
    
    [wx mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(thirdView);
        make.top.equalTo(thirdLabel.mas_bottom).offset(20);
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.1f;
}

-(void)viewDidAppear:(BOOL)animated{
    if(_textField[0].text.length == 0)
        [_textField[0] becomeFirstResponder];
}

#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _dataList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *list = _dataList[section];
    return list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
    
        cell = [[UITableViewCell alloc]initWithStyle:0 reuseIdentifier:@"cell"];
        NSArray *list = _dataList[indexPath.section];
        if (indexPath.section == 0) {
            
            if (indexPath.row == 0) {
                _codeBtn = [UIButton new];
                [cell.contentView addSubview:_codeBtn];
                [_codeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
                [_codeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                _codeBtn.titleLabel.font = [UIFont systemFontOfSize:13];
                _codeBtn.layer.cornerRadius = 6;
                _codeBtn.layer.masksToBounds = YES;
                _codeBtn.backgroundColor = COLOR_X(244, 112, 35);//[UIColor colorWithHexString:@""];
                [_codeBtn addTarget:self action:@selector(action_getCode) forControlEvents:UIControlEventTouchUpInside];
                
                [_codeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.right.equalTo(cell.contentView.mas_right).offset(-15);
                    make.centerY.equalTo(cell.contentView.mas_centerY);
                    make.height.equalTo(@(30));
                    make.width.equalTo(@(86));
                }];
            }
            
            _textField[indexPath.row] = [UITextField new];
            [cell.contentView addSubview:_textField[indexPath.row]];
            _textField[indexPath.row].placeholder = list[indexPath.row][@"title"];
            _textField[indexPath.row].secureTextEntry = (indexPath.row == 2 || indexPath.row == 3)?YES:NO;
            _textField[indexPath.row].font = [UIFont systemFontOfSize2:15];
            _textField[indexPath.row].delegate = self;
            _textField[indexPath.row].clearButtonMode = UITextFieldViewModeWhileEditing;
            _textField[indexPath.row].returnKeyType = UIReturnKeyNext;
            if(indexPath.row == 0){
                _textField[indexPath.row].keyboardType = UIKeyboardTypePhonePad;
            }
            CGFloat r = (indexPath.row == 0)?116:15;
            [_textField[indexPath.row] mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(cell.contentView.mas_left).offset(50);
                make.top.bottom.equalTo(cell.contentView);
                make.right.equalTo(cell.contentView.mas_right).offset(-r);
            }];
        }
        else if (indexPath.section == 1){
            if (indexPath.row == 0) {
                _textField[4] = [UITextField new];
                [cell.contentView addSubview:_textField[4]];
                _textField[4].placeholder = list[indexPath.row][@"title"];
                _textField[4].font = [UIFont systemFontOfSize2:15];
                _textField[4].delegate = self;
                _textField[4].clearButtonMode = UITextFieldViewModeWhileEditing;
                _textField[4].returnKeyType = UIReturnKeyDone;
                [_textField[4] mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(cell.contentView.mas_left).offset(50);
                    make.top.bottom.equalTo(cell.contentView);
                    make.right.equalTo(cell.contentView.mas_right).offset(-12);
                }];
            }
        }
    }
    cell.imageView.image = [UIImage imageNamed:_dataList[indexPath.section][indexPath.row][@"img"]];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1) {
        if (indexPath.row == 1) {
            UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"男",@"女", nil];
            [sheet showInView:self.view];
        }
    }
}

#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{

    if (buttonIndex != 2) {
        _sexType = buttonIndex;
        _sexLabel.text = (_sexType == 1)?@"男":@"女";
    }
}

#pragma mark action
- (void)action_submit{
    if (_textField[0].text.length < 8) {
        SVP_ERROR_STATUS(@"请输入正确的手机号");
        return;
    }
    if (_textField[1].text.length < 3) {
        SVP_ERROR_STATUS(@"请入正确的验证码");
        return;
    }
    if (_textField[2].text.length > 16 || _textField[2].text.length < 6) {
        SVP_ERROR_STATUS(@"请输入6-16位密码");
        return;
    }
    if (_textField[3].text.length > 16 || _textField[3].text.length < 6) {
        SVP_ERROR_STATUS(@"请输入6-16位确认密码");
        return;
    }
    if (![_textField[2].text isEqualToString:_textField[3].text]) {
        SVP_ERROR_STATUS(@"密码不一致");
        return;
    }
    if (_textField[4].text.length == 0) {
        SVP_ERROR_STATUS(@"请输入邀请码");
        return;
    }
    SVP_SHOW;
    WEAK_OBJ(weakSelf, self);
    [NET_REQUEST_MANAGER registeWithAccount:_textField[0].text password:_textField[2].text smsCode:_textField[1].text referralCode:_textField[4].text success:^(id object) {
        SVP_SUCCESS_STATUS(@"注册成功");
        [weakSelf.navigationController popViewControllerAnimated:YES];
    } fail:^(id object) {
        [[FunctionManager sharedInstance] handleFailResponse:object];
    }];
}

- (void)action_getCode{
    if (_textField[0].text.length < 8) {
        SVP_ERROR_STATUS(@"请输入正确的手机号");
        return;
    }
    [_textField[1] becomeFirstResponder];
    SVP_SHOW;
    WEAK_OBJ(weakSelf, self);
    [NET_REQUEST_MANAGER requestSmsCodeWithPhone:_textField[0].text success:^(id object) {
        SVP_SUCCESS_STATUS(@"发送成功，请注意查收短信");
        [weakSelf.codeBtn beginTime:60];
    } fail:^(id object) {
        [[FunctionManager sharedInstance] handleFailResponse:object];
    }];
}

-(void)feedback{
    WebViewController *vc = [[WebViewController alloc] initWithUrl:[AppModel shareInstance].commonInfo[@"pop"]];
    vc.title = @"联系客服";
    [self.navigationController pushViewController:vc animated:YES];
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
        [_textField[3] becomeFirstResponder];
    else if(textField == _textField[3])
        [_textField[4] becomeFirstResponder];
    else
        [textField resignFirstResponder];
    return YES;
}

@end
