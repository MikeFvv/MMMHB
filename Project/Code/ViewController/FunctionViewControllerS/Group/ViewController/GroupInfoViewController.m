//
//  GroupInfoViewController.m
//  Project
//
//  Created by mini on 2018/8/9.
//  Copyright © 2018年 CDJay. All rights reserved.
//

#import "GroupInfoViewController.h"
#import "MessageItem.h"
#import "GroupNet.h"
#import "GroupHeadView.h"
#import "AllUserViewController.h"

@interface GroupInfoViewController ()<UITableViewDelegate,UITableViewDataSource>{
    UITableView *_tableView;
    GroupNet *_model;
    GroupHeadView *_headView;
}

@property (nonatomic, strong) MessageItem *groupInfo;
@end


@implementation GroupInfoViewController

+ (GroupInfoViewController *)groupVc:(id)obj{
    GroupInfoViewController *vc = [[GroupInfoViewController alloc]init];
    vc.groupInfo = obj;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self initSubviews];
    [self initLayout];
}

#pragma mark ----- Data
- (void)initData{
    _model = [GroupNet new];
}

- (void)update{
    CDWeakSelf(self);
    _headView = [GroupHeadView headViewWithList:_model.dataList];
    [_headView setTotalNum:_model.total];
    _headView.click = ^(NSInteger index) {
        CDStrongSelf(self);
        [self action_allUser];
    };
    _tableView.tableHeaderView = _headView;
}


#pragma mark ----- Layout
- (void)initLayout{
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

#pragma mark ----- subView
- (void)initSubviews{
    
    self.view.backgroundColor = BaseColor;
    self.navigationItem.title = @"群信息";
    
    _tableView = [UITableView groupTable];
    [self.view addSubview:_tableView];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.estimatedRowHeight = 60;
    _tableView.rowHeight = UITableViewAutomaticDimension;
    _tableView.sectionFooterHeight = 8.0f;
    
    WEAK_OBJ(weakSelf, self);
    _model.groupId = _groupInfo.groupId;
    [_model getUserListWithSuccess:^(NSDictionary * info) {
        [weakSelf update];
    } failure:^(id error) {
        [FUNCTION_MANAGER handleFailResponse:error];
    }];
//    [_model queryUserObj:@{@"groupId":_groupInfo.groupId} Success:^(NSDictionary *info) {
//        CDStrongSelf(self);
//        [self update];
//    } Failure:^(NSError *error) {
//        SV_ERROR(error);
//    }];
}

#pragma mark UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 8;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return (section == 0)?4:1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"group"];
    if(cell == nil){
        cell = [[UITableViewCell alloc]initWithStyle:0 reuseIdentifier:@"group"];
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
                
                UILabel *label = [UILabel new];
                [cell.contentView addSubview:label];
                label.font = [UIFont scaleFont:14];
                label.text = @"群聊名称";
                label.textColor = Color_3;
                cell.accessoryType = 1;
                [label mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(cell.contentView).offset(15);
                    make.height.equalTo(@(48));
                    make.top.bottom.equalTo(cell.contentView);
                }];
                
                UILabel *value = [UILabel new];
                [cell.contentView addSubview:value];
                value.textColor = Color_6;
                value.text = _groupInfo.groupName;
                value.font = [UIFont scaleFont:13];
                [value mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.right.equalTo(cell.contentView.mas_right).offset(-8);
                    make.centerY.equalTo(cell.contentView);
                }];
            }
            else if (indexPath.row == 1){
                UILabel *label = [UILabel new];
                [cell.contentView addSubview:label];
                label.font = [UIFont scaleFont:14];
                label.text = @"群二维码";
                label.textColor = Color_3;
                
                [label mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(cell.contentView).offset(15);
                    make.height.equalTo(@(48));
                    make.top.bottom.equalTo(cell.contentView);
                }];
                
                UIImageView *img = [UIImageView new];
                [cell.contentView addSubview:img];
                img.image = CD_QrImg(_groupInfo.ewm, 20);
                
                [img mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.right.equalTo(cell.contentView.mas_right).offset(-15);
                    make.width.height.equalTo(@(20));
                    make.centerY.equalTo(cell.contentView);
                }];
            }
            else if (indexPath.row == 2){
                UILabel *label = [UILabel new];
                [cell.contentView addSubview:label];
                label.font = [UIFont scaleFont:14];
                label.text = @"群公告";
                label.textColor = Color_3;
                
                [label mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(cell.contentView).offset(15);
                    make.top.bottom.equalTo(cell.contentView);
                }];
                
                UILabel *right = [UILabel new];
                [cell.contentView addSubview:right];
                right.font = [UIFont scaleFont:13];
                right.text = _groupInfo.notice;
                right.textColor = Color_6;
                right.numberOfLines = 0;
                
                [right mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.right.equalTo(cell.contentView.mas_right).offset(-15);
                    make.top.equalTo(cell.contentView.mas_top).offset(16);
                    make.bottom.equalTo(cell.contentView.mas_bottom).offset(-16);
                    make.left.greaterThanOrEqualTo(label.mas_right).offset(20);
                }];
            }
            else if (indexPath.row == 3){
                UILabel *label = [UILabel new];
                [cell.contentView addSubview:label];
                label.font = [UIFont scaleFont:14];
                label.text = @"须知";
                label.textColor = Color_3;
                
                [label mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(cell.contentView).offset(13);
                    make.left.equalTo(cell.contentView).offset(15);
                }];
                
                UILabel *bot = [UILabel new];
                [cell.contentView addSubview:bot];
                bot.font = [UIFont scaleFont:13];
                bot.text = _groupInfo.know;
                bot.textColor = Color_6;
                bot.numberOfLines = 0;
                
                [bot mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.right.equalTo(cell.contentView.mas_right).offset(-15);
                    make.top.equalTo(label.mas_bottom).offset(7);
                    make.bottom.equalTo(cell.contentView.mas_bottom).offset(-13);
                    make.left.equalTo(cell.contentView.mas_left).offset(15);
                }];
            }
            
        }
        else if (indexPath.section == 1){
            
            UILabel *label = [UILabel new];
            [cell.contentView addSubview:label];
            label.font = [UIFont scaleFont:14];
            label.text = @"规则";
            label.textColor = Color_3;
            
            [label mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(cell.contentView).offset(13);
                make.left.equalTo(cell.contentView).offset(15);
            }];
            
            UILabel *bot = [UILabel new];
            [cell.contentView addSubview:bot];
            bot.font = [UIFont scaleFont:13];
            bot.text = _groupInfo.rule;
            bot.textColor = Color_6;
            bot.numberOfLines = 0;
            
            [bot mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(cell.contentView.mas_right).offset(-15);
                make.top.equalTo(label.mas_bottom).offset(7);
                make.bottom.equalTo(cell.contentView.mas_bottom).offset(-13);
                make.left.equalTo(cell.contentView.mas_left).offset(15);
            }];
        }
        
    }
    return cell;
}

#pragma mark action
- (void)action_allUser{
    AllUserViewController *vc = [AllUserViewController allUser:_model];
    [self.navigationController pushViewController:vc animated:YES];
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
