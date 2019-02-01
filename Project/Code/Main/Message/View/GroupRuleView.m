//
//  GroupRuleView.m
//  Project
//
//  Created by Mike on 2019/1/12.
//  Copyright © 2019 Mike. All rights reserved.
//

#import "GroupRuleView.h"
#import "MessageItem.h"
#import "NSString+Size.h"

@interface GroupRuleView()
//
@property (nonatomic,strong)  UIControl *backControl;

@property (nonatomic,strong)  UIView *backView;

// 
@property (nonatomic,strong) UIImageView *headIcon;
@property (nonatomic,strong) UIImageView *contentImageView;


@property (nonatomic,strong) UIButton *okButton;
@property (nonatomic,strong) UILabel *nameLabel;
@property (nonatomic,strong) UILabel *contentLabel;




@end

@implementation GroupRuleView



- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self initSubviews];
    }
    return self;
}




- (void)showInView:(UIView *)view{
    if (self == nil) {
        return;
    }
    _backView.transform = CGAffineTransformMakeScale(0.4, 0.4);
    _backView.alpha = 0.0;
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    _backControl.alpha = 0.0;
    [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0.5 options:0 animations:^{
        // 放大
        self->_backView.transform = CGAffineTransformMakeScale(1, 1);
        self->_backControl.alpha = 0.6;
        self->_backView.alpha = 1.0;
        
    } completion:nil];
    
}

#pragma mark - subView
- (void)initSubviews {
    
    _backControl = [[UIControl alloc]initWithFrame:self.bounds];
    [self addSubview:_backControl];
    _backControl.backgroundColor = ApHexColor(@"#000000", 0.6);
    [_backControl addTarget:self action:@selector(disMissView) forControlEvents:UIControlEventTouchUpInside];
    
    CGFloat marginWidth = 12;
    //    _backView = [[UIView alloc]initWithFrame:CGRectMake(marginWidth, y, w, h)];
    _backView = [[UIView alloc] init];
    [self addSubview:_backView];
    _backView.backgroundColor = [UIColor whiteColor];
    _backView.layer.cornerRadius = 8;
    _backView.layer.masksToBounds = YES;
    
    UITapGestureRecognizer *tapGesturRecognizer=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapActionView:)];
    [_backView addGestureRecognizer:tapGesturRecognizer];
    
    [_backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.backControl.mas_left).offset(marginWidth);
        make.right.mas_equalTo(self.backControl.mas_right).offset(-marginWidth);
        make.centerY.mas_equalTo(self.backControl.mas_centerY);
        make.height.mas_equalTo(230);
    }];
    
    
    UIView *topView = [[UIView alloc] init];
    topView.backgroundColor = [UIColor colorWithRed:1.000 green:0.208 blue:0.373 alpha:1.000];
    [_backView addSubview:topView];
    
    [topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self.backView);
        make.height.mas_equalTo(44);
    }];
    
    UILabel *titLabel = [UILabel new];
    titLabel.text = @"群规";
    [topView addSubview:titLabel];
    titLabel.font = [UIFont boldSystemFontOfSize2:17];
    titLabel.textColor = [UIColor whiteColor];
    
    [titLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(topView.mas_centerX);
        make.centerY.equalTo(topView.mas_centerY);
    }];
    
    _headIcon = [UIImageView new];
    _headIcon.backgroundColor = [UIColor yellowColor];
    [_backView addSubview:_headIcon];
    _headIcon.layer.cornerRadius = 5;
    _headIcon.layer.masksToBounds = YES;
    
    [_headIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.backView.mas_left).offset(22);
        make.top.equalTo(topView.mas_bottom).offset(marginWidth);
        make.width.height.equalTo(@(40));
    }];
    
    UILabel *nameLabel = [UILabel new];
    [topView addSubview:nameLabel];
    _nameLabel = nameLabel;
    nameLabel.font = [UIFont boldSystemFontOfSize2:16];
    nameLabel.textColor = Color_3;
    
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.headIcon.mas_centerY);
        make.left.equalTo(self.headIcon.mas_right).offset(marginWidth);
    }];
    
    UIImageView *contentImageView = [UIImageView new];
    contentImageView.image = [[UIImage imageNamed:@"mess_groupRule"] resizableImageWithCapInsets:UIEdgeInsetsMake(20, 35, 10, 10) resizingMode:UIImageResizingModeStretch];
    //    contentImageView.image = [UIImage imageNamed:@"mess_groupRule"];
    
    contentImageView.backgroundColor = [UIColor darkGrayColor];
    [_backView addSubview:contentImageView];
    _contentImageView = contentImageView;
    //    contentImageView.layer.cornerRadius = 5;
    //    contentImageView.layer.masksToBounds = YES;
    
    [contentImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.headIcon.mas_left);
        make.top.equalTo(self.headIcon.mas_bottom).offset(CD_Scal(2, 667));
        make.right.equalTo(self.backView.mas_right).offset(-22);
        make.height.mas_equalTo(100);
    }];
    
    UILabel *contentLabel = [UILabel new];
    contentLabel.numberOfLines = 0;
    [contentImageView addSubview:contentLabel];
    _contentLabel = contentLabel;
    contentLabel.font = [UIFont systemFontOfSize2:14];
    contentLabel.textColor = [UIColor grayColor];
    
    [contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(contentImageView.mas_top).offset(15);
        make.left.equalTo(contentImageView.mas_left).offset(10);
        make.right.equalTo(contentImageView.mas_right).offset(-10);
    }];
    
    
    _okButton = [UIButton new];
    [_backView addSubview:_okButton];
    _okButton.layer.cornerRadius = 8;
    _okButton.backgroundColor = [UIColor colorWithRed:1.000 green:0.208 blue:0.373 alpha:1.000];
    _okButton.titleLabel.font = [UIFont boldSystemFontOfSize2:16];
    [_okButton addTarget:self action:@selector(onOkButton:) forControlEvents:UIControlEventTouchUpInside];
    [_okButton setTitle:@"确认" forState:UIControlStateNormal];
    [_okButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [_okButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.backView.mas_bottom).offset(-10);
        make.left.equalTo(self.backView.mas_left).offset(50);
        make.right.equalTo(self.backView.mas_right).offset(-50);
        make.height.mas_equalTo(44);
        make.top.equalTo(contentImageView.mas_bottom).offset(10);
    }];
    
    
    
    //    _closeButton = [UIButton new];
    //    [_redView addSubview:_closeButton];
    //    _closeButton.titleLabel.font = [UIFont systemFontOfSize2:14];
    //    [_closeButton addTarget:self action:@selector(actionCloseButton) forControlEvents:UIControlEventTouchUpInside];
    //    [_closeButton setBackgroundImage:[UIImage imageNamed:@"mess_close"] forState:UIControlStateNormal];
    //    [_closeButton setTitleColor:HexColor(@"#FFE6A2") forState:UIControlStateNormal];
    //    [_closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.left.and.top.mas_equalTo(self->_redView).offset(15);
    //        make.size.mas_equalTo(CGSizeMake(22, 22));
    //    }];
    
}

- (void)updateView:(MessageItem *)messageItem {
    
    [_headIcon cd_setImageWithURL:[NSURL URLWithString:[NSString cdImageLink:messageItem.avatar]] placeholderImage:[UIImage imageNamed:@"user-default"]];
    _nameLabel.text = messageItem.nick;
    _contentLabel.text = messageItem.rule;
    
    CGFloat height = [messageItem.rule heightWithFont:[UIFont systemFontOfSize2:14] constrainedToWidth:SCREEN_WIDTH - (12*2 +22*2+10*2)];
    
    [_backView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(height+190);
    }];
    [self.contentImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(height + 35);
    }];
}

- (void)onOkButton:(UIButton *)sender {
    [self disMissView];
}

-(void)tapActionView:(UITapGestureRecognizer *)tap {
    //    if (self.isClickedDisappear) {
    //        [self disMissRedView];
    //    }
}

- (void)disMissView {
    [UIView animateWithDuration:0.25 animations:^{
        self->_backView.transform = CGAffineTransformMakeScale(0.2, 0.2);
        self->_backView.alpha = 0.0;
        self->_backControl.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (finished) {
            [self removeFromSuperview];
        }
    }];
}



@end
