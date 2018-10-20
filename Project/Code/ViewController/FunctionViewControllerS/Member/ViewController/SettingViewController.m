//
//  SettingViewController.m
//  Project
//
//  Created by mini on 2018/8/1.
//  Copyright © 2018年 CDJay. All rights reserved.
//

#import "SettingViewController.h"

@interface SettingViewController ()<UITableViewDelegate,UITableViewDataSource>{
    UITableView *_tableView;
    NSArray *_rowList;
    UISwitch *_sw;
}

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self initSubviews];
    [self initLayout];
}

#pragma mark ----- Data
- (void)initData{
    _rowList = @[@[@"账号",@"手机号",@"提示音"],@[@"重设密码"]];
}


#pragma mark ----- Layout
- (void)initLayout{
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

#pragma mark ----- subView
- (void)initSubviews{
    
    self.navigationItem.title = @"设置";
    _tableView = [UITableView groupTable];
    [self.view addSubview:_tableView];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = 51.f;
    _tableView.separatorColor = TBSeparaColor;
    _tableView.tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CDScreenWidth, 1)];
}

#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _rowList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *list = _rowList[section];
    return list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"result"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:0 reuseIdentifier:@"result"];
        cell.textLabel.font = [UIFont scaleFont:14];
        if (indexPath.section == 0) {
            if (indexPath.row == 0 || indexPath.row ==1) {
                UILabel *label = [UILabel new];
                [cell.contentView addSubview:label];
                label.font = [UIFont scaleFont:14];
                label.textColor = Color_3;
                label.text = (indexPath.row == 0)?APP_MODEL.user.userId:APP_MODEL.user.userMobile;
                
                [label mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.bottom.equalTo(cell.contentView);
                    make.right.equalTo(cell.contentView.mas_right).offset(-15);
                }];
            }
            if (indexPath.row == 2) {
                _sw = [UISwitch new];
                [cell.contentView addSubview:_sw];
                _sw.on = (APP_MODEL.Sound == NO)?YES:NO;//APP_MODEL.Sound;
                [_sw addTarget:self action:@selector(action_setSound) forControlEvents:UIControlEventValueChanged];
                [_sw mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.right.equalTo(cell.contentView.mas_right).offset(-12);
                    make.centerY.equalTo(cell.contentView);
                }];
            }
        }
      }
    cell.textLabel.text = _rowList[indexPath.section][indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1) {
        CDPush(self.navigationController, CDVC(@"ForgotViewController"), YES);
    }
}

#pragma mark action
- (void)action_setSound{
    APP_MODEL.Sound = (_sw.on== NO)?YES:NO;;
    [APP_MODEL saveToDisk];
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
