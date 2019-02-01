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

static NSString *CellIdentifier = @"RCDBaseSettingTableViewCell";

@interface GroupInfoViewController ()<UITableViewDelegate,UITableViewDataSource>{
    UITableView *_tableView;
    GroupNet *_model;
    GroupHeadView *_headView;
    BOOL enableNotification;
    RCConversation *currentConversation;
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
    [self getGroupUsersData];
    [self initLayout];

}

#pragma mark ----- Data
- (void)initData {
    _model = [GroupNet new];
    
}

- (void)update{
    CDWeakSelf(self);
    _headView = [GroupHeadView headViewWithModel:_model];
    _headView.click = ^(NSInteger index) {
        CDStrongSelf(self);
        [self gotoAllGroupUsers];
    };
    _tableView.tableHeaderView = _headView;
    
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
//    UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"提示" message:@"是否退出该群？" preferredStyle:UIAlertControllerStyleAlert];
//    UIAlertAction *cancle = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//
//    }];
//    [vc addAction:cancle];
//    UIAlertAction *make = [UIAlertAction actionWithTitle:@"退出" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//    }];
//    [vc addAction:make];
//    [self presentViewController:vc animated:YES completion:nil];
}



/**
 退出群组请求  退群
 */
- (void)action_exitGroup {

    BADataEntity *entity = [BADataEntity new];
    entity.urlString = [NSString stringWithFormat:@"%@%@/%@",APP_MODEL.serverUrl,@"social/skChatGroup/quit", _groupInfo.groupId];
    
    entity.needCache = NO;
    
    __weak __typeof(self)weakSelf = self;
    [BANetManager ba_request_GETWithEntity:entity successBlock:^(id response) {
         __strong __typeof(weakSelf)strongSelf = weakSelf;
        NSLog(@"get 请求数据结果： *** %@", response);
        if ([[response objectForKey:@"code"] integerValue] == 0) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadMyMessageGroupList" object:nil];
            SVP_ERROR_STATUS([response objectForKey:@"msg"]);
            
            [strongSelf.navigationController popToViewController:[strongSelf.navigationController.viewControllers objectAtIndex:0] animated:YES];
            
        } else {
            SVP_ERROR_STATUS([response objectForKey:@"msg"]);
        }
    } failureBlock:^(NSError *error) {
        [FUNCTION_MANAGER handleFailResponse:error];
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
    UIButton *exitBtn = [UIButton new];
    [footView addSubview:exitBtn];
    exitBtn.layer.cornerRadius = 8;
    exitBtn.layer.masksToBounds = YES;
    exitBtn.backgroundColor = MBTNColor;
    exitBtn.titleLabel.font = [UIFont boldSystemFontOfSize2:17];
    [exitBtn setTitle:@"删除并退出" forState:UIControlStateNormal];
    [exitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [exitBtn addTarget:self action:@selector(exit_group) forControlEvents:UIControlEventTouchUpInside];
    
    [exitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(footView.mas_left).offset(30);
        make.right.mas_equalTo(footView.mas_right).offset(-30);
        make.centerY.mas_equalTo(footView.mas_centerY);
        make.height.mas_equalTo(@(44));
    }];
    
    _tableView.tableFooterView = footView;
    
}

#pragma mark - 获取群成员
- (void)getGroupUsersData {

    __weak __typeof(self)weakSelf = self;
    [_model queryGroupUserGroupId:_groupInfo.groupId successBlock:^(NSDictionary *info) {
         __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf update];
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
    return (section == 0)?3:1;
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
                label.font = [UIFont systemFontOfSize2:16];
                label.text = @"群聊名称";
                label.textColor = Color_0;
                cell.accessoryType = 0;
                [label mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(cell.contentView).offset(15);
                    make.height.equalTo(@(48));
                    make.top.bottom.equalTo(cell.contentView);
                }];
                
                UILabel *value = [UILabel new];
                [cell.contentView addSubview:value];
                value.textColor = Color_6;
                value.text = _groupInfo.chatgName;
                value.font = [UIFont systemFontOfSize2:13];
                [value mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.right.equalTo(cell.contentView.mas_right).offset(-15);
                    make.centerY.equalTo(cell.contentView);
                }];
            } else if (indexPath.row == 1){
                UILabel *label = [UILabel new];
                [cell.contentView addSubview:label];
                label.font = [UIFont systemFontOfSize2:16];
                label.text = @"群公告";
                label.textColor = Color_0;
                
                [label mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(cell.contentView).offset(15);
                    make.top.bottom.equalTo(cell.contentView);
                }];
                
                UILabel *right = [UILabel new];
                [cell.contentView addSubview:right];
                right.font = [UIFont systemFontOfSize2:14];
                right.text = _groupInfo.notice;
                right.textColor = Color_6;
                right.numberOfLines = 0;
                
                [right mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.right.equalTo(cell.contentView.mas_right).offset(-15);
                    make.top.equalTo(cell.contentView.mas_top).offset(16);
                    make.bottom.equalTo(cell.contentView.mas_bottom).offset(-16);
                    make.left.greaterThanOrEqualTo(label.mas_right).offset(20);
                }];
            } else if (indexPath.row == 2){
                UILabel *label = [UILabel new];
                [cell.contentView addSubview:label];
                label.font = [UIFont systemFontOfSize2:16];
                label.text = @"须知";
                label.textColor = Color_0;
                
                [label mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerY.equalTo(cell.contentView);
                    make.left.equalTo(cell.contentView).offset(15);
                }];
                
                UILabel *bot = [UILabel new];
                [cell.contentView addSubview:bot];
                bot.font = [UIFont systemFontOfSize2:14];
                bot.text = _groupInfo.know;
                bot.textColor = Color_6;
                bot.numberOfLines = 0;
                
                [bot mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.right.equalTo(cell.contentView.mas_right).offset(-15);
                    make.centerY.equalTo(label.mas_centerY);
                }];
            }
            
//            else if (indexPath.row == 3){
//                UILabel *label = [UILabel new];
//                [cell.contentView addSubview:label];
//                label.font = [UIFont systemFontOfSize2:16];
//                label.text = @"规则";
//                label.textColor = Color_0;
//
//                [label mas_makeConstraints:^(MASConstraintMaker *make) {
//                    make.left.equalTo(cell.contentView).offset(15);
//                    make.centerY.equalTo(cell.contentView);
//                }];
//
//                UILabel *bot = [UILabel new];
//                [cell.contentView addSubview:bot];
//                bot.font = [UIFont systemFontOfSize2:13];
//                bot.text = _groupInfo.rule;
//                bot.textColor = Color_6;
//                bot.numberOfLines = 0;
//
//                [bot mas_makeConstraints:^(MASConstraintMaker *make) {
//                    make.right.equalTo(cell.contentView.mas_right).offset(-15);
//                    make.centerY.equalTo(label.mas_centerY);
//                }];
//            }
        } else if (indexPath.section == 1) {

            switch (indexPath.row) {
                case 0: {
                    [cellee setCellStyle:SwitchStyle];
                    cellee.leftLabel.text = @"消息免打扰";
                    cellee.switchButton.hidden = NO;
 
                    NSString *switchKeyStr = [NSString stringWithFormat:@"%@-%@", APP_MODEL.user.userId,_groupInfo.groupId];
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

#pragma mark - gotoAllGroupUsers
- (void)gotoAllGroupUsers{
    AllUserViewController *vc = [AllUserViewController allUser:_model];
    vc.groupId = self.groupInfo.groupId;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)clickNotificationBtn:(id)sender {
    UISwitch *swch = sender;
    NSString *switchKeyStr = [NSString stringWithFormat:@"%@-%@", APP_MODEL.user.userId,_groupInfo.groupId];
    //保存
    [[NSUserDefaults standardUserDefaults] setBool:swch.on forKey:switchKeyStr];
    
    [[RCIMClient sharedRCIMClient] setConversationNotificationStatus:ConversationType_GROUP
                                                            targetId:APP_MODEL.user.userId
                                                           isBlocked:swch.on
                                                             success:^(RCConversationNotificationStatus nStatus) {
                                                                 NSLog(@"111");
                                                             }
                                                               error:^(RCErrorCode status){
                                                                   NSLog(@"111");
                                                               }];
}

@end
