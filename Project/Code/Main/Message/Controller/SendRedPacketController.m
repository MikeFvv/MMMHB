//
//  EnvelopeViewController.m
//  Project
//
//  Created by mini on 2018/8/8.
//  Copyright © 2018年 CDJay. All rights reserved.
//

#import "SendRedPacketController.h"
#import "ChatViewController.h"
#import "EnvelopeMessage.h"
#import "EnvelopeNet.h"
#import "MessageItem.h"
#import "NetRequestManager.h"
#import "BANetManager_OC.h"
#import "GroupRuleModel.h"
#import "NSString+RegexCategory.h"

@interface SendRedPacketController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>{
    UITextField *_textField[3];
}

@property (nonatomic ,strong) UITableView *tableView;
@property (nonatomic ,strong) NSArray *rowList;
@property (nonatomic ,strong) UILabel *moneyLabel;
@property (nonatomic ,strong) UIButton *submit;
@property (nonatomic ,strong) MessageItem *message;
@property (nonatomic ,strong) UILabel *promptLabel;
@property (nonatomic ,assign) NSInteger textFieldObjectIndex;



@end

@implementation SendRedPacketController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self initSubviews];
    [self initLayout];
    [self initNotif];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_textField[0] becomeFirstResponder];
}
#pragma mark ----- Data
- (void)initData {
    NSLog(@"%@",self.CDParam);
    _message = (MessageItem *)self.CDParam;
    
    if (self.isFu) {
        _rowList = @[@[@{@"title":@"总金额",@"right":@"元",@"placeholder":[NSString stringWithFormat:@"%@-%@",self.message.simpMinMoney,self.message.simpMaxMoney]},@{@"title":@"红包个数",@"right":@"个",@"placeholder":@"填写红包个数"}]];
        return;
    }
    
    if (_message.type == 1) {
        _rowList = @[@[@{@"title":@"总金额",@"right":@"元",@"placeholder":[NSString stringWithFormat:@"%@-%@",self.message.minMoney,self.message.maxMoney]},@{@"title":@"红包个数",@"right":@"个",@"placeholder":@"填写红包个数"}],@[@{@"title":@"雷数",@"right":@"",@"placeholder":@"范围0-9"}]];
    } else if (_message.type == 2) {
        _rowList = @[@[@{@"title":@"总金额",@"right":@"元",@"placeholder":[NSString stringWithFormat:@"%@-%@",self.message.minMoney,self.message.maxMoney]},@{@"title":@"红包个数",@"right":@"个",@"placeholder":@"填写红包个数"}]];
    }
}



#pragma mark ----- Layout
- (void)initLayout{
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)initNotif{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textFieldDidChangeValue:)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:nil];
}



#pragma mark ----- subView
- (void)initSubviews{
    
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
    _tableView.backgroundView = view;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.separatorInset = UIEdgeInsetsMake(0, 20, 0, 0);
    _tableView.separatorColor = TBSeparaColor;
    _tableView.rowHeight = 60;
    
    UIView *headView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CDScreenWidth, 100)];
    _tableView.tableHeaderView = headView;
    
    _moneyLabel = [UILabel new];
    [headView addSubview:_moneyLabel];
    _moneyLabel.font = [UIFont systemFontOfSize:40];
    _moneyLabel.textColor = Color_0;
    _moneyLabel.text = @"￥0";
    
    [_moneyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(headView);
        make.top.equalTo(headView.mas_top).offset(30);
    }];
    
    
    _promptLabel = [UILabel new];
    [headView addSubview:_promptLabel];
    _promptLabel.font = [UIFont systemFontOfSize:14];
    _promptLabel.textColor = [UIColor redColor];
    
    [_promptLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(headView);
        make.top.equalTo(self.moneyLabel.mas_bottom);
    }];
    
    
    
    UIView *fotView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CDScreenWidth, 100)];
    _tableView.tableFooterView = fotView;
    
    _submit = [UIButton new];
    [fotView addSubview:_submit];
    _submit.layer.cornerRadius = 8;
    _submit.titleLabel.font = [UIFont boldSystemFontOfSize2:18];
    _submit.layer.masksToBounds = YES;
    _submit.backgroundColor = MBTNColor;
    [_submit setTitle:@"塞钱进红包" forState:UIControlStateNormal];
    [_submit setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_submit addTarget:self action:@selector(action_sendRedpacked) forControlEvents:UIControlEventTouchUpInside];
    [_submit delayEnable];
    [_submit mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(16);
        make.right.equalTo(self.view.mas_right).offset(-16);
        make.height.equalTo(@(44));
        make.top.equalTo(fotView.mas_top).offset(7);
    }];
    _submit.alpha = 0.5;
    
    UILabel *bot = [UILabel new];
    [fotView addSubview:bot];
    bot.font = [UIFont systemFontOfSize2:12];
    bot.textColor = COLOR_X(140, 140, 140);
    
  
    bot.text = [NSString stringWithFormat:@"未领取的红包，将于%0.f分钟后发起退款", [self.message.rpOverdueTime floatValue]/60 <= 1 ? 1 : [self.message.rpOverdueTime floatValue]/60];
    
    [bot mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self -> _submit);
        make.top.equalTo(self ->_submit.mas_bottom).offset(9);
    }];
}

#pragma mark UITableViewDelegate,UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 35;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CDScreenWidth, 35)];
    UILabel *label = [UILabel new];
    [view addSubview:label];
    label.font = [UIFont systemFontOfSize2:13];
    label.textColor = COLOR_X(140, 140, 140);
    
    if (self.isFu) {
        label.text = [NSString stringWithFormat:@"红包发包范围: %@-%@元",self.message.simpMinMoney,self.message.simpMaxMoney];
    } else if (!self.isFu && _message.type == 1) {
        label.text = (section == 0)? [NSString stringWithFormat:@"红包发包范围: %@-%@元",self.message.minMoney,self.message.maxMoney]:@"雷数范围0-9";
    } else if (!self.isFu && _message.type == 2) {
        label.text = (section == 0)? [NSString stringWithFormat:@"红包发包范围: %@-%@元",self.message.minMoney,self.message.maxMoney]:[NSString stringWithFormat:@"红包个数: %@-%@元",self.message.minCount,self.message.maxCount];
    }
    
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view.mas_left).offset(20);
        make.centerY.equalTo(view);
    }];
    
    return view;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *list = _rowList[section];
    return list.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellId = [NSString stringWithFormat:@"cell%ld",indexPath.row];
    UITableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:0 reuseIdentifier:cellId];
        //        _textField[row].text = _rowList[indexPath.section][indexPath.row][@"title"];
        cell.textLabel.text = _rowList[indexPath.section][indexPath.row][@"title"];
        cell.textLabel.font = [UIFont systemFontOfSize2:16];
        cell.textLabel.textColor = Color_0;
        
        NSInteger row = indexPath.section *2 +indexPath.row;
        _textField[row] = [UITextField new];
        [cell.contentView addSubview:_textField[row]];
        
        _textField[row].placeholder = _rowList[indexPath.section][indexPath.row][@"placeholder"];
        _textField[row].font = [UIFont systemFontOfSize2:16];
        _textField[row].keyboardType = UIKeyboardTypeNumberPad;
        _textField[row].textAlignment = NSTextAlignmentRight;
        
        UILabel *unit = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 30, 25)];
        _textField[row].rightView = unit;
        _textField[row].rightViewMode = UITextFieldViewModeAlways;
        //        _textField[row].backgroundColor = [UIColor redColor];
        
        unit.font = [UIFont boldSystemFontOfSize2:16];
        unit.text = _rowList[indexPath.section][indexPath.row][@"right"];;
        unit.textAlignment = NSTextAlignmentRight;
        unit.textColor = Color_0;
        
        if(row == 1){
            if (self.isFu) {
                _textField[1].placeholder = [NSString stringWithFormat:@"%@-%@",self.message.simpMinCount,self.message.simpMaxCount];
                _textField[1].userInteractionEnabled = YES;
                cell.textLabel.textColor = Color_0;
                unit.textColor = Color_0;
            } else {
                if(_message.type == 1) {
                    _textField[1].text = [NSString stringWithFormat:@"%@",self.message.maxCount];
                    _textField[1].userInteractionEnabled = NO;
                    _textField[1].textColor = COLOR_X(140, 140, 140);
                    cell.textLabel.textColor = COLOR_X(140, 140, 140);
                    unit.textColor = COLOR_X(140, 140, 140);
                } else if(_message.type == 2) {
                    if (self.message.maxCount.integerValue == self.message.minCount.integerValue) {
                        _textField[1].text = [NSString stringWithFormat:@"%@",self.message.maxCount];
                        _textField[1].userInteractionEnabled = NO;
                        _textField[1].textColor = COLOR_X(140, 140, 140);
                        cell.textLabel.textColor = COLOR_X(140, 140, 140);
                        unit.textColor = COLOR_X(140, 140, 140);
                    } else {
                        _textField[1].placeholder = [NSString stringWithFormat:@"%@-%@",self.message.minCount,self.message.maxCount];
                        _textField[1].userInteractionEnabled = YES;
                        cell.textLabel.textColor = Color_0;
                        unit.textColor = Color_0;
                    }
                }
            }
        }
        if(_textField[row].userInteractionEnabled)
            _textField[row].delegate = self;
        [_textField[row] mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(cell.contentView.mas_right).offset(-15);
            make.top.bottom.equalTo(cell.contentView);
            make.left.equalTo(cell.contentView).offset(98);
        }];
    }
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

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = BaseColor;
    return view;
}



#pragma mark action
- (void)action_cancle {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark action
- (void)doneSend:(EnvelopeMessage *)message{
    [self dismissViewControllerAnimated:YES completion:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [ChatViewController sendCustomMessage:message];
    });
}



#pragma mark - 发红包
- (void)action_sendRedpacked {
    NSString *money = _textField[0].text;
    NSString *packetNum = _textField[1].text;
    NSString *bombNum = [_textField[2].text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    NSString * regex        = @"(^[0-9]{0,15}$)";
    NSPredicate * pred      = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    
    if (money.length == 0) {
        SVP_ERROR_STATUS(@"请输入总金额");
        return;
    }
    if (packetNum.length == 0) {
        SVP_ERROR_STATUS(@"请输入红包个数");
        return;
    }
    
    if(![pred evaluateWithObject:packetNum]){
        SVP_ERROR_STATUS(@"红包个数请输入整数");
        return;
    }
    
    if(![pred evaluateWithObject:money]){
        SVP_ERROR_STATUS(@"金额请输入整数");
        return;
    }
    
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    if (!self.isFu && _message.type == 1) {
        if (bombNum.length == 0) {
            SVP_ERROR_STATUS(@"请输入雷数");
            return;
        }
        if(![pred evaluateWithObject:bombNum]){
            SVP_ERROR_STATUS(@"雷数请输入整数");
            return;
        }
        [dic setObject:bombNum forKey:@"bombNum"];
    }
    
    
    [self redpackedRequest:money packetNum:packetNum extDict:dic];
    
}

- (void)redpackedRequest:(NSString *)money packetNum:(NSString *)packetNum extDict:(NSDictionary *)extDict {
    NSDictionary *parameters = @{
                                 @"ext":extDict,
                                 @"groupId":self.message.groupId,
                                 @"userId":APP_MODEL.user.userId,
                                 @"type":self.isFu ? @(0) : @(_message.type),
                                 @"money":money,
                                 @"count":@(packetNum.integerValue)
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
        SVP_DISMISS;
        if ([[response objectForKey:@"code"] integerValue] == 0) {
            [strongSelf action_cancle];
        } else {
            SVP_ERROR_STATUS([response objectForKey:@"msg"]);
        }
        
    } failureBlock:^(NSError *error) {
        SVP_DISMISS;
        SVP_ERROR_STATUS(kSystemBusyMessage);
        //        [FUNCTION_MANAGER handleFailResponse:error];
    } progressBlock:nil];
}


#pragma mark -  输入字符判断
- (void)textFieldDidChangeValue:(NSNotification *)text{
    
    self.textFieldObjectIndex = 0;
    if (_textField[0] == text.object) {
        self.textFieldObjectIndex = 0;
    } else if (_textField[1] == text.object) {
        self.textFieldObjectIndex = 1;
    } else if (_textField[2] == text.object) {
        self.textFieldObjectIndex = 2;
    }
    
    NSInteger m = [_textField[0].text integerValue];
    
    if (text.object == _textField[0]) {
        _moneyLabel.text = [NSString stringWithFormat:@"￥%ld",m];
    }
    BOOL money = [self money:m];
    
    NSInteger c = [_textField[1].text integerValue];
    BOOL count = [self count:c];
    
    //    BOOL lel = [[_textField[2].text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isSingleNumber];
    BOOL lel = [self leiNum:[_textField[2].text integerValue]];
    
    if ((self.isFu && money && count) || (_message.type == 1 && money && lel) || (_message.type == 2 && money && count)) {
        _submit.enabled = YES;
        _submit.alpha = 1.0;
        self.promptLabel.text = @"";
    }  else {
        _submit.enabled = NO;
        _submit.alpha = 0.5;
        
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
        if (self.textFieldObjectIndex == 0) {
            if (self.isFu) {
                self.promptLabel.text = [NSString stringWithFormat:@"红包发包范围:%@-%@", self.message.simpMinMoney,self.message.simpMaxMoney];
            } else {
                self.promptLabel.text = [NSString stringWithFormat:@"红包发包范围:%@-%@", self.message.minMoney,self.message.maxMoney];
            }
        }
        return NO;
    } else {
        if (self.textFieldObjectIndex == 0) {
            self.promptLabel.text = @"";
        }
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
        
        if (self.textFieldObjectIndex == 1) {
            if (self.isFu) {
                self.promptLabel.text = [NSString stringWithFormat:@"红包个数范围:%@-%@", self.message.simpMinCount,self.message.simpMaxCount];
            } else {
                self.promptLabel.text = [NSString stringWithFormat:@"红包个数范围:%@-%@", self.message.minCount,self.message.maxCount];
            }
        }
        return NO;
    } else {
        if (self.textFieldObjectIndex == 1) {
            self.promptLabel.text = @"";
        }
        return YES;
    }
}

- (BOOL)leiNum:(CGFloat)number {
    CGFloat max = 9;
    CGFloat min = 0;
    if ((number > max) | (number < min)) {
        if (self.textFieldObjectIndex == 2) {
            self.promptLabel.text = @"雷数范围:0-9";
        }
        return NO;
    } else {
        if (self.textFieldObjectIndex == 2) {
            self.promptLabel.text = @"";
        }
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

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    if(textField == _textField[0]){
        if(_textField[1].userInteractionEnabled)
            [_textField[1] performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0.5];
        else
            [_textField[2] performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0.5];
    }
    else
        [textField resignFirstResponder];
    return YES;
}

@end