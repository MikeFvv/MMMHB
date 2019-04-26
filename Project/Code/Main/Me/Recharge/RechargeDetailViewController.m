//
//  RechargeDetailViewController.m
//  ProjectXZHB
//
//  Created by fangyuan on 2019/3/9.
//  Copyright © 2019 CDJay. All rights reserved.
//

#import "RechargeDetailViewController.h"
#import "WebViewController.h"
#import "DepositOrderController.h"
#import "UIImageView+WebCache.h"

@interface RechargeDetailViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,ActionSheetDelegate>
@property(nonatomic,assign)NSInteger type;
@property(nonatomic,strong)UITableView *tableView;
@property(nonatomic,strong)UITextField *moneyTextField;//充值金额输入框
@property(nonatomic,strong)NSMutableArray *moneyBtnArray;//金额按钮列表
@property(nonatomic,strong)NSMutableArray *typeBtnArray;//转账按钮列表

@property(nonatomic,strong)UITextField *nameTextField;//姓名输入框
@property(nonatomic,strong)UITextField *bankNameField;//开户行输入框
@property(nonatomic,strong)UITextField *accountTextField;//账号输入框
@property(nonatomic,strong)UIButton *selectBankBtn;//选择银行按钮
@property(nonatomic,assign)NSInteger selectType;
@property(nonatomic,strong)NSString *bankId;

@property(nonatomic,strong)NSArray *bankList;

@end

@implementation RechargeDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.navigationController.navigationBar setTranslucent:NO];
    
    self.type = [self.infoDic[@"type"] integerValue];
    self.selectType = 0;//转账类型
    
    _tableView = [UITableView groupTable];
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = BaseColor;
    _tableView.backgroundView = view;
    [self.view addSubview:_tableView];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.tableHeaderView = [self headView];
    _tableView.rowHeight = 158;
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    _tableView.tableFooterView = [self bottomView];
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    self.bankList = [ud objectForKey:@"bankList"];
    
    [self requestBankList];
}

-(void)requestBankList{
    WEAK_OBJ(weakObj, self);
    [NET_REQUEST_MANAGER requestBankListWithSuccess:^(id object) {
        NSArray *arr = [object objectForKey:@"data"];
        weakObj.bankList = arr;
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        [ud setObject:arr forKey:@"bankList"];
        [ud synchronize];
    } fail:^(id object) {
    }];
}

#pragma mark - UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 50;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    
    NSInteger y = 5;
    NSInteger per = 4;
    NSInteger width = 75;
    if(SCREEN_WIDTH == 375)
        width = 86;
    else if(SCREEN_WIDTH > 375)
        width = 96;
    NSInteger height = 40;
    NSInteger x = 5;
    NSInteger invX = (SCREEN_WIDTH - x * 2 - width * per)/(per + 1);
    NSInteger bottom = 0;
    
    NSArray *arr = @[@"网银转账",@"ATM转账",@"手机银行转账",@"支付宝存款"];//[self.infoDic[@"bankCardForward"] componentsSeparatedByString:@","];
    self.typeBtnArray = [NSMutableArray array];
    
    NSInteger right = x + invX;
    for (NSInteger i = 0; i < arr.count; i ++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setBackgroundImage:[[UIImage imageNamed:@"rechargeBtn1"] stretchableImageWithLeftCapWidth:20 topCapHeight:10] forState:UIControlStateNormal];
        [btn setBackgroundImage:[[UIImage imageNamed:@"rechargeBtn2"] stretchableImageWithLeftCapWidth:20 topCapHeight:10] forState:UIControlStateSelected];
        btn.tag = i;
        [btn addTarget:self action:@selector(selectType:) forControlEvents:UIControlEventTouchUpInside];
        btn.titleLabel.font = [UIFont systemFontOfSize:15];
        btn.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        if(i == 0){
            btn.selected = YES;
        }
        [btn setTitle:arr[i] forState:UIControlStateNormal];
        NSInteger a = i%per;
        NSInteger b = i/per;
        NSInteger ww = width;
        if(i < 2)
            ww = width - 13;
        else if(i == 2)
            ww = width + 20;
        else ww = width + 6;
        btn.frame = CGRectMake(right, b * (height + invX)+y, ww, height);
        [view addSubview:btn];
        bottom = btn.frame.origin.y + btn.frame.size.height;
        [self.typeBtnArray addObject:btn];
        
        right = btn.frame.size.width + btn.frame.origin.x;
        right += invX;
    }
    
    return view;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if(self.type == 4)
        return 1;
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(self.type == 4)
        return 1;
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:0 reuseIdentifier:@"cell"];
        
        NSInteger x = self.moneyTextField.superview.frame.origin.x;
        UIImageView *inputBg = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"rechargeInput1"] stretchableImageWithLeftCapWidth:20 topCapHeight:10]];
        inputBg.frame = CGRectMake(x, 5, SCREEN_WIDTH - x * 2, 44);
        inputBg.userInteractionEnabled = YES;
        [cell addSubview:inputBg];
        
        UITextField *tf = [[UITextField alloc] init];
        tf.backgroundColor = [UIColor clearColor];
        tf.textAlignment = NSTextAlignmentLeft;
        tf.font = [UIFont systemFontOfSize2:16];
        tf.textColor = COLOR_X(60, 60, 60);
        tf.frame = CGRectMake(15, 0, inputBg.frame.size.width - 30, inputBg.frame.size.height);
        tf.delegate = self;
        tf.returnKeyType = UIReturnKeyDone;
        tf.placeholder = @"请输入存款人姓名";
        [inputBg addSubview:tf];
        self.nameTextField = tf;
        
        inputBg = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"rechargeInput1"] stretchableImageWithLeftCapWidth:20 topCapHeight:10]];
        inputBg.frame = CGRectMake(x, 57, SCREEN_WIDTH - x - 110, 44);
        inputBg.userInteractionEnabled = YES;
        [cell addSubview:inputBg];
        
        tf = [[UITextField alloc] init];
        tf.backgroundColor = [UIColor clearColor];
        tf.textAlignment = NSTextAlignmentLeft;
        tf.font = [UIFont systemFontOfSize2:16];
        tf.textColor = COLOR_X(60, 60, 60);
        tf.frame = CGRectMake(15, 0, inputBg.frame.size.width - 30, inputBg.frame.size.height);
        tf.returnKeyType = UIReturnKeyDone;
        tf.userInteractionEnabled = NO;
        tf.placeholder = @"请选择开户行";
        [inputBg addSubview:tf];
        self.bankNameField = tf;
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setBackgroundImage:[[UIImage imageNamed:@"rechargeBtn2"] stretchableImageWithLeftCapWidth:20 topCapHeight:10] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(selectBank) forControlEvents:UIControlEventTouchUpInside];
        btn.titleLabel.font = [UIFont systemFontOfSize:15];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn setTitle:@"选择银行" forState:UIControlStateNormal];
        NSInteger xx = SCREEN_WIDTH - 105;
        btn.frame = CGRectMake(xx, 57, 105 - x, 44);
        [cell addSubview:btn];
        self.selectBankBtn = btn;
        
        inputBg = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"rechargeInput1"] stretchableImageWithLeftCapWidth:20 topCapHeight:10]];
        inputBg.frame = CGRectMake(x, 109, SCREEN_WIDTH - x * 2, 44);
        inputBg.userInteractionEnabled = YES;
        [cell addSubview:inputBg];
        
        tf = [[UITextField alloc] init];
        tf.backgroundColor = [UIColor clearColor];
        tf.textAlignment = NSTextAlignmentLeft;
        tf.font = [UIFont systemFontOfSize2:16];
        tf.textColor = COLOR_X(60, 60, 60);
        tf.frame = CGRectMake(15, 0, inputBg.frame.size.width - 30, inputBg.frame.size.height);
        tf.delegate = self;
        tf.returnKeyType = UIReturnKeyDone;
        tf.placeholder = @"请输入银行卡号后四位";
        [inputBg addSubview:tf];
        self.accountTextField = tf;
    }
    if(self.selectType == 3){
        self.bankNameField.hidden = YES;
        NSInteger x = self.moneyTextField.superview.frame.origin.x;
        self.selectBankBtn.frame = CGRectMake(x, 57, self.moneyTextField.superview.frame.size.width, 44);
        [self.selectBankBtn setBackgroundImage:[[UIImage imageNamed:@"rechargeBtn1"] stretchableImageWithLeftCapWidth:20 topCapHeight:10] forState:UIControlStateNormal];
        [self.selectBankBtn setTitle:@"支付宝账户" forState:UIControlStateNormal];
        self.accountTextField.placeholder = @"请输入支付宝账号";
    }else{
        NSInteger x = self.moneyTextField.superview.frame.origin.x;
        NSInteger xx = SCREEN_WIDTH - 105;
        self.selectBankBtn.frame = CGRectMake(xx, 57, 105 - x, 44);
        self.bankNameField.hidden = NO;
        [self.selectBankBtn setBackgroundImage:[[UIImage imageNamed:@"rechargeBtn2"] stretchableImageWithLeftCapWidth:20 topCapHeight:10] forState:UIControlStateNormal];
        [self.selectBankBtn setTitle:@"选择银行" forState:UIControlStateNormal];
        self.accountTextField.placeholder = @"请输入银行卡号后四位";
    }
    return cell;
}

-(UIView *)headView{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 80)];
    view.backgroundColor = [UIColor clearColor];
    
    UIView *iconView = [self headIcon];
    [view addSubview:iconView];
//    UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 24, view.frame.size.width, 44)];
//    iconView.contentMode = UIViewContentModeScaleAspectFit;
//    iconView.image = [UIImage imageNamed:@"wechat111"];
//    [view addSubview:iconView];
    
    NSArray *array = [self.infoDic[@"allocationAmount"] componentsSeparatedByString:@","];

    NSInteger y = iconView.frame.size.height + iconView.frame.origin.y + 16;
    if(array.count > 0){
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, y, 150, 20)];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = COLOR_X(80, 80, 80);
        titleLabel.font = [UIFont systemFontOfSize2:16];
        titleLabel.text = @"选择存款金额";
        [view addSubview:titleLabel];
        y = titleLabel.frame.origin.y + titleLabel.frame.size.height + 10;
    }
    
    NSInteger per = 4;
    NSInteger width = 70;
    if(SCREEN_WIDTH > 375)
        width = 84;
    NSInteger height = 40;
    NSInteger x = 10;
    NSInteger invX = (SCREEN_WIDTH - x * 2 - width * per)/(per + 1);
    NSInteger bottom = y;
    self.moneyBtnArray = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < array.count; i ++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setBackgroundImage:[[UIImage imageNamed:@"rechargeBtn1"] stretchableImageWithLeftCapWidth:20 topCapHeight:10] forState:UIControlStateNormal];
        [btn setBackgroundImage:[[UIImage imageNamed:@"rechargeBtn2"] stretchableImageWithLeftCapWidth:20 topCapHeight:10] forState:UIControlStateSelected];
        btn.tag = i;
        [btn addTarget:self action:@selector(selectMoney:) forControlEvents:UIControlEventTouchUpInside];
        btn.titleLabel.font = [UIFont systemFontOfSize2:17];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn setTitle:array[i] forState:UIControlStateNormal];
        NSInteger a = i%per;
        NSInteger b = i/per;
        btn.frame = CGRectMake(x + invX * (a + 1) + width *a, b * (height + invX)+y, width, height);
        [view addSubview:btn];
        bottom = btn.frame.origin.y + btn.frame.size.height;
        [self.moneyBtnArray addObject:btn];
    }
    
    UIImageView *inputBg = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"rechargeInput1"] stretchableImageWithLeftCapWidth:20 topCapHeight:10]];
    inputBg.frame = CGRectMake(x + invX, bottom + invX + 3, SCREEN_WIDTH - (x + invX) * 2, 44);
    inputBg.userInteractionEnabled = YES;
    [view addSubview:inputBg];
    
    UILabel *tLabel = [[UILabel alloc] init];
    tLabel.backgroundColor = [UIColor clearColor];
    tLabel.textColor = COLOR_X(80, 80, 80);
    tLabel.font = [UIFont systemFontOfSize2:15];
    tLabel.text = @"充值金额";
    tLabel.textAlignment = NSTextAlignmentCenter;
    tLabel.frame = CGRectMake(0, 0, 90, inputBg.frame.size.height);
    [inputBg addSubview:tLabel];
    
    tLabel = [[UILabel alloc] init];
    tLabel.backgroundColor = [UIColor clearColor];
    tLabel.textColor = COLOR_X(80, 80, 80);
    tLabel.font = [UIFont systemFontOfSize2:15];
    tLabel.text = @"元";
    tLabel.textAlignment = NSTextAlignmentCenter;
    tLabel.frame = CGRectMake(inputBg.frame.size.width - 40, 0, 30, inputBg.frame.size.height);
    [inputBg addSubview:tLabel];
    
    UITextField *tf = [[UITextField alloc] init];
    tf.backgroundColor = [UIColor clearColor];
    tf.font = [UIFont systemFontOfSize2:16];
    tf.textColor = COLOR_X(60, 60, 60);
    tf.frame = CGRectMake(90, 0, inputBg.frame.size.width - 90 - 40, inputBg.frame.size.height);
    tf.delegate = self;
    tf.textAlignment = NSTextAlignmentRight;
    tf.returnKeyType = UIReturnKeyDone;
    tf.keyboardType = UIKeyboardTypeNumberPad;
    tf.placeholder = @"请输入金额";
    [inputBg addSubview:tf];
    self.moneyTextField = tf;
    
    bottom = inputBg.frame.size.height + inputBg.frame.origin.y;
    
    tLabel = [[UILabel alloc] init];
    tLabel.backgroundColor = [UIColor clearColor];
    tLabel.textColor = COLOR_X(150, 150, 150);
    tLabel.font = [UIFont systemFontOfSize2:13];
    tLabel.text = [NSString stringWithFormat:@"单笔存款限额（元）：%@-%@",self.infoDic[@"minAmount"],self.infoDic[@"maxAmount"]];
    tLabel.frame = CGRectMake(inputBg.frame.origin.x, bottom + 5, 250, 16);
    [view addSubview:tLabel];
    
    bottom = tLabel.frame.size.height + tLabel.frame.origin.y;
    
    CGRect rect = view.frame;
    rect.size.height = bottom + 15;
    view.frame = rect;
    return view;
}

-(UIView *)bottomView{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [view addSubview:btn];
    btn.titleLabel.font = [UIFont boldSystemFontOfSize2:17];
    if(self.type == 4)
        [btn setTitle:@"下一步" forState:UIControlStateNormal];
    else
        [btn setTitle:@"去支付" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(submitAction) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.layer.cornerRadius = 8.0f;
    btn.layer.masksToBounds = YES;
    [btn setBackgroundImage:[UIImage imageNamed:@"rechargeBtn3"] forState:UIControlStateNormal];
    [btn delayEnable];
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(16));
        make.right.equalTo(view.mas_right).offset(-20);
        make.height.equalTo(@(44));
        make.top.equalTo(view.mas_top).offset(3);
    }];
    return view;
}

-(void)selectMoney:(UIButton *)btn{
    [self.view endEditing:YES];
    for (UIButton *button in self.moneyBtnArray) {
        if(button != btn)
            button.selected = NO;
    }
    self.moneyTextField.text = [btn titleForState:UIControlStateNormal];
    btn.selected = YES;
}

-(void)selectType:(UIButton *)btn{
    [self.view endEditing:YES];
    for (UIButton *button in self.typeBtnArray) {
        if(button != btn)
            button.selected = NO;
    }
    btn.selected = YES;
    self.selectType = btn.tag;
    
    if(self.selectType == 3){
        self.bankNameField.hidden = YES;
        NSInteger x = self.moneyTextField.superview.frame.origin.x;
        self.selectBankBtn.frame = CGRectMake(x, 57, self.moneyTextField.superview.frame.size.width, 44);
        [self.selectBankBtn setBackgroundImage:[[UIImage imageNamed:@"rechargeBtn1"] stretchableImageWithLeftCapWidth:20 topCapHeight:10] forState:UIControlStateNormal];
        [self.selectBankBtn setTitle:@"支付宝账户" forState:UIControlStateNormal];
        self.accountTextField.placeholder = @"请输入支付宝账号";
    }else{
        NSInteger x = self.moneyTextField.superview.frame.origin.x;
        NSInteger xx = SCREEN_WIDTH - 105;
        self.selectBankBtn.frame = CGRectMake(xx, 57, 105 - x, 44);
        self.bankNameField.hidden = NO;
        [self.selectBankBtn setBackgroundImage:[[UIImage imageNamed:@"rechargeBtn2"] stretchableImageWithLeftCapWidth:20 topCapHeight:10] forState:UIControlStateNormal];
        [self.selectBankBtn setTitle:@"选择银行" forState:UIControlStateNormal];
        self.accountTextField.placeholder = @"请输入银行卡号后四位";
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
}

-(void)submitAction{
    NSString *money = self.moneyTextField.text;
    if(money.length == 0){
        SVP_ERROR_STATUS(@"请输入金额");
        return;
    }
    if(![FUNCTION_MANAGER checkIsNum:money]){
        SVP_ERROR_STATUS(@"请输入正确的金额");
    }
    
    float aa = [money floatValue];
    NSInteger minMoney = [self.infoDic[@"minAmount"] integerValue];
    NSInteger maxMoney = [self.infoDic[@"maxAmount"] integerValue];
    if(aa < minMoney){
        NSString *tip = [NSString stringWithFormat:@"存款金额最小%zd元",minMoney];
        SVP_ERROR_STATUS(tip);
        return;
    }
    if(aa > maxMoney){
        NSString *tip = [NSString stringWithFormat:@"存款金额最大%zd元",maxMoney];
        SVP_ERROR_STATUS(tip);
        return;
    }
    if(self.type != 4)
        [self openByWeb];
    else{
        if(self.nameTextField.text.length == 0){
            SVP_ERROR_STATUS(@"请输入存款人姓名");
            return;
        }
        if(self.selectType != 3){
            if(self.bankId == nil){
                SVP_ERROR_STATUS(@"请选择银行");
                return;
            }
        }
        if(self.accountTextField.text.length < 4){
            if(self.selectType == 3)
                SVP_ERROR_STATUS(@"请输入支付宝账号");
            else
                SVP_ERROR_STATUS(@"请输入银行卡后四位");
            return;
        }
        [self.view endEditing:YES];
        SVP_SHOW;
        WEAK_OBJ(weakSelf, self);
        NSString *bankId = nil;
        NSString *bankName = nil;
        if(self.selectType != 3){
            bankId = self.bankId;
            bankName = self.bankNameField.text;
        }
        [NET_REQUEST_MANAGER submitRechargeInfoWithBankId:bankId bankName:bankName bankNo:self.accountTextField.text tId:self.infoDic[@"id"] money:self.moneyTextField.text name:self.nameTextField.text orderId:nil type:self.selectType + 1 typeCode:[self.infoDic[@"typeCode"] integerValue] userId:APP_MODEL.user.userId success:^(id object) {
            SVP_DISMISS;
            [weakSelf goToCheck:object[@"data"]];
        } fail:^(id object) {
            [FUNCTION_MANAGER handleFailResponse:object];
        }];
    }
}

-(void)openByWeb{
    NSString *url = [NSString stringWithFormat:@"%@%@?userId=%@&amount=%@&id=%@&typeCode=%zd",APP_MODEL.serverUrl,self.infoDic[@"url"],APP_MODEL.user.userId,self.moneyTextField.text,self.infoDic[@"id"],[self.infoDic[@"typeCode"] integerValue]];
    WebViewController *vc = [[WebViewController alloc] initWithUrl:url];
    vc.navigationItem.title = @"充值";
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark
- (void)selectBank{
    if(self.selectType == 3)
        return;
    [self.view endEditing:YES];
    NSMutableArray *arr = [NSMutableArray array];
    for (NSDictionary *dic in self.bankList) {
        NSString *bankName = dic[@"title"];
        [arr addObject:bankName];
    }
    ActionSheetCus *sheet = [[ActionSheetCus alloc] initWithArray:arr];
    sheet.titleLabel.text = @"请选择银行";
    sheet.delegate = self;
    [sheet showWithAnimationWithAni:YES];
}

-(void)actionSheetDelegateWithActionSheet:(ActionSheetCus *)actionSheet index:(NSInteger)index{
    if(index == self.bankList.count)
        return;
    NSDictionary *dic = self.bankList[index];
    NSString *bankName = dic[@"title"];
    NSInteger bankId = [dic[@"id"] integerValue];
    self.bankId = INT_TO_STR(bankId);
    self.bankNameField.text = bankName;
}

-(void)goToCheck:(NSDictionary *)dict{
    DepositOrderController *vc = [[DepositOrderController alloc] init];
    vc.imageUrl = self.infoDic[@"img"];
    vc.titleStr = self.infoDic[@"title"];
    vc.infoDic = dict;
    vc.type = self.type;
    [self.navigationController pushViewController:vc animated:YES];
}

-(UIView *)headIcon{
    UIImageView *imgView = [[UIImageView alloc] init];
    imgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"recharget%zd",self.type]];
    imgView.contentMode = UIViewContentModeScaleAspectFit;
    imgView.frame = CGRectMake(0, 20, SCREEN_WIDTH, 50);
    
    return imgView;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if(textField == self.moneyTextField){
        for (UIButton *btn in self.moneyBtnArray) {
            btn.selected = NO;
        }
    }
    return YES;
}
@end
