//
//  NoRobSendRPController.m
//  Project
//
//  Created by Mike on 2019/3/2.
//  Copyright © 2019 CDJay. All rights reserved.
//

#import "NoRobSendRPController.h"
#import "ChatViewController.h"
#import "EnvelopeMessage.h"
#import "EnvelopeNet.h"
#import "MessageItem.h"
#import "NetRequestManager.h"
#import "BANetManager_OC.h"
#import "GroupRuleModel.h"
#import "NSString+RegexCategory.h"
#import "RongCloudManager.h"
#import "NotificationMessageModel.h"
#import "SendRedPackedSelectNumCell.h"
#import "SendRedPackedTextCell.h"
#import "SendRPNumTableViewCell.h"


@interface NoRobSendRPController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>

@property (nonatomic ,strong) UITableView *tableView;
@property (nonatomic ,strong) NSArray *rowList;
@property (nonatomic ,strong) UILabel *moneyLabel;
@property (nonatomic ,strong) UIButton *submit;
@property (nonatomic ,strong) MessageItem *message;
//@property (nonatomic ,strong) UILabel *promptLabel;
@property (nonatomic ,assign) NSInteger textFieldObjectIndex;

@property (nonatomic ,strong) NSMutableArray *selectNumArray;
// 红包个数
@property (nonatomic ,strong) NSString *redpbNum;
// NO 禁抢   YES 不中
@property (nonatomic ,assign) BOOL isNotPlaying;
// 总金额
@property (nonatomic ,strong) NSString *totalMoney;


@end

@implementation NoRobSendRPController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    self.isNotPlaying = NO;
    
    [self initSubviews];
    [self initLayout];
    [self initNotif];
    
    self.selectNumArray = [[NSMutableArray alloc] init];
    
    [self.tableView registerClass:[SendRedPackedSelectNumCell class] forCellReuseIdentifier:@"SendRedPackedSelectNumCell"];
    
    [self.tableView registerClass:[SendRedPackedTextCell class] forCellReuseIdentifier:@"SendRedPackedTextCell"];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
#pragma mark ----- Data
- (void)initData {
    NSLog(@"%@",self.CDParam);
    _message = (MessageItem *)self.CDParam;
 
    if (self.isFu) {
        _rowList = @[
                     @[
                         @{@"title":@"总金额",@"right":@"元",@"placeholder":[NSString stringWithFormat:@"%@-%@",self.message.simpMinMoney,self.message.simpMaxMoney]},
                         @{@"title":@"红包个数",@"right":@"个",@"placeholder":@"填写红包个数"}] ];
        return;
    }
    if (_message.type == 3) { // 禁抢
        
        _rowList = @[
                     @[
                         @{@"title":@"",@"right":@""},
                         @{@"title":@"总金额",@"right":@"元",@"placeholder":[NSString stringWithFormat:@"%@-%@",self.message.minMoney,self.message.maxMoney]},
                         @{@"title":@"红包个数",@"right":@"包"},
                         @{@"title":@"雷  号",@"":@""}],
                     ];
    }
}



#pragma mark ----- Layout
- (void)initLayout{
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)initNotif {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textFieldDidChangeValue:)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:nil];
}



#pragma mark ----- subView
- (void)initSubviews {
    
    self.view.backgroundColor = BaseColor;
    self.navigationItem.title = @"发红包";
    
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 30)];
    btn.titleLabel.font = [UIFont boldSystemFontOfSize2:15];
    [btn addTarget:self action:@selector(action_cancle) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitle:@"取消" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    UIBarButtonItem *l = [[UIBarButtonItem alloc]initWithCustomView:btn];
    self.navigationItem.leftBarButtonItem = l;
    
    _tableView = [UITableView groupTable];
    [self.view addSubview:_tableView];
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = BaseColor;
    
    UIView *tableBackView = [[UIView alloc] init];
    tableBackView.backgroundColor = [UIColor colorWithRed:0.882 green:0.882 blue:0.882 alpha:1.000];
    
    
    UIImageView *backImageView = [[UIImageView alloc] init];
    backImageView.image = [UIImage imageNamed:@"send_redpack_back"];
    [tableBackView addSubview:backImageView];
    
    [backImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(tableBackView);
    }];
    
    
    //    [_tableView setBackgroundView:tableBackView];
    _tableView.backgroundView = tableBackView;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.scrollEnabled =NO;  // 设置tableview 不能滚动
    //    _tableView.separatorInset = UIEdgeInsetsMake(0, 20, 0, 0);
    //    _tableView.separatorColor = TBSeparaColor;
    _tableView.rowHeight = 60;
    //    _tableView.contentInset = UIEdgeInsetsMake(30, 0, 20, -50);
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;//推荐该方法
    
    UIView *fotView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CDScreenWidth, 500)];
    _tableView.tableFooterView = fotView;
    //    fotView.backgroundColor = [UIColor greenColor];
    
    _moneyLabel = [UILabel new];
    [fotView addSubview:_moneyLabel];
    _moneyLabel.font = [UIFont systemFontOfSize:43];
    _moneyLabel.textColor = [UIColor colorWithRed:0.996 green:0.596 blue:0.165 alpha:1.000];
    _moneyLabel.text = @"￥0";
    //    _moneyLabel.backgroundColor = [UIColor blueColor];
    
    [_moneyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(fotView);
        make.top.equalTo(fotView.mas_top).offset(10);
    }];
    
    
    _submit = [UIButton new];
    _submit.layer.cornerRadius = 8;
    _submit.titleLabel.font = [UIFont boldSystemFontOfSize2:18];
    _submit.layer.masksToBounds = YES;
    //    _submit.backgroundColor = MBTNColor;
    //    [_submit setTitle:@"塞钱进红包" forState:UIControlStateNormal];
    [_submit setBackgroundImage:[UIImage imageNamed:@"send_btn"] forState:UIControlStateNormal];
    //    [_submit setBackgroundImage:[UIImage imageNamed:@"send_btn_dis"] forState:UIControlStateHighlighted];
    
//    [_submit setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_submit addTarget:self action:@selector(action_sendRedpacked) forControlEvents:UIControlEventTouchUpInside];
    [fotView addSubview:_submit];
    [_submit delayEnable];
    
    
    CGFloat submitWidth = CDScreenWidth/3;
    CGFloat bottomHeight = CDScreenHeight/2/2;
    [_submit mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(@(submitWidth+20));
        make.centerY.mas_equalTo(self.tableView.mas_centerY).multipliedBy(1.25);
        make.centerX.mas_equalTo(fotView.mas_centerX);
    }];
    //    _submit.alpha = 0.5;
    
    UILabel *bot = [UILabel new];
    [fotView addSubview:bot];
    bot.font = [UIFont systemFontOfSize2:12];
    bot.textColor = COLOR_X(140, 140, 140);
    
    if (_message.type == 2) {
        bot.text = kMessCowRefundMessage;
    } else if (_message.type == 1 || _message.type == 0) {
        bot.text = [NSString stringWithFormat:@"未领取的红包，将于%0.f分钟后发起退款", [self.message.rpOverdueTime floatValue]/60 <= 1 ? 1 : [self.message.rpOverdueTime floatValue]/60];
    } else if (_message.type == 3) {
        bot.text = @"";
    }
    
    [bot mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self -> _submit);
        make.top.equalTo(self ->_submit.mas_bottom).offset(9);
    }];
}



#pragma mark UITableViewDelegate,UITableViewDataSource

//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
//    return 35;
//}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *list = _rowList[section];
    return list.count;
}

// 设置Cell行高
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
        } else if (indexPath.row == 3) {
            return CD_Scal(120, 812);
        }
    }
    return CD_Scal(60, 812);
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSDictionary *messDict = [_message.attr mj_JSONObject];
    NSDictionary *dict1 = [messDict objectForKey:@"1"];  // 禁抢红包
    NSDictionary *dict2 = [messDict objectForKey:@"2"];  // 不中
    NSArray *noPlayArray = [dict2 allKeys];
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            UITableViewCell *cell = [[UITableViewCell alloc] init];
            cell.backgroundColor = [UIColor clearColor];
            return cell;
        } else if (indexPath.row == 2) {
            SendRPNumTableViewCell *cell = [SendRPNumTableViewCell cellWithTableView:tableView reusableId:@"SendRPNumTableViewCell"];

            NSMutableArray *dataArray = [NSMutableArray arrayWithArray:[dict1 allKeys]];

            for (NSInteger i = 0; i < noPlayArray.count; i++) {
                if (![dataArray containsObject:noPlayArray[i]]) {
                    [dataArray addObject:noPlayArray[i]];
                }
            }
//            NSArray *dataArray = @[@"5",@"6",@"7",@"8",@"9"];  1  3
            cell.model = [[FunctionManager sharedInstance] orderBombArray: dataArray];
            cell.selectNumBlock = ^(NSArray *items) {
                NSIndexPath *indexPath = (NSIndexPath *)items.firstObject;
                // 不中玩法
//                for (NSInteger index = 0; index < noPlayArray.count; index++) {
//                    if (self.redpbNum.integerValue == [noPlayArray[index] integerValue] && [dataArray[indexPath.row] integerValue] != [noPlayArray[index] integerValue]) {
//                        //                    [self.tableView reloadData];
//                        self.redpbNum = dataArray[indexPath.row];
//                        NSIndexPath *indexPath=[NSIndexPath indexPathForRow:3 inSection:0];
//                        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
//                        return;
//                    } else if ([dataArray[indexPath.row] integerValue] == [noPlayArray[index] integerValue]) {
//                        self.redpbNum = dataArray[indexPath.row];
//                        NSIndexPath *indexPath=[NSIndexPath indexPathForRow:3 inSection:0];
//                        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
//                        return;
//                    }
//                }
                self.isNotPlaying = NO;
                self.redpbNum = [[FunctionManager sharedInstance] orderBombArray: dataArray][indexPath.row];
                NSIndexPath *ip=[NSIndexPath indexPathForRow:3 inSection:0];
                [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:ip,nil] withRowAnimation:UITableViewRowAnimationNone];

            };
            return cell;
        } else if (indexPath.row == 3) {
            SendRedPackedSelectNumCell *cell = [SendRedPackedSelectNumCell cellWithTableView:tableView reusableId:@"SendRedPackedSelectNumCell"];
            NSArray *dataArray = @[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"0"];
    
            NSDictionary *numDict;
            if (self.isNotPlaying) {
                numDict = dict2[[NSString stringWithFormat:@"%@",self.redpbNum]];
            } else {
                numDict = dict1[[NSString stringWithFormat:@"%@",self.redpbNum]];
            }
            cell.maxNum = [numDict[@"bombMax"] intValue];
            cell.model = dataArray;
            
            BOOL isNoPlay = NO;
             for (NSInteger index = 0; index < noPlayArray.count; index++) {
                if (self.redpbNum.integerValue == [noPlayArray[index] integerValue]) {
                    isNoPlay = YES;
                }
            }
            
            cell.isBtnDisplay = isNoPlay;
            cell.selectNumBlock = ^(NSArray *items) {
                
                [self.selectNumArray removeAllObjects];
                for (NSInteger index = 0; index < items.count; index++) {
                    NSIndexPath *indexPath = (NSIndexPath *)items[index];
                    NSString *num = dataArray[indexPath.row];
                    [self.selectNumArray addObject:num];
                }
                NSLog(@"%@", self.selectNumArray);
            };
            cell.selectBtnBlock = ^(BOOL isSelect) {
                self.isNotPlaying =  isSelect;
            };
            return cell;
        }
    }
    
    SendRedPackedTextCell *cell = [SendRedPackedTextCell cellWithTableView:tableView reusableId:@"SendRedPackedTextCell"];
    //    cell.backgroundColor = [UIColor blueColor];
    cell.deTextField.placeholder = [NSString stringWithFormat:@"%ld-%ld", [self.message.minMoney integerValue], [self.message.maxMoney integerValue]];
    cell.titleLabel.text = @"总金额";
    cell.unitLabel.text = @"元";
    
    cell.object = self;
    return cell;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _rowList.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.1f;
}

#pragma mark action
- (void)action_cancle {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"scrollToBottom" object:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark action
- (void)doneSend:(EnvelopeMessage *)message{
    [self dismissViewControllerAnimated:YES completion:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [ChatViewController sendCustomMessage:message];
    });
}


#pragma mark - 红包金额验证
- (BOOL)moneyCheck:(CGFloat)money {
    
    NSInteger max = 0;
    NSInteger min = 0;
    if (self.isFu) {
        max = [self.message.simpMaxMoney integerValue];
        min = [self.message.simpMinMoney integerValue];
    } else {
        max = [self.message.maxMoney integerValue];
        min = [self.message.minMoney integerValue];
    }
    
    if ((money > max) | (money < min)) {
        if (self.isFu) {
            NSString *str = [NSString stringWithFormat:@"红包发包范围:%@-%@", self.message.simpMinMoney,self.message.simpMaxMoney];
            SVP_ERROR_STATUS(str);
        } else {
            NSString *str = [NSString stringWithFormat:@"红包发包范围:%@-%@", self.message.minMoney,self.message.maxMoney];
            SVP_ERROR_STATUS(str);
        }
        
        return NO;
    } else {
        return YES;
    }
}



#pragma mark - 发红包
- (void)action_sendRedpacked {

    NSString * regex        = @"(^[0-9]{0,15}$)";
    NSPredicate * pred      = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    
    if (self.totalMoney.length == 0) {
        SVP_ERROR_STATUS(@"请输入总金额");
        return;
    }
    
    if (![self moneyCheck:self.totalMoney.floatValue]) {
        return;
    }
    
    if (self.redpbNum.length == 0) {
        SVP_ERROR_STATUS(@"请选择包数");
        return;
    }
    
    if(![pred evaluateWithObject:self.redpbNum]){
        SVP_ERROR_STATUS(@"红包个数请输入整数");
        return;
    }
    
    if(![pred evaluateWithObject:self.totalMoney]){
        SVP_ERROR_STATUS(@"金额请输入整数");
        return;
    }
    
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    if (!self.isFu && _message.type == 3) {  // 禁抢
        if (self.selectNumArray.count == 0) {
            SVP_ERROR_STATUS(@"选择雷号");
            return;
        }
        
        NSDictionary *messDict = [_message.attr mj_JSONObject];
        NSDictionary *dict1 = [messDict objectForKey:@"1"];  // 禁抢红包
        NSDictionary *dict2 = [messDict objectForKey:@"2"];  // 不中
        NSDictionary *numDict;
        if (self.isNotPlaying) {
            numDict = dict2[[NSString stringWithFormat:@"%@",self.redpbNum]];
        } else {
            numDict = dict1[[NSString stringWithFormat:@"%@",self.redpbNum]];
        }
        
        if (self.selectNumArray.count < [numDict[@"bombMin"] intValue]) {
            NSString *strMess = [NSString stringWithFormat:@"%@包多雷玩法最少%i雷", self.redpbNum, [numDict[@"bombMin"] intValue]];
            SVP_ERROR_STATUS(strMess);
            return;
        }
        
        [dic setObject:self.isNotPlaying ? @"2" : @"1" forKey:@"type"];   // 游戏类型  2不中玩法
        self.selectNumArray = (NSMutableArray *)[FUNCTION_MANAGER orderBombArray:self.selectNumArray];
        [dic setObject:self.selectNumArray forKey:@"bombList"];  // 雷号列表
    }
    
    _submit.enabled = NO;
    [self redpackedRequest:self.totalMoney packetNum:self.redpbNum extDict:dic];
    
}

- (void)redpackedRequest:(NSString *)money packetNum:(NSString *)packetNum extDict:(NSDictionary *)extDict {
    
    if (![RongCloudManager shareInstance].isConnectRC) {
        
        NotificationMessageModel *model = [[NotificationMessageModel alloc] init];
        model.messagetype = 3;
        
        [[RCIM sharedRCIM] sendMessage:ConversationType_GROUP targetId:self.message.groupId content:model pushContent:nil pushData:nil success:^(long messageId) {
        } error:^(RCErrorCode nErrorCode, long messageId) {
        }];
        
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    
    
    NSDictionary *parameters = @{
                                 @"ext":extDict,
                                 @"groupId":self.message.groupId,
                                 @"userId":APP_MODEL.user.userId,
                                 @"type":self.isFu ? @(0) : @(_message.type),
                                 @"money":money,
                                 @"count":@(self.redpbNum.integerValue)
                                 };
    
    BADataEntity *entity = [BADataEntity new];
    entity.urlString = [NSString stringWithFormat:@"%@%@",APP_MODEL.serverUrl,@"social/redpacket/send"];
    
    entity.needCache = NO;
    entity.parameters = parameters;
    
    BANetManagerShare.isOpenLog = YES;
    
    SVP_SHOW;
    __weak __typeof(self)weakSelf = self;
    [BANetManager ba_request_POSTWithEntity:entity successBlock:^(id response) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        strongSelf.submit.enabled = YES;
        SVP_DISMISS;
        if ([response objectForKey:@"code"] != nil && [[response objectForKey:@"code"] integerValue] == 0) {
            [strongSelf action_cancle];
        } else if ([response objectForKey:@"code"] != nil){
            SVP_ERROR_STATUS([response objectForKey:@"msg"]);
        } else {
            if ([[response objectForKey:@"status"] integerValue] == 500) {
                SVP_ERROR_STATUS(@"服务器内部错误");
            } else {
                SVP_ERROR_STATUS(@"网络连接错误");
            }
        }
        
    } failureBlock:^(NSError *error) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        strongSelf.submit.enabled = YES;
        SVP_DISMISS;
        SVP_ERROR_STATUS(kSystemBusyMessage);
        //        [FUNCTION_MANAGER handleFailResponse:error];
    } progressBlock:nil];
}

#pragma mark -  输入字符判断
- (void)textFieldDidChangeValue:(NSNotification *)notiObject {
    
    UITextField *textFieldObj = (UITextField *)notiObject.object;
    NSInteger mObjectInte = [textFieldObj.text integerValue];
    _moneyLabel.text = [NSString stringWithFormat:@"￥%ld",mObjectInte];
    self.totalMoney = textFieldObj.text;
    
    BOOL money = [self money:mObjectInte];
    
    if ((self.isFu && money) || (!self.isFu && _message.type == 1 && money) || (!self.isFu && _message.type == 3 && money)) {
        //        _submit.enabled = YES;
        //        _submit.alpha = 1.0;
    }  else {
        //        _submit.enabled = NO;
        //        _submit.alpha = 0.5;
        
    }
    
}

- (BOOL)money:(CGFloat)money {
    
    NSInteger max = 0;
    NSInteger min = 0;
    if (self.isFu) {
        max = [self.message.simpMaxMoney integerValue];
        min = [self.message.simpMinMoney integerValue];
    } else {
        max = [self.message.maxMoney integerValue];
        min = [self.message.minMoney integerValue];
    }
    
    if ((money > max) | (money < min)) {
        return NO;
    } else {
        return YES;
    }
}

- (BOOL)count:(CGFloat)count {
    
    NSInteger max = 0;
    NSInteger min = 0;
    if (self.isFu) {
        max = [self.message.simpMaxCount integerValue];
        min = [self.message.simpMinCount integerValue];
    } else {
        max = [self.message.maxCount integerValue];
        min = [self.message.minCount integerValue];
    }
    
    if ((count > max) | (count < min)) {
        return NO;
    } else {
        return YES;
    }
}

- (BOOL)leiNum:(CGFloat)number {
    CGFloat max = 9;
    CGFloat min = 0;
    if ((number > max) | (number < min)) {
        return NO;
    } else {
        return YES;
    }
}


-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

