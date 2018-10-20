//
//  TopupBarView.m
//  Project
//
//  Created by mini on 2018/8/14.
//  Copyright © 2018年 CDJay. All rights reserved.
//

#import "TopupBarView.h"
#import "PayButton.h"

#define Paytype 10000

@interface TopupBarView(){
    UIView *_inputView;
    UITextField *_moneyField;
    UILabel *_iLabel;
    UILabel *_pLabel;
    NSArray *_payMethods;
    NSInteger _selectMethod;
}
@end

@implementation TopupBarView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+ (TopupBarView *)topupBar{
    return [[TopupBarView alloc]initWithFrame:CGRectMake(0, 0, CDScreenWidth, 78+20+60*3)];
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self initData];
        [self initSubviews];
        [self initLayout];
    }
    return self;
}


#pragma mark ----- Data
- (void)initData{
    _selectMethod = 0;
    _payMethods = @[@{@"img":@"pay-qq",@"title":@"QQ支付",@"type":@"1"},@{@"img":@"pay-wy",@"title":@"网银快捷",@"type":@"2"},@{@"img":@"pay-wx",@"title":@"微信支付",@"type":@"3"},@{@"img":@"pay-zfb",@"title":@"支付宝",@"type":@"4"},@{@"img":@"pay-zfb",@"title":@"面对面",@"type":@"5"},@{@"img":@"pay-yl",@"title":@"银联网关",@"type":@"6"}];
}


#pragma mark ----- Layout
- (void)initLayout{
    [_inputView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self);
        make.height.equalTo(@(48));
    }];
    
    [_iLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self->_inputView.mas_left).offset(15);
        make.centerY.equalTo(self->_inputView);
    }];
    
    [_moneyField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self->_inputView.mas_right).offset(-15);
        make.bottom.top.equalTo(self->_inputView);
        make.width.equalTo(@(CDScreenWidth*0.65));
    }];
}

#pragma mark ----- subView
- (void)initSubviews{
    
    _inputView = [UIView new];
    [self addSubview:_inputView];
    _inputView.backgroundColor = [UIColor whiteColor];
    
    _iLabel = [UILabel new];
    [_inputView addSubview:_iLabel];
    _iLabel.text = @"支付金额";
    _iLabel.font = [UIFont scaleFont:14];
    
    UILabel *unit = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 30, 20)];
    [self addSubview:unit];
    unit.font = [UIFont scaleFont:14];
    unit.text = @"元";
    unit.textAlignment = NSTextAlignmentRight;
    unit.textColor =  HexColor(@"#151515");
    
    _moneyField = [UITextField new];
    [_inputView addSubview:_moneyField];
    _moneyField.font = [UIFont scaleFont:13];
    _moneyField.placeholder = @"请输入金额";
    _moneyField.rightView = unit;
    _moneyField.rightViewMode = UITextFieldViewModeAlways;
    _moneyField.textAlignment = NSTextAlignmentRight;
    _moneyField.keyboardType = UIKeyboardTypeDecimalPad;
    
    _pLabel = [UILabel new];
    [self addSubview:_pLabel];
    _pLabel.textColor = Color_6;
    _pLabel.text = @"支付方式";
    
    CGFloat y = 78;
    CGFloat w = (CDScreenWidth -50)/2,h = 60;
    CGFloat lm = 20, rm = 10;
    for (int i = 0 ; i<_payMethods.count; i++) {
        PayButton *btn = [[PayButton alloc]initWithFrame:CGRectMake(15+(lm+w)*(i%2), y+(h+rm)*(i/2), w, h)];
        [self addSubview:btn];
        [btn addTarget:self action:@selector(action_click:) forControlEvents:UIControlEventTouchUpInside];
        btn.payImg = [UIImage imageNamed:_payMethods[i][@"img"]];
        btn.payTitle = _payMethods[i][@"title"];
        btn.tag = Paytype + i ;
        if (i == _selectMethod) {
            [btn cd_SetState:YES];
        }
    }
}

#pragma mark action
- (void)action_click:(PayButton *)sender{
    [_moneyField resignFirstResponder];
    NSInteger s = sender.tag - Paytype;
    if (s == _selectMethod) {
        return;
    }
    PayButton *old = [self viewWithTag:_selectMethod+Paytype];
    [old cd_SetState:NO];
    [sender cd_SetState:YES];
    _selectMethod = s;
}

- (NSString *)money{
    return _moneyField.text;
}

- (NSInteger)type{
    return [_payMethods[_selectMethod][@"type"]integerValue];
}

@end
