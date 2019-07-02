//
//  LoginViewController.m
//  Project
//
//  Created by mini on 2018/7/31.
//  Copyright © 2018年 CDJay. All rights reserved.
//

#import "LoginViewController.h"
#import "UIView+AZGradient.h"
#import "WXManage.h"
#import "GTMBase64.h"
#import "NSData+AES.h"
#import "NetRequestManager.h"
#import "LoginBySMSViewController.h"
#import "AddIpViewController.h"
#import "SSKeychain.h"
#import "SAMKeychain.h"

@interface LoginViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,ActionSheetDelegate>{
    UITableView *_tableView;
    UITextField *_textField[2];
    NSMutableDictionary *_wxRegister;
    UITextField *_reField;
}
@property (nonatomic, strong) NSTimer *timer;
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
    
    UIView *fotView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 300)];
    _tableView.tableFooterView = fotView;
    
    UIButton *loginBtn = [UIButton new];
    [fotView addSubview:loginBtn];
    loginBtn.layer.cornerRadius = 8;
    loginBtn.layer.masksToBounds = YES;
    loginBtn.backgroundColor = MBTNColor;
//    [loginBtn setBackgroundImage:[UIImage imageNamed:@"navBarBg"] forState:UIControlStateNormal];
    [loginBtn az_setGradientBackgroundWithColors:@[HEXCOLOR(0xfe3366),HEXCOLOR(0xff733d)] locations:0 startPoint:CGPointMake(0, 0) endPoint:CGPointMake(1, 0)];
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
    yzmBtn.hidden = YES;
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
    #ifdef DEBUG
        versionLabel.text = [NSString stringWithFormat:@"debug v%@",[[FunctionManager sharedInstance] getApplicationVersion]];
    #else
        versionLabel.text = [NSString stringWithFormat:@"v%@",[[FunctionManager sharedInstance] getApplicationVersion]];
    #endif
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
    if(mobile == nil){
        NSArray *arr = [SAMKeychain accountsForService:@"com.fy.ser"];
        if(arr.count > 0){
            NSDictionary *dic = arr[0];
            mobile = dic[@"acct"];
        }
    }
    _textField[0].text = mobile;
    if([AppModel shareInstance].debugMode)
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
            _textField[indexPath.row].keyboardType = UIKeyboardTypeNumberPad;
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
    if([account isEqualToString:@"88866610"]){
        [self accountSwitch];
        return;
    }
    
    if (account.length < 8 || account.length > 11) {
        SVP_ERROR_STATUS(@"请输入正确的手机号");
        return;
    }
    if (_textField[1].text.length < 6) {
        SVP_ERROR_STATUS(@"请输入6位以上密码");
        return;
    }
    [self.view endEditing:YES];
    
    if ([AppModel shareInstance].commonInfo == nil||
        [AppModel shareInstance].appClientIdInCommonInfo==nil) {
        
        [NET_REQUEST_MANAGER requestAppConfigWithSuccess:^(id object) {
            SVP_SHOW;
            [NET_REQUEST_MANAGER requestTockenWithAccount:self->_textField[0].text password:self->_textField[1].text success:^(id object) {
                SVP_DISMISS;
                if([object isKindOfClass:[NSDictionary class]]){
                    if ([object objectForKey:@"code"] && [[object objectForKey:@"code"] integerValue] == 0) {
                        [SSKeychain setPassword:self->_textField[1].text forService:@"password" account:self->_textField[0].text];
                    }
                    [self getUserInfo];
                }
            }  fail:^(id object) {
                [[FunctionManager sharedInstance] handleFailResponse:object];
            }];
        } fail:^(id object) {
            SVP_ERROR_STATUS(@"网络请求初始化接口失败，稍后重试...");
        }];
        
    }else{
        
        SVP_SHOW;
        [NET_REQUEST_MANAGER requestTockenWithAccount:_textField[0].text password:_textField[1].text success:^(id object) {
            SVP_DISMISS;
            if([object isKindOfClass:[NSDictionary class]]){
                NSDictionary* dic = object[@"data"];
                if (![FunctionManager isEmpty:dic[@"userId"]]) {
                    [SSKeychain setPassword:self->_textField[1].text forService:@"password" account:self->_textField[0].text];
                    SetUserDefaultKeyWithObject(@"mobile", self->_textField[0].text);
                    UserDefaultSynchronize;
                }
                [self getUserInfo];
            }
        }  fail:^(id object) {
            [[FunctionManager sharedInstance] handleFailResponse:object];
        }];
    
    }
}


/**
 获取用户信息
 */
- (void)getUserInfo {
    [NET_REQUEST_MANAGER requestUserInfoWithSuccess:^(id object) {
//        [[AppModel shareInstance] reSetRootAnimation:YES];
        [[AppModel shareInstance] reSetTabBarAsRootAnimation];
    } fail:^(id object) {
        [[FunctionManager sharedInstance] handleFailResponse:object];
    }];
    [NET_REQUEST_MANAGER requestAppConfigWithSuccess:nil fail:nil];
}


- (void)accountSwitch {
    [self.view endEditing:YES];
//    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"请选择服务器地址" preferredStyle:UIAlertControllerStyleActionSheet];
    NSArray *arr = [[AppModel shareInstance] ipArray];
    
    NSMutableArray *newArr = [NSMutableArray array];
    for (NSDictionary *dic in arr) {
        NSString *bankName = dic[@"url"];
        [newArr addObject:bankName];
    }
    [newArr addObject:@"添加ip"];
    ActionSheetCus *sheet = [[ActionSheetCus alloc] initWithArray:newArr];
    sheet.titleLabel.text = @"请选择地址";
    sheet.delegate = self;
    [sheet showWithAnimationWithAni:YES];
}

-(void)actionSheetDelegateWithActionSheet:(ActionSheetCus *)actionSheet index:(NSInteger)index{
    NSArray *arr = [[AppModel shareInstance] ipArray];
    if(index > arr.count)
    return;
    if(index == arr.count){
        AddIpViewController *vc = [[AddIpViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        [ud setObject:INT_TO_STR(index) forKey:@"serverIndex"];
        [ud synchronize];
        SVP_SUCCESS_STATUS(@"切换成功，重启生效");
        [[FunctionManager sharedInstance] performSelector:@selector(exitApp) withObject:nil afterDelay:1.0];
    }
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
