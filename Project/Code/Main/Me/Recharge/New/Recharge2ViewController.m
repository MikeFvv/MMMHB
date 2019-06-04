//
//  Recharge2ViewController.m
//  Project
//
//  Created by fangyuan on 2019/5/9.
//  Copyright © 2019 CDJay. All rights reserved.
//

#import "Recharge2ViewController.h"
#import "TypeView.h"
#import "ChannelView.h"
#import "WebViewController.h"
#import "CustomerServiceAlertView.h"
#import "DepositOrderController.h"
#import "ReportView.h"

@interface Recharge2ViewController ()<UITextFieldDelegate>
@property(nonatomic,strong)NSArray *typeArray;
@property(nonatomic,strong)NSDictionary *infoDic;
@property(nonatomic,strong)ChannelView *channelView;
@property(nonatomic,strong)UIView *containView;
@property(nonatomic,assign)RechargeType rechargeType;//充值类型
@property(nonatomic,assign)NSInteger channelIndex;//通道索引
@property(nonatomic,strong)UITextField *moneyTextField;//充值金额输入框
@property(nonatomic,strong)UITextField *nameField;
@property(nonatomic,strong)UIButton *tempBtn;
@property(nonatomic,strong)UIScrollView *scrollView;
@property(nonatomic,strong)UIView *tipView;
@end

@implementation Recharge2ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"充值中心";
//    [self.navigationController.navigationBar setBackgroundImage:[[FunctionManager sharedInstance] imageWithColor:[UIColor whiteColor]] forBarMetrics:UIBarMetricsDefault];
   // 获取状态栏的rect
//    CGRect statusRect = [[UIApplication sharedApplication] statusBarFrame];
//    //获取导航栏的rect
//    CGRect navRect = self.navigationController.navigationBar.frame;
//   // 那么导航栏+状态栏的高度
//    NSInteger h = statusRect.size.height+navRect.size.height;
//    CGRect rect = self.view.frame;
//    rect.size.height = SCREEN_HEIGHT - h;
//    self.view.frame = rect;
    
    [self requestData];
    
    UIButton *kfBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 44, 44)];
    [kfBtn setImage:[UIImage imageNamed:@"rec_kf"] forState:UIControlStateNormal];
    [kfBtn addTarget:self action:@selector(keFu) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *kfItem = [[UIBarButtonItem alloc]initWithCustomView:kfBtn];
    self.navigationItem.rightBarButtonItem = kfItem;
}

-(void)requestData{
    SVP_SHOW;
    WEAK_OBJ(weakSelf, self);
    [NET_REQUEST_MANAGER requestAllRechargeChannelWithSuccess:^(id object) {
        SVP_DISMISS;
        weakSelf.infoDic = object[@"data"];
        [weakSelf reloadData];
    } fail:^(id object) {
        [[FunctionManager sharedInstance] handleFailResponse:object];
    }];
}

-(void)reloadData{
    if(self.infoDic == nil)
        return;
    if(self.scrollView == nil){
        self.typeArray = [self typeData];
        self.view.backgroundColor = COLOR_X(237, 239, 242);
        
        WEAK_OBJ(weakSelf, self);
        TypeView *typeView = [[TypeView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 80) buttonArray:self.typeArray];
        typeView.selectBlock = ^(id object) {
            [weakSelf selectType:[object integerValue] - 1];
        };
        [self.view addSubview:typeView];
        
        UIImageView *shadowView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"rec_shadow"] stretchableImageWithLeftCapWidth:10 topCapHeight:5]];
        shadowView.frame = CGRectMake(0, typeView.frame.size.height, SCREEN_WIDTH, 6);
        [self.view addSubview:shadowView];
        
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 80, self.view.frame.size.width, self.view.frame.size.height - 80)];
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.showsHorizontalScrollIndicator = NO;
        [self.view addSubview:scrollView];
        self.scrollView = scrollView;
    }
    if(self.channelView == nil){
        WEAK_OBJ(weakSelf, self);
        NSInteger y = 10;
        NSInteger a = 100;
        if(SCREEN_WIDTH == 320)
            a = 90;
        ChannelView *channelView = [[ChannelView alloc] initWithFrame:CGRectMake(0, y, a, 320)];
        [self.scrollView addSubview:channelView];
        self.channelView = channelView;
        channelView.selectBlock = ^(id object) {
            [weakSelf selectChannel:[object integerValue]];
        };
    }
    self.channelView.rechargeType = self.rechargeType;
    if(self.rechargeType == RechargeType_gf){
        NSArray *channelArr = @[@"银行卡"];//@[@"银行卡",@"支付宝",@"微信"];
        self.channelView.channelArray = channelArr;
    }else{
        NSArray *arr = nil;
        if(self.rechargeType == RechargeType_zhiFuBao)
            arr = [self.infoDic objectForKey:@"alipayChanels"];
        else if(self.rechargeType == RechargeType_yinLian)
            arr = [self.infoDic objectForKey:@"unionPayChanels"];
        else if(self.rechargeType == RechargeType_weiXin)
            arr = [self.infoDic objectForKey:@"wechatChanels"];
        NSMutableArray *channelArr = [NSMutableArray array];
        for (NSInteger i = 0; i < arr.count; i ++) {
            [channelArr addObject:[NSString stringWithFormat:@"通道%@",[self numberToZH:[NSString stringWithFormat:@"%ld",i + 1]]]];
        }
        self.channelView.channelArray = channelArr;
    }
    [self selectChannel:0];
}

-(void)selectType:(NSInteger)index{
    NSDictionary *dic = self.typeArray[index];
    [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    self.rechargeType = [dic[@"tag"] integerValue];
    self.channelIndex = 0;
    [self reloadData];
}

-(void)selectChannel:(NSInteger)index{
    self.channelIndex = index;
    [self reloadContainView];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


-(NSArray *)typeData{
    NSArray *channelArr = nil;
    NSMutableArray *arr = [NSMutableArray array];
    channelArr = [self.infoDic objectForKey:@"alipayChanels"];
    if(channelArr.count > 0){
        NSDictionary *dic3 = @{@"imgNormal":@"rec_jf",@"imgSelected":@"rec_jf2",@"tag":@(RechargeType_zhiFuBao),};
        [arr addObject:dic3];
        if(self.rechargeType == RechargeType_nil)
            self.rechargeType = RechargeType_zhiFuBao;
    }
    channelArr = [self.infoDic objectForKey:@"wechatChanels"];
    if(channelArr.count > 0){
        NSDictionary *dic2 = @{@"imgNormal":@"rec_wx",@"imgSelected":@"rec_wx2",@"tag":@(RechargeType_weiXin),};
        [arr addObject:dic2];
        if(self.rechargeType == RechargeType_nil)
            self.rechargeType = RechargeType_weiXin;
    }
    
    channelArr = [self.infoDic objectForKey:@"unionPayChanels"];
    if(channelArr.count > 0){
        NSDictionary *dic4 = @{@"imgNormal":@"rec_yl",@"imgSelected":@"rec_yl2",@"tag":@(RechargeType_yinLian),};
        [arr addObject:dic4];
        if(self.rechargeType == RechargeType_nil)
            self.rechargeType = RechargeType_yinLian;
    }
    channelArr = [self.infoDic objectForKey:@"bankPayChanels"];
    if(channelArr.count > 0){
        NSDictionary *dic1 = @{@"imgNormal":@"rec_gf",@"imgSelected":@"rec_gf2",@"tag":@(RechargeType_gf)};
        [arr addObject:dic1];
        if(self.rechargeType == RechargeType_nil)
            self.rechargeType = RechargeType_gf;
    }
    return arr;
}

-(void)reloadContainView{
    if(self.containView)
        [self.containView removeFromSuperview];
    self.tempBtn = nil;
    self.moneyTextField = nil;
    
    CGRect rect = self.channelView.frame;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(self.channelView.frame.size.width, self.channelView.frame.origin.y, SCREEN_WIDTH - self.channelView.frame.size.width, self.channelView.frame.size.height)];
    [self.scrollView addSubview:view];
    view.backgroundColor = [UIColor whiteColor];
    self.containView = view;
    

    UILabel *titleLabel = [[UILabel alloc] init];
    [self.containView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.equalTo(self.containView);
        make.left.equalTo(self.containView).offset(20);
        make.height.equalTo(@50);
    }];
    titleLabel.font = [UIFont systemFontOfSize2:16];
    titleLabel.textColor = COLOR_X(60, 60, 60);
    
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = TBSeparaColor;
    [self.containView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.containView);
        make.height.equalTo(@0.5);
        make.top.equalTo(titleLabel.mas_bottom);
    }];
    if(self.rechargeType == RechargeType_gf)
        titleLabel.text = @"官方代理充值";
    else{
        NSDictionary *dic = [self currentPayInfo];
        titleLabel.text = dic[@"title"];
    }
    
//    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [btn setImage:[UIImage imageNamed:@"reportBtn"] forState:UIControlStateNormal];
//    btn.imageView.contentMode = UIViewContentModeScaleAspectFit;
//    [btn addTarget:self action:@selector(reportAction) forControlEvents:UIControlEventTouchUpInside];
//    [self.containView addSubview:btn];
//    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.height.equalTo(@44);
//        make.width.equalTo(@50);
//        make.right.equalTo(self.containView.mas_right).offset(-10);
//        make.centerY.equalTo(titleLabel.mas_centerY);
//    }];
    if(self.rechargeType == RechargeType_gf){
        if(self.channelIndex == 1 || self.channelIndex == 2){
            UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"rec_null"]];
            imgView.contentMode = UIViewContentModeScaleAspectFit;
            [self.containView addSubview:imgView];
            [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self.containView.mas_centerY);
                make.left.equalTo(self.containView).offset(60);
                make.right.equalTo(self.containView.mas_right).offset(-60);
            }];
            UILabel *tLabel = [[UILabel alloc] init];
            tLabel.backgroundColor = [UIColor clearColor];
            tLabel.textColor = COLOR_X(150, 150, 150);
            tLabel.font = [UIFont systemFontOfSize2:15];
            tLabel.text = @"敬请期待";
            tLabel.textAlignment = NSTextAlignmentCenter;
            [self.containView addSubview:tLabel];
            [tLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(imgView.mas_bottom).offset(15);
                make.centerX.equalTo(imgView.mas_centerX);
            }];
        }
    }
    
    NSDictionary *ddd = [self currentPayInfo];
    if(ddd){
        NSInteger y = 44 + 20;
        if(self.rechargeType == RechargeType_gf){
            if(self.channelIndex == 0){
                UILabel *idLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, y, self.containView.frame.size.width - 30, 20)];
                [self.containView addSubview:idLabel];
                idLabel.font = [UIFont systemFontOfSize2:15];
                idLabel.textColor = COLOR_X(60, 60, 60);
                
                NSString *s = [NSString stringWithFormat:@"用户ID：%@",[AppModel shareInstance].userInfo.userId];
                NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc]initWithString:s];
                NSRange rang = NSMakeRange(4, s.length - 4);
                [attributedStr addAttribute:NSForegroundColorAttributeName value:COLOR_X(140, 140, 140) range:NSMakeRange(rang.location, rang.length)];
                idLabel.attributedText = attributedStr;
                
                UIImageView *inputBg = [[UIImageView alloc] initWithFrame:CGRectMake(idLabel.frame.origin.x, idLabel.frame.size.height + y + 12, self.containView.frame.size.width - (idLabel.frame.origin.x) * 2, 44)];
                inputBg.backgroundColor = COLOR_X(244, 244, 244);
                inputBg.userInteractionEnabled = YES;
                inputBg.layer.masksToBounds = YES;
                inputBg.layer.cornerRadius = 4;
                [view addSubview:inputBg];
                
                UITextField *tf = [[UITextField alloc] init];
                tf.backgroundColor = [UIColor clearColor];
                tf.font = [UIFont systemFontOfSize2:16];
                tf.textColor = COLOR_X(60, 60, 60);
                tf.frame = CGRectMake(10, 0, inputBg.frame.size.width - 20, inputBg.frame.size.height);
                tf.delegate = self;
                tf.returnKeyType = UIReturnKeyDone;
                tf.placeholder = @"存款人姓名";
                [inputBg addSubview:tf];
                self.nameField = tf;
                
                inputBg = [[UIImageView alloc] initWithFrame:CGRectMake(inputBg.frame.origin.x, inputBg.frame.origin.y + inputBg.frame.size.height + 12, self.containView.frame.size.width - (inputBg.frame.origin.x) * 2, 44)];
                
                inputBg.userInteractionEnabled = YES;
                [view addSubview:inputBg];
                
                UILabel *tLabel = [[UILabel alloc] init];
                tLabel.backgroundColor = [UIColor clearColor];
                tLabel.textColor = COLOR_X(80, 80, 80);
                tLabel.font = [UIFont systemFontOfSize2:15];
                tLabel.text = @"存款金额";
                tLabel.textAlignment = NSTextAlignmentCenter;
                tLabel.frame = CGRectMake(0, 0, 70, inputBg.frame.size.height);
                [inputBg addSubview:tLabel];
                
                tLabel = [[UILabel alloc] init];
                tLabel.backgroundColor = [UIColor clearColor];
                tLabel.textColor = COLOR_X(80, 80, 80);
                tLabel.font = [UIFont systemFontOfSize2:15];
                tLabel.text = @"元";
                tLabel.textAlignment = NSTextAlignmentCenter;
                tLabel.frame = CGRectMake(inputBg.frame.size.width - 30, 0, 30, inputBg.frame.size.height);
                [inputBg addSubview:tLabel];
                
                tf = [[UITextField alloc] init];
                tf.backgroundColor = [UIColor clearColor];
                tf.font = [UIFont boldSystemFontOfSize2:16];
                tf.textColor = COLOR_X(70, 131, 215);
                tf.frame = CGRectMake(80, 0, inputBg.frame.size.width - 70 - 30 - 8, inputBg.frame.size.height);
                tf.delegate = self;
                tf.textAlignment = NSTextAlignmentRight;
                tf.returnKeyType = UIReturnKeyDone;
                tf.keyboardType = UIKeyboardTypeNumberPad;
                NSDictionary *dic = [self currentPayInfo];
                tf.placeholder = [NSString stringWithFormat:@"%zd-%zd",[dic[@"minAmount"] integerValue],[dic[@"maxAmount"] integerValue]];
                [inputBg addSubview:tf];
                self.moneyTextField = tf;
                
                lineView = [[UIView alloc] initWithFrame:CGRectMake(0, inputBg.frame.size.height - 0.5, inputBg.frame.size.width, 0.5)];
                lineView.backgroundColor = COLOR_X(220, 220, 220);
                [inputBg addSubview:lineView];
                
                tLabel = [[UILabel alloc] init];
                tLabel.backgroundColor = [UIColor clearColor];
                tLabel.textColor = COLOR_X(180, 180, 180);
                tLabel.font = [UIFont systemFontOfSize2:12];
                tLabel.text = @"请选择常用的支付方式，为您匹配专职代理";
                tLabel.frame = CGRectMake(inputBg.frame.origin.x, inputBg.frame.origin.y + inputBg.frame.size.height + 8, 300, 16);
                [view addSubview:tLabel];
                
                UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                [self.containView addSubview:btn];
                btn.titleLabel.font = [UIFont boldSystemFontOfSize2:17];
                [btn setTitle:@"下一步" forState:UIControlStateNormal];
                [btn addTarget:self action:@selector(submitAction) forControlEvents:UIControlEventTouchUpInside];
                [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                btn.layer.cornerRadius = 8.0f;
                btn.layer.masksToBounds = YES;
                [btn setBackgroundColor:MBTNColor];
                [btn delayEnable];
                btn.frame = CGRectMake(16, tLabel.frame.size.height + tLabel.frame.origin.y + 16, self.containView.frame.size.width - 32, 44);
                
                NSInteger bottom = btn.frame.size.height + btn.frame.origin.y;
                CGRect rect = self.containView.frame;
                rect.size.height = bottom + 15;
                self.containView.frame = rect;
            }
            
        }else{
            NSDictionary *dic = [self currentPayInfo];
            NSArray *array = [dic[@"allocationAmount"] componentsSeparatedByString:@","];
            NSInteger per = 3;
            NSInteger width = 70;
            if(SCREEN_WIDTH > 375)
                width = 84;
            NSInteger height = 40;
            NSInteger x = 0;
            NSInteger invX = (self.containView.frame.size.width - x * 2 - width * per)/(per + 1);
            NSInteger bottom = y;
            for (NSInteger i = 0; i < array.count; i ++) {
                UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                [btn setBackgroundImage:[[FunctionManager sharedInstance] imageWithColor:COLOR_X(193, 201, 220)] forState:UIControlStateNormal];
                [btn setBackgroundImage:[[FunctionManager sharedInstance] imageWithColor:COLOR_X(70, 131, 215)] forState:UIControlStateSelected];
                btn.tag = i;
                [btn addTarget:self action:@selector(selectMoney:) forControlEvents:UIControlEventTouchUpInside];
                btn.titleLabel.font = [UIFont systemFontOfSize2:17];
                [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [btn setTitle:array[i] forState:UIControlStateNormal];
                NSInteger a = i%per;
                NSInteger b = i/per;
                btn.frame = CGRectMake(x + invX * (a + 1) + width *a, b * (height + invX)+y, width, height);
                btn.layer.masksToBounds = YES;
                btn.layer.cornerRadius = 4;
                [view addSubview:btn];
                bottom = btn.frame.origin.y + btn.frame.size.height;
            }
            
            UIImageView *inputBg = [[UIImageView alloc] initWithFrame:CGRectMake(x + invX, bottom + invX + 3, self.containView.frame.size.width - (x + invX) * 2, 44)];
            
            inputBg.userInteractionEnabled = YES;
            [view addSubview:inputBg];
            
            UILabel *tLabel = [[UILabel alloc] init];
            tLabel.backgroundColor = [UIColor clearColor];
            tLabel.textColor = COLOR_X(80, 80, 80);
            tLabel.font = [UIFont systemFontOfSize2:15];
            tLabel.text = @"存款金额";
            tLabel.textAlignment = NSTextAlignmentCenter;
            tLabel.frame = CGRectMake(0, 0, 80, inputBg.frame.size.height);
            [inputBg addSubview:tLabel];
            
            tLabel = [[UILabel alloc] init];
            tLabel.backgroundColor = [UIColor clearColor];
            tLabel.textColor = COLOR_X(80, 80, 80);
            tLabel.font = [UIFont systemFontOfSize2:15];
            tLabel.text = @"元";
            tLabel.textAlignment = NSTextAlignmentCenter;
            tLabel.frame = CGRectMake(inputBg.frame.size.width - 30, 0, 30, inputBg.frame.size.height);
            [inputBg addSubview:tLabel];
            
            UITextField *tf = [[UITextField alloc] init];
            tf.backgroundColor = [UIColor clearColor];
            tf.font = [UIFont boldSystemFontOfSize2:16];
            tf.textColor = COLOR_X(70, 131, 215);
            tf.frame = CGRectMake(80, 0, inputBg.frame.size.width - 80 - 30, inputBg.frame.size.height);
            tf.delegate = self;
            tf.textAlignment = NSTextAlignmentRight;
            tf.returnKeyType = UIReturnKeyDone;
            tf.keyboardType = UIKeyboardTypeNumberPad;
            tf.placeholder = @"请输入金额";
            [inputBg addSubview:tf];
            self.moneyTextField = tf;
            
            lineView = [[UIView alloc] initWithFrame:CGRectMake(0, inputBg.frame.size.height - 0.5, inputBg.frame.size.width, 0.5)];
            lineView.backgroundColor = COLOR_X(220, 220, 220);
            [inputBg addSubview:lineView];
            
            bottom = inputBg.frame.size.height + inputBg.frame.origin.y;
            
            tLabel = [[UILabel alloc] init];
            tLabel.backgroundColor = [UIColor clearColor];
            tLabel.textColor = COLOR_X(180, 180, 180);
            tLabel.font = [UIFont systemFontOfSize2:13];
            tLabel.text = [NSString stringWithFormat:@"单笔存款限额(元)：%@-%@",dic[@"minAmount"],dic[@"maxAmount"]];
            tLabel.frame = CGRectMake(inputBg.frame.origin.x, bottom + 8, 250, 16);
            [view addSubview:tLabel];
            
            bottom = tLabel.frame.size.height + tLabel.frame.origin.y;
            
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [self.containView addSubview:btn];
            btn.titleLabel.font = [UIFont boldSystemFontOfSize2:17];
            [btn setTitle:@"支付" forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(submitAction) forControlEvents:UIControlEventTouchUpInside];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            btn.layer.cornerRadius = 8.0f;
            btn.layer.masksToBounds = YES;
            [btn setBackgroundColor:MBTNColor];//COLOR_X(244, 7, 0)
            [btn delayEnable];
            btn.frame = CGRectMake(16, bottom + 16, self.containView.frame.size.width - 32, 44);
            
            bottom = btn.frame.size.height + btn.frame.origin.y;
            CGRect rect = self.containView.frame;
            rect.size.height = bottom + 15;
            self.containView.frame = rect;
        }
    }
    rect = self.channelView.frame;
    if(rect.size.height < self.containView.frame.size.height){
        rect.size.height = self.containView.frame.size.height;
        self.channelView.frame = rect;
    }else if(rect.size.height > self.containView.frame.size.height + 10){
        rect.size.height = self.containView.frame.size.height + 10;
        self.channelView.frame = rect;
    }
    
    //重设tipView的长度
    //防止tipView不够长 底部漏出背景色，所以加长用白色遮挡
    rect = self.tipView.frame;
    rect.origin.y = self.containView.frame.origin.y + self.containView.frame.size.height;
    if(rect.origin.y + rect.size.height < self.scrollView.frame.size.height)
        rect.size.height = self.scrollView.frame.size.height - rect.origin.y;
    self.tipView.frame = rect;
    CGSize size = CGSizeMake(self.tipView.frame.origin.x + self.tipView.frame.size.width, self.tipView.frame.origin.y + self.tipView.frame.size.height);
    if(size.height < self.scrollView.frame.size.height + 1)
        size.height = self.scrollView.frame.size.height + 1;
    self.scrollView.contentSize = size;
}

-(void)selectMoney:(UIButton *)btn{
    [self.view endEditing:YES];
    if(btn.selected)
        return;
    self.tempBtn.selected = NO;
    btn.selected = YES;
    self.tempBtn = btn;
    self.moneyTextField.text = [btn titleForState:UIControlStateNormal];
    btn.selected = YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if(textField == self.moneyTextField){
        self.tempBtn.selected = NO;
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

-(void)submitAction{
    NSString *money = self.moneyTextField.text;
    if(money.length == 0){
        SVP_ERROR_STATUS(@"请输入金额");
        return;
    }
    if(![[FunctionManager sharedInstance] checkIsNum:money]){
        SVP_ERROR_STATUS(@"请输入正确的金额");
    }
    
    NSDictionary *dic = [self currentPayInfo];
    
    float aa = [money floatValue];
    NSInteger minMoney = [dic[@"minAmount"] integerValue];
    NSInteger maxMoney = [dic[@"maxAmount"] integerValue];
    if(dic[@"minAmount"]){
        if(aa < minMoney){
            NSString *tip = [NSString stringWithFormat:@"存款金额最小%zd元",minMoney];
            SVP_ERROR_STATUS(tip);
            return;
        }
    }
    if(dic[@"maxAmount"]){
        if(aa > maxMoney){
            NSString *tip = [NSString stringWithFormat:@"存款金额最大%zd元",maxMoney];
            SVP_ERROR_STATUS(tip);
            return;
        }
    }
    if(self.rechargeType != RechargeType_gf)
        [self openByWeb];
    else{
        if(self.nameField.text.length == 0){
            SVP_ERROR_STATUS(@"请输入存款人姓名");
            return;
        }
        [self.view endEditing:YES];
        SVP_SHOW;
        WEAK_OBJ(weakSelf, self);

        [NET_REQUEST_MANAGER submitRechargeInfoWithId:dic[@"id"] money:self.moneyTextField.text name:self.nameField.text type:[dic[@"type"] integerValue] typeCode:[dic[@"typeCode"] integerValue] userId:[AppModel shareInstance].userInfo.userId success:^(id object) {
            SVP_DISMISS;
           [weakSelf goToCheck:object[@"data"]];
        } fail:^(id object) {
            [[FunctionManager sharedInstance] handleFailResponse:object];
        }];
    }
}

-(void)openByWeb{
    NSDictionary *dic = [self currentPayInfo];
    NSString *url = [NSString stringWithFormat:@"%@%@?userId=%@&amount=%@&id=%@&typeCode=%zd",[AppModel shareInstance].serverUrl,dic[@"url"],[AppModel shareInstance].userInfo.userId,self.moneyTextField.text,dic[@"id"],[dic[@"typeCode"] integerValue]];
    WebViewController *vc = [[WebViewController alloc] initWithUrl:url];
    vc.navigationItem.title = @"充值";
    [self.navigationController pushViewController:vc animated:YES];
}

-(NSDictionary *)currentPayInfo{
    NSArray *arr = nil;
    if(self.rechargeType == RechargeType_zhiFuBao)
        arr = [self.infoDic objectForKey:@"alipayChanels"];
    else if(self.rechargeType == RechargeType_yinLian)
        arr = [self.infoDic objectForKey:@"unionPayChanels"];
    else if(self.rechargeType == RechargeType_weiXin)
        arr = [self.infoDic objectForKey:@"wechatChanels"];
    else if(self.rechargeType == RechargeType_gf)
        arr = [self.infoDic objectForKey:@"bankPayChanels"];
    if(arr.count <= self.channelIndex)
        return nil;
    NSDictionary *dic = arr[self.channelIndex];
    return dic;
}

#pragma mark - 客服弹框  常见问题
- (void)keFu{
    NSString *imageUrl = [AppModel shareInstance].commonInfo[@"customer.service.window"];
    if (imageUrl.length == 0) {
        [self keFu2];
        return;
    }
    CustomerServiceAlertView *view = [[CustomerServiceAlertView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [view updateView:@"常见问题" imageUrl:imageUrl];
    __weak __typeof(self)weakSelf = self;
    view.customerServiceBlock = ^{
        [weakSelf keFu2];
    };
    [view showInView:self.view];
}

-(void)keFu2{
    WebViewController *vc = [[WebViewController alloc] initWithUrl:[AppModel shareInstance].commonInfo[@"pop"]];
    vc.title = @"在线客服";
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)goToCheck:(NSDictionary *)dict{
    NSDictionary *dic = [self currentPayInfo];
    DepositOrderController *vc = [[DepositOrderController alloc] init];
    vc.titleStr = dic[@"title"];
    vc.infoDic = dict;
    vc.type = [dic[@"type"] integerValue];
    [self.navigationController pushViewController:vc animated:YES];
}

-(UIView *)tipView{
    if(_tipView == nil){
        UIView *tipView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 100)];
        tipView.backgroundColor = [UIColor whiteColor];
        _tipView = tipView;
        [self.scrollView addSubview:_tipView];
        
        UILabel *tLabel = [[UILabel alloc] init];
        tLabel.backgroundColor = [UIColor clearColor];
        tLabel.textColor = COLOR_X(80, 80, 80);
        tLabel.font = [UIFont systemFontOfSize2:14];
        [_tipView addSubview:tLabel];
        NSInteger x = 20;
        if(SCREEN_WIDTH == 320)
            x = 15;
        tLabel.frame = CGRectMake(x, 15, SCREEN_WIDTH - x * 2, 20);
        tLabel.text = @"温馨提示";
        
        UILabel *tipLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(x, tLabel.frame.origin.y + tLabel.frame.size.height, tLabel.frame.size.width, 150)];
        tipLabel2.backgroundColor = [UIColor clearColor];
        tipLabel2.textColor = COLOR_X(190, 190, 190);
        tipLabel2.font = [UIFont systemFontOfSize:14];
        tipLabel2.numberOfLines = 0;
        NSString *s = [AppModel shareInstance].commonInfo[@"pay_rule"];
        tipLabel2.text = s;
        CGSize size = [[FunctionManager sharedInstance] getFitSizeWithLabel:tipLabel2];
        CGRect rect = tipLabel2.frame;
        rect.size.height = size.height + 15;
        tipLabel2.frame = rect;
        [_tipView addSubview:tipLabel2];
        
        rect = tipView.frame;
        rect.size.height = tipLabel2.frame.origin.y + tipLabel2.frame.size.height + 8;
        _tipView.frame = rect;
    }
    
    return _tipView;
}

-(NSString *)numberToZH:(NSString *)number{
    NSDictionary *dic = @{@"0":@"",@"1":@"一",@"2":@"二",@"3":@"三",@"4":@"四",@"5":@"五",@"6":@"六",@"7":@"七",@"8":@"八",@"9":@"九",@"10":@"十"};
    NSInteger num = [number integerValue];
    if(num <= 10)
        return dic[number];
    
    NSInteger geWei = num % 10;
    NSInteger shiWei = num / 10;
    
    NSString *getWeiString = [NSString stringWithFormat:@"%zd",geWei];
    NSString *value1 = dic[getWeiString];
    NSString *shiWeiString = [NSString stringWithFormat:@"%zd",shiWei];
    NSString *value2 = dic[shiWeiString];
    if(shiWei < 2)
        return [NSString stringWithFormat:@"十%@",value1];
    else
        return [NSString stringWithFormat:@"%@十%@",value2,value1];
}

-(void)reportAction{
    WEAK_OBJ(weakSelf, self);
    ReportView *reportView = [ReportView createInstanceWithView:nil];
    reportView.selectBlock = ^(id object) {
        [weakSelf keFu2];
    };
}
@end
