//
//  CustomerServiceAlertView.m
//  Project
//
//  Created by Mike on 2019/3/19.
//  Copyright © 2019 CDJay. All rights reserved.
//

#import "CustomerServiceAlertView.h"

@interface CustomerServiceAlertView()<CAAnimationDelegate>

@property (nonatomic,strong) UIControl *backControl;
@property (nonatomic,strong) UIView *contentView;

@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) UIImageView *backImageView;

@end

@implementation CustomerServiceAlertView


- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self initSubviews];
    }
    return self;
}


#pragma mark - subView
- (void)initSubviews {
    
    _backControl = [[UIControl alloc]initWithFrame:self.bounds];
    [self addSubview:_backControl];
    _backControl.backgroundColor = ApHexColor(@"#000000", 0.6);
    [_backControl addTarget:self action:@selector(onbackControl) forControlEvents:UIControlEventTouchUpInside];
    
    CGFloat marginWidth = 20;
    
    CGFloat w = CDScreenWidth-marginWidth * 2;
    CGFloat h = (CDScreenWidth-marginWidth)/0.9;
    CGFloat y = CDScreenHeight /2 - h/2;
    
    _contentView = [[UIView alloc] initWithFrame:CGRectMake(marginWidth, y, w, h)];
    _contentView.backgroundColor = [UIColor colorWithRed:250 green:251 blue:252 alpha:1];
    _contentView.layer.backgroundColor = [UIColor colorWithRed:0.996 green:0.969 blue:0.898 alpha:1.000].CGColor;
    _contentView.layer.cornerRadius = 10;
    _contentView.clipsToBounds = YES;
    _contentView.layer.masksToBounds = YES;
    //    _contentView.backgroundColor = [UIColor redColor];
    [self addSubview:_contentView];
    
    UIView *topView = [[UIView alloc] init];
    topView.backgroundColor = MBTNColor;
    [_contentView addSubview:topView];
    [topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self->_contentView);
        make.height.mas_equalTo(50);
    }];
    
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"-";
    titleLabel.font = [UIFont vvBoldFontOfSize:18];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [topView addSubview:titleLabel];
    _titleLabel = titleLabel;
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(topView);
    }];
    
    
    UIButton *closeBtn = [[UIButton alloc] init];
    [closeBtn addTarget:self action:@selector(didClickCloseBtn) forControlEvents:UIControlEventTouchUpInside];
    closeBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [closeBtn setBackgroundImage:[UIImage imageNamed:@"message_close"] forState:UIControlStateNormal];
    [topView addSubview:closeBtn];
    
    [closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(topView);
        make.left.mas_equalTo(topView.mas_left).offset(12);
        make.size.mas_equalTo(CGSizeMake(22, 22));
    }];
    
    UIButton *csBtn = [[UIButton alloc] init];
    [csBtn setTitle:@"在线客服" forState:UIControlStateNormal];
    [csBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [csBtn addTarget:self action:@selector(onCSBtn) forControlEvents:UIControlEventTouchUpInside];
    csBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    csBtn.backgroundColor = MBTNColor;
    csBtn.layer.cornerRadius = 5;
    [_contentView addSubview:csBtn];
    
    [csBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-10);
        make.right.mas_equalTo(self.contentView.mas_right).offset(-12);
        make.size.mas_equalTo(CGSizeMake(100, 40));
    }];
    
    UIImageView *backImageView = [[UIImageView alloc] init];
//    backImageView.image = [UIImage imageNamed:@"-"];
    [_contentView addSubview:backImageView];
    _backImageView = backImageView;
    
    [backImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(topView.mas_bottom);
        make.left.right.equalTo(self.contentView);
        make.bottom.mas_equalTo(csBtn.mas_top).offset(-5);
    }];
    
}

- (void)updateView:(NSString *)title imageUrl:(NSString *)imageUrl {
    self.titleLabel.text = title;
    
    [self.backImageView cd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@""]];
}

- (void)onCSBtn {
    if (self.customerServiceBlock) {
        self.customerServiceBlock();
    }
    [self disMissView];
}

- (void)didClickCloseBtn {
    [self disMissView];
}

- (void)showInView:(UIView *)view{
    if (self == nil) {
        return;
    }
    _contentView.transform = CGAffineTransformMakeScale(0.4, 0.4);
    _contentView.alpha = 0.0;
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    _backControl.alpha = 0.0;
    [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0.5 options:0 animations:^{
        // 放大
        self->_contentView.transform = CGAffineTransformMakeScale(1, 1);
        self->_backControl.alpha = 0.6;
        self->_contentView.alpha = 1.0;
        
    } completion:nil];
    
}


- (void)disMissView {
    
    if (self.disMissViewBlock) {
        self.disMissViewBlock();
    }
    [UIView animateWithDuration:0.25 animations:^{
        self->_contentView.transform = CGAffineTransformMakeScale(0.2, 0.2);
        self->_contentView.alpha = 0.0;
        self->_backControl.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (finished) {
            [self removeFromSuperview];
        }
    }];
}


- (void)onbackControl {
    [self disMissView];
}

@end

