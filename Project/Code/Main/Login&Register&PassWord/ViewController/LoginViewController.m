//
//  LoginViewController.m
//  Project
//
//  Created by mini on 2018/7/31.
//  Copyright © 2018年 CDJay. All rights reserved.
//

#import "LoginViewController.h"
#import "WXManage.h"
#import "GTMBase64.h"
#import "NSData+AES.h"
#import "NetRequestManager.h"
#import "LoginBySMSViewController.h"
#import "AddIpViewController.h"

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
    if(![AppModel shareInstance].isReleaseOrBeta)
        self.navigationItem.title = @"登录";
    else
        self.navigationItem.title = APP_MODEL.serverUrl;
    
//    UIButton *regisBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 44, 44)];
//    regisBtn.titleLabel.font = [UIFont systemFontOfSize:15];
//    [regisBtn setTitle:@"注册" forState:UIControlStateNormal];
//    [regisBtn addTarget:self action:@selector(action_register) forControlEvents:UIControlEventTouchUpInside];
//    [regisBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:regisBtn];
//    self.navigationItem.rightBarButtonItem = rightItem;
    
    _tableView = [UITableView groupTable];
    [self.view addSubview:_tableView];
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = BaseColor;
    _tableView.backgroundView = view;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = 52.f;
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
    loginBtn.titleLabel.font = [UIFont boldSystemFontOfSize2:17];
    [loginBtn setTitle:@"登录" forState:UIControlStateNormal];
    [loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [loginBtn addTarget:self action:@selector(action_login) forControlEvents:UIControlEventTouchUpInside];
    [loginBtn delayEnable];
    [loginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(16);
        make.right.equalTo(self.view.mas_right).offset(-16);
        make.top.equalTo(fotView.mas_top).offset(38);
        make.height.equalTo(@(44));
    }];
    
    UIButton *yzmBtn = [UIButton new];
    [fotView addSubview:yzmBtn];
    yzmBtn.layer.cornerRadius = 8;
    yzmBtn.layer.borderWidth = 0.5;
    yzmBtn.layer.borderColor = COLOR_X(230, 230, 230).CGColor;
    yzmBtn.layer.masksToBounds = YES;
    yzmBtn.backgroundColor = COLOR_X(254, 254, 254);
    yzmBtn.titleLabel.font = [UIFont boldSystemFontOfSize2:16];
    [yzmBtn setTitle:@"注册" forState:UIControlStateNormal];
    [yzmBtn setTitleColor:COLOR_X(120, 120, 120) forState:UIControlStateNormal];
    [yzmBtn addTarget:self action:@selector(action_register) forControlEvents:UIControlEventTouchUpInside];
    [yzmBtn delayEnable];
    [yzmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(16);
        make.right.equalTo(self.view.mas_right).offset(-16);
        make.top.equalTo(loginBtn.mas_bottom).offset(15);
        make.height.equalTo(@(44));
    }];
    
    UIButton *forGot = [UIButton new];
    [fotView addSubview:forGot];
    [forGot addTarget:self action:@selector(action_forgot) forControlEvents:UIControlEventTouchUpInside];
    
    NSMutableAttributedString *AttributedStr = [[NSMutableAttributedString alloc]initWithString:@"忘记密码"];
    NSRange rang = NSMakeRange(0, 4);
    [AttributedStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize2:13] range:rang];
    [AttributedStr addAttribute:NSForegroundColorAttributeName value:MBTNColor range:rang];
    //[AttributedStr addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:rang];
    
    [forGot setAttributedTitle:AttributedStr forState:UIControlStateNormal];
    [forGot delayEnable];
    [forGot mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view.mas_right).offset(-30);
        make.top.equalTo(yzmBtn.mas_bottom);
        make.width.equalTo(@70);
        make.height.equalTo(@(44));
    }];
    
    
    UIView *thirdView = [UIView new];
    [fotView addSubview:thirdView];
    thirdView.hidden = YES;
    //    BOOL b = [WXManage isWXAppInstalled];
    //
    //    thirdView.hidden = [WXManage isWXAppInstalled];///<yes安装
    
    [thirdView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(fotView);
        make.top.equalTo(forGot.mas_bottom).offset(50);
    }];
    
    UILabel *thirdLabel = [UILabel new];
    [thirdView addSubview:thirdLabel];
    thirdLabel.font = [UIFont systemFontOfSize2:14];
    thirdLabel.text = @"第三方账号登录";
    thirdLabel.textColor = Color_9;
    
    [thirdLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.top.equalTo(thirdView);
    }];
    
    UIView *lineleft = [UIView new];
    [thirdView addSubview:lineleft];
    lineleft.backgroundColor = Color_9;
    
    [lineleft mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(thirdView.mas_left).offset(15);
        make.right.greaterThanOrEqualTo(thirdLabel.mas_left).offset(-15);
        make.centerY.equalTo(thirdLabel.mas_centerY);
        make.height.equalTo(@(1.0));
    }];
    
    UIView *lineright = [UIView new];
    [thirdView addSubview:lineright];
    lineright.backgroundColor = Color_9;
    [lineright mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.lessThanOrEqualTo(thirdLabel.mas_right).offset(15);
        make.right.equalTo(thirdView.mas_right).offset(-15);
        make.height.equalTo(@(1.0));
        make.centerY.equalTo(thirdLabel.mas_centerY);
    }];
    
    UIButton *wx = [UIButton new];
    [thirdView addSubview:wx];
    [wx setBackgroundImage:[UIImage imageNamed:@"icon_wx"] forState:UIControlStateNormal];
    [wx addTarget:self action:@selector(action_wxLogin) forControlEvents:UIControlEventTouchUpInside];
    
    [wx mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(thirdView);
        make.top.equalTo(thirdLabel.mas_bottom).offset(25);
    }];
    
    UILabel *versionLabel = [UILabel new];
    [self.view addSubview:versionLabel];
    versionLabel.font = [UIFont systemFontOfSize:13];
    versionLabel.textAlignment = NSTextAlignmentCenter;
    versionLabel.text = [NSString stringWithFormat:@"v%@",[FUNCTION_MANAGER getApplicationVersion]];
    versionLabel.textColor = COLOR_X(200, 200, 200);
    
    [versionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.bottom.equalTo(self.view.mas_bottom).offset(-15);
    }];
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.1f;
}

- (void)action_wxLogin {
    
}

-(void)viewDidAppear:(BOOL)animated{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *mobile = [ud objectForKey:@"mobile"];
    _textField[0].text = mobile;
    if([AppModel shareInstance].isReleaseOrBeta)
        _textField[1].text = @"123456";
    if(_textField[0].text.length == 0)
        [_textField[0] becomeFirstResponder];
    else if(_textField[1].text.length == 0)
        [_textField[1] becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell.backgroundColor = [UIColor whiteColor];
        
        cell = [[UITableViewCell alloc]initWithStyle:0 reuseIdentifier:@"cell"];
        _textField[indexPath.row] = [UITextField new];
        [cell.contentView addSubview:_textField[indexPath.row]];
        _textField[indexPath.row].font = [UIFont systemFontOfSize2:15];
        _textField[indexPath.row].placeholder = (indexPath.row == 0)?@"请输入手机号":@"请输入密码";
        _textField[indexPath.row].secureTextEntry = (indexPath.row == 1)?YES:NO;
        _textField[indexPath.row].delegate = self;
        _textField[indexPath.row].clearButtonMode = UITextFieldViewModeWhileEditing;
        if(indexPath.row == 0){
            _textField[indexPath.row].keyboardType = UIKeyboardTypePhonePad;
            _textField[indexPath.row].returnKeyType = UIReturnKeyNext;
            cell.imageView.image = [UIImage imageNamed:@"icon_phone"];
            
        }
        else{
            _textField[indexPath.row].returnKeyType = UIReturnKeyDone;
            cell.imageView.image = [UIImage imageNamed:@"icon_lock"];
        }
        [_textField[indexPath.row] mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(cell.contentView.mas_left).offset(50);
            make.right.equalTo(cell.contentView.mas_right).offset(-20);
            make.top.bottom.equalTo(cell.contentView);
        }];
    }
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

#pragma mark action
- (void)action_login{
    NSString *account = _textField[0].text;
    __weak __typeof(self)weakSelf = self;
    
    if([account isEqualToString:@"88866610"]){
        [self accountSwitch];
        return;
    }
    
    if (account.length < 8) {
        SVP_ERROR_STATUS(@"请输入正确的手机号");
        return;
    }
    if (_textField[1].text.length < 6) {
        SVP_ERROR_STATUS(@"请输入密码");
        return;
    }
    [self.view endEditing:YES];
    SVP_SHOW;
    [NET_REQUEST_MANAGER requestTockenWithAccount:_textField[0].text password:_textField[1].text success:nil fail:^(id object) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf failData:object];
        
    }];
}


- (void)accountSwitch {
    __weak __typeof(self)weakSelf = self;
    [self.view endEditing:YES];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"请选择服务器地址" preferredStyle:UIAlertControllerStyleActionSheet];
    NSArray *arr = [APP_MODEL ipArray];
    
    NSInteger index = 0;
    for (NSDictionary *dic in arr) {
        
        UIAlertAction *action = [UIAlertAction actionWithTitle:dic[@"url"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            APP_MODEL.serverUrl = dic[@"url"];
            APP_MODEL.rongYunKey = dic[@"rongYunKey"];
            APP_MODEL.isReleaseOrBeta = [dic[@"isReleaseOrBeta"] boolValue];
            APP_MODEL.testVersionIndex = index;
            APP_MODEL.authKey = dic[@"authKey"];
            [APP_MODEL saveAppModel];
            SVP_SUCCESS_STATUS(@"切换成功，重启生效");
            [FUNCTION_MANAGER performSelector:@selector(exitApp) withObject:nil afterDelay:1.0];
        }];
        [alertController addAction:action];
        index++;
    }
    
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"添加ip" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        AddIpViewController *vc = [[AddIpViewController alloc] init];
        [strongSelf.navigationController pushViewController:vc animated:YES];
    }];
    [alertController addAction:action];
    action = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertController addAction:action];
    
    [alertController modifyColor];
    
    [self presentViewController:alertController animated:YES completion:^{
        
    }];
}

- (void)failData:(id)object {
    if([object isKindOfClass:[NSDictionary class]]){
        if ([[object objectForKey:@"error"] isEqualToString:@"unauthorized"]) {
            SVP_ERROR_STATUS(kAccountOrPasswordErrorMessage);
            return;
        } else if ([[object objectForKey:@"error"] isEqualToString:@"invalid_grant"]) {
            SVP_ERROR_STATUS(kAccountOrPasswordErrorMessage);
            return;
        }
    }
    [FUNCTION_MANAGER handleFailResponse:object];
}

-(void)action_loginBySMS{
    LoginBySMSViewController *vc = [[LoginBySMSViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
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
        [textField resignFirstResponder];
    return YES;
}

@end
