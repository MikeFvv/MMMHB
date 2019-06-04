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
#import "BANetManager_OC.h"
#import "RCDBaseSettingTableViewCell.h"
#import "AddMemberController.h"
#import "NSString+Size.h"
#import "SqliteManage.h"
#import "ImageDetailViewController.h"

static NSString *CellIdentifier = @"RCDBaseSettingTableViewCell";

@interface GroupInfoViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) GroupNet *model;
@property (nonatomic, strong) GroupHeadView *headView;
@property (nonatomic, assign) BOOL enableNotification;
//@property (nonatomic, strong)  RCConversation *currentConversation;
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
//    [self initData];
    [self initSubviews];
//    [self getGroupUsersData];
    [self initLayout];

}

#pragma mark ----- Data
- (void)initData {
    _model = [GroupNet new];
    _model.groupNum = self.groupInfo.groupNum;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self initData];
    [self getGroupUsersData];
}

- (void)updateGroupUser {
    __weak __typeof(self)weakSelf = self;
    
    if ([self.groupInfo.userId isEqualToString:[AppModel shareInstance].userInfo.userId] ) {
        _headView = [GroupHeadView headViewWithModel:_model isGroupLord:YES];
    } else {
        _headView = [GroupHeadView headViewWithModel:_model isGroupLord:NO];
    }
    _headView.click = ^(NSInteger index) {
         __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        if (index - (strongSelf.model.dataList.count -1) == 1) {
            
            if ([strongSelf.groupInfo.userId isEqualToString:[AppModel shareInstance].userInfo.userId] ) {
                // 添加群员
                [strongSelf addGroupMember];
            }
            return;
        } else if (index - (strongSelf.model.dataList.count-1) == 2) {
            
            if ([strongSelf.groupInfo.userId isEqualToString:[AppModel shareInstance].userInfo.userId] ) {
                // 删减群员
                [strongSelf deleteGroupMember];
            }
            return;
        }
        
        [strongSelf gotoAllGroupUsers];
    };
    _tableView.tableHeaderView = _headView;
    
}

- (void)addGroupMember {
    AddMemberController *vc = [[AddMemberController alloc] init];
    vc.title = @"添加群成员";
    vc.groupId = self.groupInfo.groupId;
    [self.navigationController pushViewController:vc animated:YES];
}
    
    
- (void)deleteGroupMember {
    AllUserViewController *vc = [AllUserViewController allUser:_model];
    vc.title = @"删除成员";
    vc.groupId = self.groupInfo.groupId;
    vc.isDelete = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

/**
 退出群组确认
 */
-(void)exit_group {
    WEAK_OBJ(weakSelf, self);
     
    [[AlertViewCus createInstanceWithView:nil] showWithText:@"是否退出该群？" button1:@"取消" button2:@"退出" callBack:^(id object) {
        NSInteger tag = [object integerValue];
        if(tag == 1)
            [weakSelf action_exitGroup];
    }];
}

/**
 退出群组请求  退群
 */
- (void)action_exitGroup {

    SVP_SHOW;
    BADataEntity *entity = [BADataEntity new];
    entity.urlString = [NSString stringWithFormat:@"%@%@/%@",[AppModel shareInstance].serverUrl,@"social/skChatGroup/quit", _groupInfo.groupId];
    
    entity.needCache = NO;
    
    __weak __typeof(self)weakSelf = self;
    [BANetManager ba_request_GETWithEntity:entity successBlock:^(id response) {
         __strong __typeof(weakSelf)strongSelf = weakSelf;
        if ([response objectForKey:@"code"] && [[response objectForKey:@"code"] integerValue] == 0) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kReloadMyMessageGroupList object:nil];
            [SqliteManage removeGroupSql:strongSelf.groupInfo.groupId];
            SVP_ERROR_STATUS([response objectForKey:@"msg"]);
            
            [strongSelf.navigationController popToViewController:[strongSelf.navigationController.viewControllers objectAtIndex:0] animated:YES];
            
        } else {
            SVP_ERROR_STATUS([response objectForKey:@"msg"]);
        }
    } failureBlock:^(NSError *error) {
        if ([error.userInfo isKindOfClass:[NSDictionary class]]) {
            NSLog(@"%@", error.userInfo[@"NSErrorFailingURLKey"]);
            NSLog(@"%@", error.userInfo[@"NSLocalizedDescription"]);
        
            
            if ([error.userInfo[@"com.alamofire.serialization.response.error.response"] isKindOfClass:[NSHTTPURLResponse class]]) {
                NSHTTPURLResponse *http = (NSHTTPURLResponse *)error.userInfo[@"com.alamofire.serialization.response.error.response"];
                NSInteger code = http.statusCode;
                NSLog(@"%zd", code);
            }
        }
        [[FunctionManager sharedInstance] handleFailResponse:error];
    } progressBlock:nil];
}


#pragma mark - Layout
- (void)initLayout{
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.left.right.equalTo(self.view);

        if (@available(iOS 11.0, *)) {
            make.top.left.right.equalTo(self.view);
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
        } else {
            make.edges.equalTo(self.view);
        }
        
    }];
}

#pragma mark - subView
- (void)initSubviews{
    
    self.view.backgroundColor = BaseColor;
    self.navigationItem.title = @"群信息";
    
    _tableView = [UITableView groupTable];
    [self.view addSubview:_tableView];
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = BaseColor;
    _tableView.backgroundView = view;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.estimatedRowHeight = 60;
    _tableView.rowHeight = 50;
    _tableView.sectionFooterHeight = 8.0f;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.separatorColor = TBSeparaColor;
    
    
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 100)];
    
    UIButton *exitBtn = [[UIButton alloc] init];
    [footView addSubview:exitBtn];
    
    exitBtn.layer.cornerRadius = 8;
    exitBtn.layer.masksToBounds = YES;
    exitBtn.backgroundColor = MBTNColor;
    exitBtn.titleLabel.font = [UIFont boldSystemFontOfSize2:17];
    [exitBtn setTitle:@"删除并退出" forState:UIControlStateNormal];
    [exitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [exitBtn addTarget:self action:@selector(exit_group) forControlEvents:UIControlEventTouchUpInside];
    
    [exitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(footView.mas_centerY);
        make.centerX.equalTo(footView.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH -30*2, 44));
    }];
    
    _tableView.tableFooterView = footView;
    
}

#pragma mark - 获取群成员
- (void)getGroupUsersData {

    __weak __typeof(self)weakSelf = self;
    [_model queryGroupUserGroupId:_groupInfo.groupId successBlock:^(NSDictionary *info) {
         __strong __typeof(weakSelf)strongSelf = weakSelf;
        if ([info objectForKey:@"code"] && [[info objectForKey:@"code"] integerValue] == 0) {
            [strongSelf updateGroupUser];
        } else {
            SVP_ERROR_STATUS([info objectForKey:@"msg"]);
        }
    } failureBlock:^(NSError *error) {
        SVP_ERROR(error);
    }];
}


#pragma mark - UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 12;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = BaseColor;
    return view;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return (section == 0)?5:1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 1) {
        CGFloat height =  [_groupInfo.notice heightWithFont:[UIFont systemFontOfSize2:14] constrainedToWidth:SCREEN_WIDTH-(85+15)];
        return height + 15*2;
    } else if (indexPath.row == 2) {
        CGFloat height =  [_groupInfo.know heightWithFont:[UIFont systemFontOfSize2:14] constrainedToWidth:SCREEN_WIDTH-(85+15)];
        return height + 15*2;
    }
    return 48;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"group"];
    RCDBaseSettingTableViewCell *cellee = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cellee) {
        cellee = [[RCDBaseSettingTableViewCell alloc] init];
    }
    
    if(cell == nil){
        cell = [[UITableViewCell alloc]initWithStyle:0 reuseIdentifier:@"group"];
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
                
                UILabel *label = [UILabel new];
                [cell.contentView addSubview:label];
                label.font = [UIFont systemFontOfSize2:15];
                label.text = @"群名称";
                label.textColor = Color_0;
                cell.accessoryType = 0;
                [label mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(cell.contentView).offset(15);
//                    make.height.equalTo(@(48));
                    make.top.bottom.equalTo(cell.contentView);
                }];
                
                UILabel *value = [UILabel new];
                [cell.contentView addSubview:value];
                value.textColor = Color_6;
                value.text = _groupInfo.chatgName;
                value.font = [UIFont systemFontOfSize2:15];
                [value mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.right.equalTo(cell.contentView.mas_right).offset(-15);
                    make.centerY.equalTo(cell.contentView);
                }];
            } else if (indexPath.row == 1){
                UILabel *label = [UILabel new];
                [cell.contentView addSubview:label];
                label.font = [UIFont systemFontOfSize2:15];
                label.text = @"群公告";
                label.textColor = Color_0;
                
                [label mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(cell.contentView).offset(15);
                    make.top.bottom.equalTo(cell.contentView);
                }];
                
                UILabel *right = [UILabel new];
                [cell.contentView addSubview:right];
                right.font = [UIFont systemFontOfSize2:15];
                right.text = _groupInfo.notice;
                right.textColor = Color_6;
                right.textAlignment = NSTextAlignmentRight;
                right.numberOfLines = 0;
                CGFloat height =  [_groupInfo.notice heightWithFont:[UIFont systemFontOfSize2:15] constrainedToWidth:SCREEN_WIDTH-(85+15)];
                if (height > 20) {
                    right.textAlignment = NSTextAlignmentLeft;
                } else {
                    right.textAlignment = NSTextAlignmentRight;
                }
                
                [right mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.right.equalTo(cell.contentView.mas_right).offset(-15);
                    make.left.equalTo(cell.contentView.mas_left).offset(85);
                    make.centerY.equalTo(label.mas_centerY);
                }];
            } else if (indexPath.row == 2){
                UILabel *label = [UILabel new];
                [cell.contentView addSubview:label];
                label.font = [UIFont systemFontOfSize2:15];
                label.text = @"须知";
                label.textColor = Color_0;
                
                [label mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerY.equalTo(cell.contentView);
                    make.left.equalTo(cell.contentView).offset(15);
                }];
                
                UILabel *bot = [UILabel new];
                [cell.contentView addSubview:bot];
                bot.font = [UIFont systemFontOfSize2:15];
                bot.text = _groupInfo.know;
                bot.numberOfLines = 0;
                
                CGFloat height =  [_groupInfo.know heightWithFont:[UIFont systemFontOfSize2:15] constrainedToWidth:SCREEN_WIDTH-(85+15)];
                if (height > 20) {
                    bot.textAlignment = NSTextAlignmentLeft;
                } else {
                    bot.textAlignment = NSTextAlignmentRight;
                }
                bot.textColor = Color_6;

                [bot mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.right.equalTo(cell.contentView.mas_right).offset(-15);
                    make.left.equalTo(cell.contentView.mas_left).offset(85);
                    make.centerY.equalTo(label.mas_centerY);
                }];
            }
            
            else if (indexPath.row == 3 || indexPath.row == 4){
                UILabel *label = [UILabel new];
                [cell.contentView addSubview:label];
                label.font = [UIFont systemFontOfSize2:16];
                if(indexPath.row == 3)
                    label.text = @"群规";
                else
                    label.text = @"玩法";
                label.textColor = Color_0;

                [label mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(cell.contentView).offset(15);
                    make.centerY.equalTo(cell.contentView);
                }];
                
                UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fangdajing"]];
                [cell.contentView addSubview:imgView];
                [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.width.height.equalTo(@18);
                    make.right.equalTo(cell.contentView.mas_right).offset(-17);
                    make.centerY.equalTo(cell.contentView.mas_centerY);
                }];
                
                UILabel *right = [UILabel new];
                [cell.contentView addSubview:right];
                right.font = [UIFont systemFontOfSize2:15];
                if(indexPath.row == 3)
                    right.text = self.groupInfo.rule;
                else if(indexPath.row == 4)
                    right.text = self.groupInfo.howplay;
                right.textColor = Color_6;
                right.textAlignment = NSTextAlignmentRight;
                
                [right mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.right.equalTo(cell.contentView.mas_right).offset(-40);
                    make.left.equalTo(cell.contentView.mas_left).offset(85);
                    make.centerY.equalTo(label.mas_centerY);
                }];
            }
        } else if (indexPath.section == 1) {

            switch (indexPath.row) {
                case 0: {
                    [cellee setCellStyle:SwitchStyle];
                    cellee.leftLabel.text = @"消息免打扰";
                    cellee.leftLabel.font = [UIFont systemFontOfSize2:15];
                    cellee.switchButton.hidden = NO;
 
                    NSString *switchKeyStr = [NSString stringWithFormat:@"%@-%@", [AppModel shareInstance].userInfo.userId,_groupInfo.groupId];
                    // 读取
                    BOOL isSwitch = [[NSUserDefaults standardUserDefaults] boolForKey:switchKeyStr];
                    
                    cellee.switchButton.on = isSwitch;
                    
                    [cellee.switchButton addTarget:self
                                            action:@selector(clickNotificationBtn:)
                                  forControlEvents:UIControlEventValueChanged];
                }
                    break;
                    
                default:
                    break;
            }
            return cellee;
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0 && (indexPath.row == 3 || indexPath.row == 4)){
        NSString *url = nil;
        if(indexPath.row == 3)
            url = self.groupInfo.ruleImg;
        else if(indexPath.row == 4)
            url = self.groupInfo.howplayImg;
        ImageDetailViewController *vc = [[ImageDetailViewController alloc] init];
        vc.imageUrl = url;
        vc.hiddenNavBar = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - gotoAllGroupUsers
- (void)gotoAllGroupUsers {
    AllUserViewController *vc = [AllUserViewController allUser:_model];
    vc.title = @"所有成员";
    vc.groupId = self.groupInfo.groupId;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)clickNotificationBtn:(id)sender {
    UISwitch *swch = sender;
    NSString *switchKeyStr = [NSString stringWithFormat:@"%@-%@", [AppModel shareInstance].userInfo.userId,_groupInfo.groupId];
    //保存
    [[NSUserDefaults standardUserDefaults] setBool:swch.on forKey:switchKeyStr];
}

@end
