//
//  RegisterViewController.m
//  Project
//
//  Created by mini on 2018/7/31.
//  Copyright © 2018年 CDJay. All rights reserved.
//

#import "RegisterViewController.h"
#import "NetRequestManager.h"

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
    _dataList = @[@[@{@"title":@"请输入手机号",@"img":@"icon_phone"},@{@"title":@"请输入验证码",@"img":@"icon_security"},@{@"title":@"请输入密码",@"img":@"icon_lock"},@{@"title":@"请确认密码",@"img":@"icon_lock"}],@[@{@"title":@"推荐码",@"img":@"icon_recommend"}]];
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
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = 51;
    _tableView.sectionFooterHeight = 8.0f;
    _tableView.tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CDScreenWidth, 1)];
    _tableView.backgroundColor = BaseColor;
    _tableView.separatorColor = TBSeparaColor;
    
    UIView *fotView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CDScreenWidth, 200)];
    _tableView.tableFooterView = fotView;
    
    UILabel *tip = [UILabel new];
    [fotView addSubview:tip];
    tip.numberOfLines = 0;
    tip.font = [UIFont scaleFont:12];
    tip.textColor = Color_6;
    [tip mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(20);
        make.top.equalTo(fotView.mas_top).offset(13);
    }];
    
    tip.text = @"温馨提示：\n你注册成功之后，随便更改即可";
    
    UIButton *btn = [UIButton new];
    [fotView addSubview:btn];
    btn.titleLabel.font = [UIFont scaleFont:15];
    [btn setTitle:@"完成" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(action_submit) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.layer.cornerRadius = 8.0f;
    btn.layer.masksToBounds = YES;
    btn.backgroundColor = MBTNColor;
    
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(16));
        make.right.equalTo(self.view.mas_right).offset(-16);
        make.height.equalTo(@(42));
        make.top.equalTo(tip.mas_bottom).offset(16);
    }];
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
                _codeBtn.titleLabel.font = [UIFont systemFontOfSize:12];
                _codeBtn.layer.cornerRadius = 12.5;
                _codeBtn.layer.masksToBounds = YES;
                _codeBtn.backgroundColor = HexColor(@"#6cccf9");;
                [_codeBtn addTarget:self action:@selector(action_getCode) forControlEvents:UIControlEventTouchUpInside];
                
                [_codeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.right.equalTo(cell.contentView.mas_right).offset(-15);
                    make.centerY.equalTo(cell.contentView.mas_centerY);
                    make.height.equalTo(@(25));
                    make.width.equalTo(@(77));
                }];
            }
            
            _textField[indexPath.row] = [UITextField new];
            [cell.contentView addSubview:_textField[indexPath.row]];
            _textField[indexPath.row].placeholder = list[indexPath.row][@"title"];
            _textField[indexPath.row].secureTextEntry = (indexPath.row == 2 || indexPath.row == 3)?YES:NO;
            _textField[indexPath.row].font = [UIFont scaleFont:14];
            _textField[indexPath.row].clearButtonMode = UITextFieldViewModeWhileEditing;
            _textField[indexPath.row].delegate = self;
                    _textField[indexPath.row].returnKeyType = UIReturnKeyNext;

            if(indexPath.row == 0)
                _textField[0].keyboardType = UIKeyboardTypePhonePad;
            else if(indexPath.row == 1)
                _textField[1].keyboardType = UIKeyboardTypeNamePhonePad;
            CGFloat r = (indexPath.row == 0)?120:12;
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
                _textField[4].font = [UIFont scaleFont:14];
                _textField[4].clearButtonMode = UITextFieldViewModeWhileEditing;
                _textField[4].returnKeyType = UIReturnKeyDone;
                _textField[4].delegate = self;
                [_textField[4] mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(cell.contentView.mas_left).offset(50);
                    make.top.bottom.equalTo(cell.contentView);
                    make.right.equalTo(cell.contentView.mas_right).offset(-12);
                }];
            }
            else{
                cell.textLabel.font = [UIFont scaleFont:14];
                cell.textLabel.text = @"性别";
                
                _sexLabel = [UILabel new];
                [cell.contentView addSubview:_sexLabel];
                _sexLabel.font = [UIFont scaleFont:14];
                _sexLabel.text = @"男";
                
                [_sexLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(cell.contentView.mas_left).offset(100);
                    make.top.bottom.right.equalTo(cell.contentView);
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
    NSLog(@"%ld",buttonIndex);
    if (buttonIndex != 2) {
        _sexType = buttonIndex;
        _sexLabel.text = (_sexType == 1)?@"男":@"女";
    }
}

#pragma mark action
- (void)action_submit{
    if (_textField[0].text.length < 11) {
        SV_ERROR_STATUS(@"请输入正确的手机号！");
        return;
    }
    if (_textField[1].text.length == 0) {
        SV_ERROR_STATUS(@"请验证码！");
        return;
    }
    if (_textField[2].text.length < 6 || _textField[3].text.length < 6) {
        SV_ERROR_STATUS(@"请输入6位以上密码！");
        return;
    }
    if (![_textField[2].text isEqualToString:_textField[3].text]) {
        SV_ERROR_STATUS(@"密码不一致！");
        return;
    }
    if (_textField[4].text.length == 0) {
        SV_ERROR_STATUS(@"请输入邀请码！");
        return;
    }
    SV_SHOW;
    WEAK_OBJ(weakSelf, self);
    [NET_REQUEST_MANAGER registeWithAccount:_textField[0].text password:_textField[2].text smsCode:_textField[1].text referralCode:_textField[4].text success:^(id object) {
        SV_SUCCESS_STATUS(@"注册成功!");
        CDPop(weakSelf.navigationController, YES);
    } fail:^(id object) {
        [FUNCTION_MANAGER handleFailResponse:object];
    }];
}

- (void)action_getCode{
    if (_textField[0].text.length < 11) {
        SV_ERROR_STATUS(@"请输入正确的手机号！");
        return;
    }
    SV_SHOW;
    WEAK_OBJ(weakSelf, self);
    [NET_REQUEST_MANAGER requestSmsCodeWithPhone:_textField[0].text code:@"reg" success:^(id object) {
        SV_SUCCESS_STATUS(@"验证码发送成功");
        [weakSelf.codeBtn beginTime:60];
        [weakSelf af];
    } fail:^(id object) {
        [FUNCTION_MANAGER handleFailResponse:object];
    }];
}

-(void)af{
    [_textField[1] becomeFirstResponder];
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
    for (NSInteger i = 0; i < 4; i ++) {
        if(_textField[i] == textField){
            [_textField[i + 1] becomeFirstResponder];
            return YES;
        }
    }
    [textField resignFirstResponder];
    return YES;
}
@end
