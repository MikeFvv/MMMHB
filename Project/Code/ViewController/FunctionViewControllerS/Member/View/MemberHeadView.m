//
//  MemberHeadView.m
//  Project
//
//  Created by mini on 2018/8/1.
//  Copyright © 2018年 CDJay. All rights reserved.
//

#import "MemberHeadView.h"

@interface MemberHeadView(){
    UIImageView *_headIcon;
    UILabel *_nickName;
    UILabel *_integral;
    UILabel *_account;
    UIView *_sexBackView;
    UIImageView *_sexIcon;
}
@end

@implementation MemberHeadView

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

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
    [_headIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(12));
        make.height.width.equalTo(@(50));
        make.centerY.equalTo(self);
    }];
    
    [_nickName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self->_headIcon.mas_right).offset(12);
        make.top.equalTo(self->_headIcon.mas_top).offset(-5);
    }];
    
    [_sexBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self->_nickName.mas_right).offset(6);
        make.centerY.equalTo(self->_nickName);
        make.width.height.equalTo(@(15));
    }];
    
    [_sexIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self->_sexBackView);
    }];
    
    [_integral mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self->_headIcon.mas_right).offset(12);
        make.top.equalTo(self->_nickName.mas_bottom).offset(5);
    }];
    
    [_account mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self->_headIcon.mas_right).offset(12);
        make.top.equalTo(self->_integral.mas_bottom).offset(4);
    }];
}

#pragma mark ----- subView
- (void)initSubviews{
    _headIcon = [UIImageView new];
    [self addSubview:_headIcon];
    _headIcon.layer.cornerRadius = 25;
    _headIcon.layer.masksToBounds = YES;
    
    _nickName = [UILabel new];
    [self addSubview:_nickName];
    _nickName.font = [UIFont scaleFont:15];
    
    _sexBackView = [UIView new];
    [self addSubview:_sexBackView];
    _sexBackView.backgroundColor = SexBack;
    _sexBackView.layer.cornerRadius = 7.5;
    
    _sexIcon = [UIImageView new];
    [_sexBackView addSubview:_sexIcon];
    
    _integral = [UILabel new];
    [self addSubview:_integral];
    _integral.font = [UIFont scaleFont:12];
    _integral.textColor = COLOR_Y(160);

    _account = [UILabel new];
    [self addSubview:_account];
    _account.font = [UIFont scaleFont:12];
    _account.textColor = [UIColor lightGrayColor];
    _account.textColor = COLOR_Y(160);
}

- (void)update{
    UserModel *user = APP_MODEL.user;
    _nickName.text = user.userNick;
    _integral.text = (user.userBalance)?[NSString stringWithFormat:@"余额：%@ 元",user.userBalance]:@"余额：0.00 元";
    _account.text = [NSString stringWithFormat:@"账号：%@",user.userId];
    [_headIcon cd_setImageWithURL:[NSURL URLWithString:[NSString cdImageLink:user.userAvatar]] placeholderImage:[UIImage imageNamed:@"user-default"]];
    _sexIcon.image = (user.userGender == 1)?[UIImage imageNamed:@"male"]:[UIImage imageNamed:@"female"];
}

@end
