//
//  UpdateNicknameViewController.m
//  Project
//
//  Created by mini on 2018/8/15.
//  Copyright © 2018年 CDJay. All rights reserved.
//

#import "UpdateNicknameViewController.h"

@interface UpdateNicknameViewController ()<UITextFieldDelegate>{///<UITableViewDataSource,UITableViewDelegate>
    UITableView *_tableView;
    UITextField *_textField;
}

@end

@implementation UpdateNicknameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self initSubviews];
    [self initLayout];
}

#pragma mark ----- Data
- (void)initData{
    
}


#pragma mark ----- Layout
- (void)initLayout{
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

#pragma mark ----- subView
- (void)initSubviews{
    
    self.navigationItem.title = @"昵称";
    
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 44, 40)];
    btn.titleLabel.font = [UIFont scaleFont:14];
    [btn setTitle:@"保存" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(action_save) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *right = [[UIBarButtonItem alloc]initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = right;
    
    _tableView = [UITableView normalTable];
    [self.view addSubview:_tableView];
    
    UIView *headView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CDScreenWidth, 50)];
    _tableView.tableHeaderView = headView;
    _tableView.backgroundColor = BaseColor;
    headView.backgroundColor = [UIColor whiteColor];
    _textField = [UITextField new];
    [headView addSubview:_textField];
    _textField.placeholder = @"填写16字以内的昵称（只能输入中文、数字、字母）";
    _textField.text = APP_MODEL.user.userNick;
    _textField.font = [UIFont scaleFont:14];
    _textField.delegate = self;
    _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _textField.returnKeyType = UIReturnKeyDone;
    
    [_textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(12);
        make.top.bottom.equalTo(headView);
        make.right.equalTo(headView.mas_right).offset(-12);
    }];
}

#pragma mark action
- (void)action_save{//UPDATENAME
    if (_textField.text.length == 0) {
        SV_ERROR_STATUS(@"请输入昵称！");
        return;
    }
    [[NSNotificationCenter defaultCenter]postNotificationName:@"UPDATENAME" object:@{@"text":_textField.text}];
    CDPop(self.navigationController, YES);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated{
    [_textField becomeFirstResponder];
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
    [textField resignFirstResponder];
    return YES;
}
@end
