//
//  LoginViewController.m
//  Project
//
//  Created by mini on 2018/7/31.
//  Copyright © 2018年 CDJay. All rights reserved.
//

#import "LoginViewController.h"
#import "WXManage.h"
#import "NetRequestManager.h"


@interface LoginViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>{
    UITableView *_tableView;
    UITextField *_textField[2];
    NSMutableDictionary *_wxRegister;
    UITextField *_reField;
}

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self initSubviews];
    [self initLayout];
}

#pragma mark ----- Data
- (void)initData{
    _wxRegister = [[NSMutableDictionary alloc]init];
}


#pragma mark ----- Layout
- (void)initLayout{
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

#pragma mark ----- subView
- (void)initSubviews{
    
    self.navigationItem.title = @"登录";
    
    UIButton *regisBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    regisBtn.titleLabel.font = [UIFont scaleFont:14];
    [regisBtn setTitle:@"注册" forState:UIControlStateNormal];
    [regisBtn addTarget:self action:@selector(action_register) forControlEvents:UIControlEventTouchUpInside];
    [regisBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:regisBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    _tableView = [UITableView normalTable];
    [self.view addSubview:_tableView];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = 51.f;
    [_tableView setSeparatorInset:UIEdgeInsetsMake(0, 15, 0, 0)];
    _tableView.separatorColor = TBSeparaColor;
    _tableView.backgroundColor = BaseColor;
    
    UIView *fotView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CDScreenWidth, 300)];
    _tableView.tableFooterView = fotView;
    
    UIButton *loginBtn = [UIButton new];
    [fotView addSubview:loginBtn];
    loginBtn.layer.cornerRadius = 8;
    loginBtn.layer.masksToBounds = YES;
    loginBtn.backgroundColor = MBTNColor;
    loginBtn.titleLabel.font = [UIFont scaleFont:17];
    [loginBtn setTitle:@"登录" forState:UIControlStateNormal];
    [loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [loginBtn addTarget:self action:@selector(action_login) forControlEvents:UIControlEventTouchUpInside];
    
    [loginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(16);
        make.right.equalTo(self.view.mas_right).offset(-16);
        make.top.equalTo(fotView.mas_top).offset(38);
        make.height.equalTo(@(42));
    }];
    
    
    UIButton *verCodeBtn = [UIButton new];
    [fotView addSubview:verCodeBtn];
    verCodeBtn.layer.cornerRadius = 8;
    verCodeBtn.layer.masksToBounds = YES;
    verCodeBtn.layer.borderColor = [UIColor colorWithRed:0.503 green:0.503 blue:0.503 alpha:1.000].CGColor;
    verCodeBtn.layer.borderWidth = 0.5;
//    verCodeBtn.backgroundColor = MBTNColor;
    verCodeBtn.titleLabel.font = [UIFont scaleFont:16];
    [verCodeBtn setTitle:@"验证码登录" forState:UIControlStateNormal];
    [verCodeBtn setTitleColor:[UIColor colorWithRed:0.503 green:0.503 blue:0.503 alpha:1.000] forState:UIControlStateNormal];
//    [verCodeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [verCodeBtn addTarget:self action:@selector(action_verCodelogin) forControlEvents:UIControlEventTouchUpInside];
    
    [verCodeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(16);
        make.right.equalTo(self.view.mas_right).offset(-16);
        make.top.equalTo(loginBtn.mas_bottom).offset(25);
        make.height.equalTo(@(42));
    }];
    
    
    UIButton *forGot = [UIButton new];
    [fotView addSubview:forGot];
    [forGot addTarget:self action:@selector(action_forgot) forControlEvents:UIControlEventTouchUpInside];
    NSString *s = @"忘记密码？";
    [forGot setTitle:s forState:UIControlStateNormal];
    [forGot setTitleColor:HexColor(@"#a19cea") forState:UIControlStateNormal];
    forGot.titleLabel.font = [UIFont scaleFont:13];
    [forGot mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view.mas_right).offset(-24);
//        make.top.equalTo(loginBtn.mas_bottom).offset(5);
         make.top.equalTo(verCodeBtn.mas_bottom).offset(0);
        make.height.equalTo(@(44));
    }];
    
    
//    UIView *thirdView = [UIView new];
//    [fotView addSubview:thirdView];
////    BOOL b = [WXManage isWXAppInstalled];
////
////    thirdView.hidden = [WXManage isWXAppInstalled];///<yes安装
//    
//    [thirdView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.right.bottom.equalTo(fotView);
//        make.top.equalTo(forGot.mas_bottom).offset(50);
//    }];
//    
//    
//    
//    UILabel *thirdLabel = [UILabel new];
//    [thirdView addSubview:thirdLabel];
//    thirdLabel.font = [UIFont scaleFont:14];
//    thirdLabel.text = @"第三方账号登录";
//    thirdLabel.textColor = Color_9;
//    
//    [thirdLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerX.top.equalTo(thirdView);
//    }];
//    
//    UIView *lineleft = [UIView new];
//    [thirdView addSubview:lineleft];
//    lineleft.backgroundColor = Color_9;
//    
//    [lineleft mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(thirdView.mas_left).offset(15);
//        make.right.greaterThanOrEqualTo(thirdLabel.mas_left).offset(-15);
//        make.centerY.equalTo(thirdLabel.mas_centerY);
//        make.height.equalTo(@(1.0));
//    }];
//    
//    UIView *lineright = [UIView new];
//    [thirdView addSubview:lineright];
//    lineright.backgroundColor = Color_9;
//    [lineright mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.lessThanOrEqualTo(thirdLabel.mas_right).offset(15);
//        make.right.equalTo(thirdView.mas_right).offset(-15);
//        make.height.equalTo(@(1.0));
//        make.centerY.equalTo(thirdLabel.mas_centerY);
//    }];
//    
//    UIButton *wx = [UIButton new];
//    [thirdView addSubview:wx];
//    [wx setBackgroundImage:[UIImage imageNamed:@"icon_wx"] forState:UIControlStateNormal];
//    [wx addTarget:self action:@selector(action_wxLogin) forControlEvents:UIControlEventTouchUpInside];
//    
//    [wx mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerX.equalTo(thirdView);
//        make.top.equalTo(thirdLabel.mas_bottom).offset(25);
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

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell.backgroundColor = [UIColor whiteColor];
        
        cell = [[UITableViewCell alloc]initWithStyle:0 reuseIdentifier:@"cell"];
        _textField[indexPath.row] = [UITextField new];
        [cell.contentView addSubview:_textField[indexPath.row]];
        _textField[indexPath.row].font = [UIFont scaleFont:14];
        _textField[indexPath.row].placeholder = (indexPath.row == 0)?@"手机号/用户名":@"密码";
        _textField[indexPath.row].secureTextEntry = (indexPath.row == 1)?YES:NO;
        _textField[indexPath.row].clearButtonMode = UITextFieldViewModeWhileEditing;
        _textField[indexPath.row].delegate = self;
        if(indexPath.row == 0)
            _textField[0].returnKeyType = UIReturnKeyNext;
        else
            _textField[1].returnKeyType = UIReturnKeyDone;
        if(indexPath.row == 0)
            _textField[0].keyboardType = UIKeyboardTypePhonePad;

        [_textField[indexPath.row] mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(cell.contentView.mas_left).offset(20);
            make.right.equalTo(cell.contentView.mas_right).offset(-20);
            make.top.bottom.equalTo(cell.contentView);
        }];
        if(indexPath.row == 0)
            _textField[0].text = @"18060855586";
        else if(indexPath.row == 1)
            _textField[1].text = @"123456";
    }
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

#pragma mark action
- (void)action_login{
    
    if (_textField[0].text.length == 0) {
        SV_ERROR_STATUS(@"请输入手机号！");
        return;
    }
    if (_textField[1].text.length == 0) {
        SV_ERROR_STATUS(@"请输入密码！");
        return;
    }
    SV_SHOW;
    WEAK_OBJ(weakSelf,self);
    [NET_REQUEST_MANAGER requestTockenWithAccount:_textField[0].text password:_textField[1].text success:^(id object) {
        [weakSelf requestUserInfo];
    } fail:^(id object) {
        [FUNCTION_MANAGER handleFailResponse:object];
    }];
//    [AppModel loginObj:@{@"username":_textField[0].text,@"passwd":_textField[1].text} Success:^(NSDictionary *info) {
//        SV_SUCCESS_STATUS(@"登录成功");
////        [self.navigationController popViewControllerAnimated:YES];
//    } Failure:^(NSError *error) {
//        SV_ERROR(error);
//    }];
}


#pragma mark - 验证码登录
- (void)action_verCodelogin{
    
    CDPush(self.navigationController, CDVC(@"VerCodeLoginController"), YES);
}



-(void)requestUserInfo{
    WEAK_OBJ(weakSelf, self);
    [NET_REQUEST_MANAGER requestUserInfoWithUserId:APP_MODEL.user.userId success:^(id object) {
            [APP_MODEL resetRootAnimation:YES];
//            [weakSelf.navigationController popViewControllerAnimated:YES];
    }fail:^(id object) {
        [FUNCTION_MANAGER handleFailResponse:object];
    }];
}
- (void)action_wxLogin{
    SV_SHOW;
    CDWeakSelf(self);
//    [AppModel wxLoginSuccess:^(NSDictionary *info) {
//        CDStrongSelf(self);
//        if (info) {
//            SV_DISMISS;
//            [self alert:info];
//        }
//        else{
//            SV_SUCCESS_STATUS(@"登录成功");
//        }
//    } Failure:^(NSError *error) {
//        [FUNCTION_MANAGER handleFailResponse:error];
//    }];
}

- (void)alert:(NSDictionary *)alert{
    _wxRegister = [[NSMutableDictionary alloc]initWithDictionary:alert];
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"未注册，请补充推荐码" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [vc addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"请输入推荐码";
        textField.font = [UIFont scaleFont:14];
        self-> _reField = textField;
    }];
    
    UIAlertAction *cancle = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [vc addAction:cancle];
    
    UIAlertAction *make = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (self->_reField.text.length == 0) {
            return ;
        }
        [self action_wxRester];
        [vc dismissViewControllerAnimated:YES completion:nil];
    }];
    [vc addAction:make];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)action_wxRester{
    SV_SHOW;
//    if (_reField.text.length == 0) {
//        return;
//    }
//    [_wxRegister setObject:_reField.text forKey:@"referralCode"];
//    [AppModel wxResterObj:_wxRegister Success:^(NSDictionary *info) {
//        SV_SUCCESS_STATUS(@"登录成功");
////        [self.navigationController popViewControllerAnimated:YES];
//    } Failure:^(NSError *error) {
//        SV_ERROR(error);
//    }];
}

- (void)action_forgot{
    CDPush(self.navigationController, CDVC(@"ForgotViewController"), YES);
}

- (void)action_register{
    CDPush(self.navigationController, CDVC(@"RegisterViewController"), YES);
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if(textField == _textField[0])
        [_textField[1] becomeFirstResponder];
    else
        [_textField[1] resignFirstResponder];
    return YES;
}

-(void)dealloc{
    NSLog(@"");
}
@end
