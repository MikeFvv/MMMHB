//
//  EnvelopeViewController.m
//  Project
//
//  Created by mini on 2018/8/8.
//  Copyright © 2018年 CDJay. All rights reserved.
//

#import "EnvelopeViewController.h"
#import "ChatViewController.h"
#import "EnvelopeMessage.h"
#import "EnvelopeNet.h"
#import "MessageItem.h"
#import "NetRequestManager.h"

@interface EnvelopeViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>{
    UITableView *_tableView;
    UITextField *_textField[3];
    NSArray *_rowList;
    UILabel *_moneyLabel;
    UIButton *_submit;
}

@property (nonatomic ,strong) MessageItem *message;
@end

@implementation EnvelopeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self initSubviews];
    [self initLayout];
    [self initNotif];
}

#pragma mark ----- Data
- (void)initData{
    NSLog(@"%@",self.CDParam);
    _message = (MessageItem *)self.CDParam;
    _rowList = (_message.type == 1)?@[@[@{@"title":@"总金额",@"right":@"元",@"placeholder":@"0"},@{@"title":@"红包个数",@"right":@"个",@"placeholder":@"填写红包个数"}],@[@{@"title":@"雷数",@"right":@"",@"placeholder":@"请输入雷数"}]]:@[@[@{@"title":@"总金额",@"right":@"元",@"placeholder":@"0.00"},@{@"title":@"红包个数",@"right":@"个",@"placeholder":@"填写红包个数"}]];
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

- (void)textFieldDidChangeValue:(NSNotification *)text{
    NSInteger m = [_textField[0].text integerValue];
    NSInteger l = [_textField[2].text integerValue];
    if (text.object == _textField[0]) {
        _moneyLabel.text = [NSString stringWithFormat:@"￥%ld",m];
    }
    BOOL money = [self money:m];
    BOOL lel = [self lei:l];
    if (money &&lel) {
        _submit.enabled = YES;
        _submit.backgroundColor = MBTAColor(1.0);
    }
    else{
        _submit.enabled = NO;
        _submit.backgroundColor = MBTAColor(0.4);
    }
}

- (BOOL)money:(CGFloat)money{
    NSInteger max = [_message.maxMoney integerValue];
    NSInteger min = [_message.minMoney integerValue];
    if ((money > max) | (money < min)) {
        return NO;
    }
    else
        return YES;
}

- (BOOL)lei:(CGFloat)number{
    CGFloat max = 9;//[_message.maxMoney floatValue];
    CGFloat min = 0;//[_message.minMoney floatValue];
    if ((number > max) | (number < min)) {
        return NO;
    }
    else
        return YES;
}


#pragma mark ----- subView
- (void)initSubviews{
    
    self.view.backgroundColor = BaseColor;
    self.navigationItem.title = @"发红包";
    
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 30)];
    btn.titleLabel.font = [UIFont scaleFont:14];
    [btn addTarget:self action:@selector(action_cancle) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitle:@"取消" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    UIBarButtonItem *l = [[UIBarButtonItem alloc]initWithCustomView:btn];
    self.navigationItem.leftBarButtonItem = l;
    
    _tableView = [UITableView groupTable];
    [self.view addSubview:_tableView];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    _tableView.separatorColor = TBSeparaColor;
    _tableView.rowHeight = 50;
    
    UIView *headView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CDScreenWidth, 100)];
    _tableView.tableHeaderView = headView;
    
    _moneyLabel = [UILabel new];
    [headView addSubview:_moneyLabel];
    _moneyLabel.font = [UIFont scaleFont:40];
    _moneyLabel.textColor = Color_3;
    _moneyLabel.text = @"￥0";
    
    [_moneyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(headView);
        make.top.equalTo(headView.mas_top).offset(30);
    }];
    
    UIView *fotView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CDScreenWidth, 100)];
    _tableView.tableFooterView = fotView;
    
    _submit = [UIButton new];
    [fotView addSubview:_submit];
    _submit.layer.cornerRadius = 8;
    _submit.titleLabel.font = [UIFont scaleFont:17];
    _submit.layer.masksToBounds = YES;
    _submit.backgroundColor = MBTNColor;
    [_submit setTitle:@"塞钱进红包" forState:UIControlStateNormal];
    [_submit setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_submit addTarget:self action:@selector(action_sendNew) forControlEvents:UIControlEventTouchUpInside];
    
    [_submit mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(15);
        make.right.equalTo(self.view.mas_right).offset(-15);
        make.height.equalTo(@(42));
        make.top.equalTo(fotView.mas_top).offset(7);
    }];
    
    UILabel *bot = [UILabel new];
    [fotView addSubview:bot];
    bot.font = [UIFont scaleFont:12];
    bot.textColor = Color_6;
    bot.text = @"未领取的红包，将于5分钟后发起退款";
    
    [bot mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self -> _submit);
        make.top.equalTo(self ->_submit.mas_bottom).offset(9);
    }];
}

#pragma mark UITableViewDelegate,UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 33;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CDScreenWidth, 33)];
    UILabel *label = [UILabel new];
    [view addSubview:label];
    label.font = [UIFont scaleFont:12];
    label.textColor = Color_6;
    label.text = (section == 0)? [NSString stringWithFormat:@"红包发布范围: %@-%@元",_message.minMoney,_message.maxMoney]:@"雷数范围0-9";
    
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view.mas_left).offset(15);
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
        cell.textLabel.font = [UIFont scaleFont:14];
        cell.textLabel.textColor = Color_3;
        
        NSInteger row = indexPath.section *2 +indexPath.row;
        _textField[row] = [UITextField new];
        [cell.contentView addSubview:_textField[row]];
        
        _textField[row].placeholder = _rowList[indexPath.section][indexPath.row][@"placeholder"];
        _textField[row].font = [UIFont scaleFont:15];
        _textField[row].keyboardType = UIKeyboardTypeNumberPad;
        
        UILabel *unit = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 30, 20)];
        _textField[row].rightView = unit;
        _textField[row].rightViewMode = UITextFieldViewModeAlways;
        
        unit.font = [UIFont scaleFont:14];
        unit.text = _rowList[indexPath.section][indexPath.row][@"right"];;
        unit.textAlignment = NSTextAlignmentRight;
        unit.textColor = Color_3;
        
        if(row == 1){
            if(_message.type == 1){
                _textField[1].text = [NSString stringWithFormat:@"%ld",[_message.count integerValue]];
                _textField[1].userInteractionEnabled = NO;
                _textField[1].textColor = COLOR_Y(140);
                cell.textLabel.textColor = COLOR_Y(140);
                unit.textColor = COLOR_Y(140);
            }
        }
        
        [_textField[row] mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(cell.contentView.mas_right).offset(-15);
            make.top.bottom.equalTo(cell.contentView);
            make.left.equalTo(cell.contentView).offset(95);
        }];
    }
    return cell;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _rowList.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

#pragma mark action
- (void)action_cancle{
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark action
- (void)doneSend:(EnvelopeMessage *)message{
    [self dismissViewControllerAnimated:YES completion:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [ChatViewController sendCustomMessage:message];
    });
}



#pragma mark 发红包 塞钱进红包  Mike
- (void)action_sendNew {
    NSString *money = _textField[0].text;
    NSString *packetNum = _textField[1].text;
    NSString *bombNum = _textField[2].text;

    if (money.length == 0) {
        SV_ERROR_STATUS(@"请输入总金额");
        return;
    }
    if (packetNum.length == 0) {
        SV_ERROR_STATUS(@"请输入红包个数");
        return;
    }
    if (bombNum.length == 0) {
        SV_ERROR_STATUS(@"请输入雷数");
        return;
    }
    
    NSString * regex        = @"(^[0-9]{0,15}$)";
    NSPredicate * pred      = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    
    if(![pred evaluateWithObject:money]){
        SV_ERROR_STATUS(@"金额请输入整数");
        return;
    }
    if(![pred evaluateWithObject:bombNum]){
        SV_ERROR_STATUS(@"雷数请输入整数");
        return;
    }
    
    SV_SHOW;
    CDWeakSelf(self);
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:bombNum forKey:@"bombNum"];
    
    [NET_REQUEST_MANAGER sendRedPackageWithGroupId:self.message.groupId userId:APP_MODEL.user.userId type:self.message.type money:money count:packetNum.integerValue ext:dic success:^(id object) {
        NSLog(@"object:%@",object);
        SV_DISMISS;
        [weakself action_cancle];
//        EnvelopeMessage *message = [[EnvelopeMessage alloc]initWithObj:object[@"requestParameters"]];
//        [self doneSend:message];
        
    } fail:^(id object) {
        [FUNCTION_MANAGER handleFailResponse:object];
    }];
    
}



//- (void)action_send{
//
//    if (_textField[0].text.length == 0) {
//        SV_ERROR_STATUS(@"请输入金额");
//        return;
//    }
//    if (_textField[1].text.length == 0) {
//        SV_ERROR_STATUS(@"请输入个数");
//        return;
//    }
//    SV_SHOW;
//    CDWeakSelf(self);
//    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithDictionary:@{@"token":APP_MODEL.user.token,@"groupId":_message.groupId,@"money":_textField[0].text,@"count":_textField[1].text}];
//    if (_textField[2].text) {
//        [dic setObject:_textField[2].text forKey:@"num"];
//    }else
//        [dic setObject:@"0" forKey:@"num"];
//    [EnvelopeNet sendEnvelop:dic Success:^(NSDictionary *info) {
//        NSLog(@"info:%@",info);
//        SV_DISMISS;
//        CDStrongSelf(self);
//        EnvelopeMessage *message = [[EnvelopeMessage alloc]initWithObj:info];
//        [self doneSend:message];
//    } Failure:^(NSError *error) {
//        SV_ERROR(error);
//    }];
//}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
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
