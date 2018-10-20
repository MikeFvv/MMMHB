//
//  BillHeadView.m
//  Project
//
//  Created by mini on 2018/8/14.
//  Copyright © 2018年 CDJay. All rights reserved.
//

#import "BillHeadView.h"

#define BIMGTAG 1000
#define BClickTAG 1000
#define BLABELTAG 2000
#define BSCAL 2.28

@implementation BillHeadView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+ (BillHeadView *)headView{
    CGFloat w = (CDScreenWidth-1)/2;
    CGFloat h = w / BSCAL;
    BillHeadView *headView = [[BillHeadView alloc]initWithFrame:CGRectMake(0, 0, CDScreenWidth, h*3+2)];
    return headView;
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
    
}


#pragma mark ----- Layout
- (void)initLayout{
    
}

#pragma mark ----- subView
- (void)initSubviews{
    UserModel *user = APP_MODEL.user;
    CGFloat w = (CDScreenWidth-1)/2;
    CGFloat h = w / BSCAL;
    NSArray *list = @[@"my-icon1",@"my-icon2",@"my-icon3",@"my-icon4",@"my-icon5",@"my-icon6"];
    NSArray *titles = @[user.userBalance,user.userFrozenMoney,@"",@"",user.userBalance,@"全部"];
    for (int i = 0; i<list.count; i++) {
        UIButton *b = [self item:list[i] title:titles[i] frame:CGRectMake((1+w)*(i%2), (1+h)*(i/2), w, h)];//[[UIButton alloc]initWithFrame:];
        b.tag = BClickTAG + i;
        [b addTarget:self action:@selector(handle:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:b];
    }
    
}

- (UIButton *)item:(NSString *)img title:(NSString *)title frame:(CGRect)rect{
    UIButton *btn = [[UIButton alloc]initWithFrame:rect];
    btn.backgroundColor = [UIColor whiteColor];
    UIImageView *imgView = [UIImageView new];
    [btn addSubview:imgView];
    imgView.image = [UIImage imageNamed:img];
    imgView.tag = BIMGTAG;
    
    [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(btn);
        make.centerY.equalTo(btn.mas_top).offset(33);
    }];
    
    UILabel *label = [UILabel new];
    [btn addSubview:label];
    label.textColor = Color_0;
    label.font = [UIFont scaleFont:13];
    label.numberOfLines = 0;
    label.tag = BLABELTAG;
    label.text = title;
    label.textAlignment = NSTextAlignmentCenter;
    
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(btn.mas_left).offset(4);
        make.right.equalTo(btn.mas_right).offset(-4);
        make.top.equalTo(imgView.mas_bottom).offset(4);
        make.bottom.greaterThanOrEqualTo(btn.mas_bottom).offset(-4);
    }];
    
    return btn;
}

- (void)handle:(UIButton *)sender{
    if (sender.tag == BClickTAG+2) {//开始时间
        if (self.beginChange) {
            self.beginChange(nil);
        }
    }
    
    if (sender.tag == BClickTAG+3) {//结束时间
        if (self.endChange) {
            self.endChange(nil);
        }
    }
    if (sender.tag == BClickTAG+5) {//类型
        UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"全部",@"充值",@"转账",@"扣除",@"红包发布",@"提现", nil];
        [sheet showInView:[UIApplication sharedApplication].keyWindow.rootViewController.view];
    }
}

- (void)setBeginTime:(NSString *)beginTime{
    _beginTime = beginTime;
    [self update:2+BClickTAG content:[NSString stringWithFormat:@"开始时间：%@",beginTime]];
}

- (void)setEndTime:(NSString *)endTime{
    _endTime = endTime;
    [self update:3+BClickTAG content:[NSString stringWithFormat:@"结束时间：%@",endTime]];
}

- (void)update:(NSInteger)sender content:(NSString *)content{
    UIButton *btn = [self viewWithTag:sender];
    UILabel *label = [btn viewWithTag:BLABELTAG];
    label.text = content;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSLog(@"t:%ld",buttonIndex);
    NSArray *list = @[@"全部",@"充值",@"转账",@"扣除",@"红包发布",@"提现"];
    if (buttonIndex>list.count-1) {
        return;
    }
    
    [self update:BClickTAG+5 content:list[buttonIndex]];
    if (self.TypeChange) {
        self.TypeChange(buttonIndex);
    }
}

@end
