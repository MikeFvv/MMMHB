//
//  ForgotViewController.m
//  Project
//
//  Created by mini on 2018/7/31.
//  Copyright © 2018年 CDJay. All rights reserved.
//

#import "ForgotViewController.h"
#import "NetRequestManager.h"

@interface ForgotViewController ()<UITableViewDelegate,UITableViewDataSource>{
    UITableView *_tableView;
    NSArray *_dataList;
    UITextField *_textField[5];
    UILabel *_sexLabel;
}
@property(nonatomic,strong)UIButton *codeBtn;
@end

@implementation ForgotViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self initSubviews];
    [self initLayout];
}

#pragma mark ----- Data
- (void)initData{
    _dataList = @[@{@"title":@"请输入手机号",@"img":@"icon_phone"},@{@"title":@"请输入验证码",@"img":@"icon_security"},@{@"title":@"请输入密码",@"img":@"icon_lock"},@{@"title":@"请确认密码",@"img":@"icon_lock"}];
}


#pragma mark ----- Layout
- (void)initLayout{
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

#pragma mark ----- subView
- (void)initSubviews{
    
    self.navigationItem.title = @"忘记密码";
    
    _tableView = [UITableView groupTable];
    [self.view addSubview:_tableView];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = 51;
    _tableView.tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CDScreenWidth, 1)];
    _tableView.backgroundColor = BaseColor;
    _tableView.separatorColor = TBSeparaColor;
    
    UIView *fotView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CDScreenWidth, 80)];
    _tableView.tableFooterView = fotView;
    
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
        make.right.equalTo(self.view.mas_right).offset(-20);
        make.height.equalTo(@(42));
        make.top.equalTo(fotView.mas_top).offset(16);
    }];
}

#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:0 reuseIdentifier:@"cell"];
        
        if (indexPath.row == 0) {
            _codeBtn = [UIButton new];
            [cell.contentView addSubview:_codeBtn];
            [_codeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
            [_codeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            _codeBtn.titleLabel.font = [UIFont systemFontOfSize:12];
            _codeBtn.layer.cornerRadius = 12.5;
            _codeBtn.layer.masksToBounds = YES;
            _codeBtn.backgroundColor = HexColor(@"#6cccf9");//[UIColor colorWithHexString:@""];
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
        _textField[indexPath.row].placeholder = _dataList[indexPath.row][@"title"];
        _textField[indexPath.row].font = [UIFont scaleFont:14];
        
        CGFloat r = (indexPath.row == 0)?120:12;
        [_textField[indexPath.row] mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(cell.contentView.mas_left).offset(50);
            make.top.bottom.equalTo(cell.contentView);
            make.right.equalTo(cell.contentView.mas_right).offset(-r);
        }];
        
    }
    cell.imageView.image = [UIImage imageNamed:_dataList[indexPath.row][@"img"]];
    return cell;
}

#pragma mark action
- (void)action_getCode{
    if (_textField[0].text.length != 11) {
        SV_ERROR_STATUS(@"请输入正确的手机号！");
        return;
    }
    SV_SHOW;
    WEAK_OBJ(weakSelf, self);
    [NET_REQUEST_MANAGER requestSmsCodeWithPhone:_textField[0].text code:@"reset_passwd" success:^(id object) {
        SV_DISMISS;
        [weakSelf.codeBtn beginTime:60];
    } fail:^(id object) {
        [FUNCTION_MANAGER handleFailResponse:object];
    }];
}

- (void)action_submit{
    if (_textField[0].text.length != 11) {
        SV_ERROR_STATUS(@"请输入正确的手机号！");
        return;
    }
    if (_textField[1].text.length == 0) {
        SV_ERROR_STATUS(@"请验证码！");
        return;
    }
    if (_textField[2].text.length == 0 || _textField[3].text.length == 0) {
        SV_ERROR_STATUS(@"请输入密码！");
        return;
    }
    if (![_textField[2].text isEqualToString:_textField[3].text]) {
        SV_ERROR_STATUS(@"密码不一致！");
        return;
    }
    SV_SHOW;
    [AppModel updataPasswordObj:@{@"username":_textField[0].text,@"passwd":_textField[2].text,@"smscode":_textField[1].text} Success:^(NSDictionary *info) {
        SV_SUCCESS_STATUS(@"修改成功！");
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
