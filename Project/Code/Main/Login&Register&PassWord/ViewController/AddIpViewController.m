//
//  AddIpViewController.m
//  Project
//
//  Created by fy on 2019/1/12.
//  Copyright © 2019 CDJay. All rights reserved.
//

#import "AddIpViewController.h"

@interface AddIpViewController ()<UITextFieldDelegate>{
    UITextField *_textField;
    NSInteger _netType;
}
@end

@implementation AddIpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _netType = 0;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self.navigationController.navigationBar setTranslucent:NO];
    self.title = @"添加ip";
    self.view.backgroundColor = BaseColor;
    
    UITextField *view = [[UITextField alloc] init];
    view.backgroundColor = COLOR_X(240, 240, 240);
    view.font = [UIFont systemFontOfSize2:16];
    view.delegate = self;
    view.placeholder = @"请输入地址 如：http://10.10.15.176:8099/";
    _textField = view;
    [self.view addSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-20);
        make.top.equalTo(self.view).offset(30);
        make.height.equalTo(@44);
    }];
    
    UILabel *label = [[UILabel alloc] init];
    label.textColor = Color_6;
    label.font = [UIFont systemFontOfSize:15];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"类型：";
    [view addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view.mas_left);
        make.height.equalTo(@44);
        make.top.equalTo(view.mas_bottom).offset(15);
    }];
    
    UIButton *typeBtn = [UIButton new];
    [self.view addSubview:typeBtn];
    typeBtn.layer.masksToBounds = YES;
    typeBtn.backgroundColor = COLOR_X(100, 100, 100);
    typeBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    [typeBtn setTitle:@"外网" forState:UIControlStateNormal];
    [typeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [typeBtn addTarget:self action:@selector(changeNetType:) forControlEvents:UIControlEventTouchUpInside];
    [typeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(label.mas_right).offset(10);
        make.top.equalTo(view.mas_bottom).offset(15);
        make.height.equalTo(@(44));
        make.width.equalTo(@80);
    }];
    
    UIButton *addBtn = [UIButton new];
    [self.view addSubview:addBtn];
    addBtn.layer.cornerRadius = 8;
    addBtn.layer.masksToBounds = YES;
    addBtn.backgroundColor = MBTNColor;
    addBtn.titleLabel.font = [UIFont boldSystemFontOfSize2:17];
    [addBtn setTitle:@"添加" forState:UIControlStateNormal];
    [addBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [addBtn addTarget:self action:@selector(addAction) forControlEvents:UIControlEventTouchUpInside];
    [addBtn delayEnable];
    [addBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(20);
        make.right.equalTo(self.view.mas_right).offset(-20);
        make.top.equalTo(typeBtn.mas_bottom).offset(38);
        make.height.equalTo(@(44));
    }];
}

-(void)changeNetType:(UIButton *)btn{
    btn.selected = !btn.selected;
    if(btn.selected){
        [btn setTitle:@"内网" forState:UIControlStateNormal];
        _netType = 1;
        [AppModel shareInstance].isReleaseOrBeta = YES;
    }
    else{
        [btn setTitle:@"外网" forState:UIControlStateNormal];
        _netType = 0;
        [AppModel shareInstance].isReleaseOrBeta = NO;
    }
}

-(void)addAction{
    NSString *ip = _textField.text;
    if(ip.length == 0)
        return;
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSArray *arr = [ud objectForKey:@"ipArray"];
    NSMutableArray *mArr = [[NSMutableArray alloc] initWithArray:arr];
    if(mArr.count > 1)
        [mArr removeObjectAtIndex:0];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:ip forKey:@"url"];
    if(_netType == 0)
        [dic setObject:kRongYunKey forKey:@"rongYunKey"];
    else
        [dic setObject:kRongfYunKeyTest1 forKey:@"rongYunKey"];

    [mArr addObject:dic];
    [ud setObject:mArr forKey:@"ipArray"];
    [ud synchronize];
    if(_netType == 0)
        SVP_SUCCESS_STATUS(@"添加外网ip成功");
    else
        SVP_SUCCESS_STATUS(@"添加内网ip成功");
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.view endEditing:YES];
    return YES;
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

@end
