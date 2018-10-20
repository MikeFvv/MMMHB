//
//  EnvelopAnimationView.m
//  Project
//
//  Created by mini on 2018/8/13.
//  Copyright © 2018年 CDJay. All rights reserved.
//

#import "EnvelopAnimationView.h"
#import "EnvelopBackImg.h"
#import "EnvelopeNet.h"

@interface EnvelopAnimationView()<CAAnimationDelegate>{
    EnvelopBackImg *_redView;
    UIControl *_backControl;
    UIImageView *_headIcon;
    UIButton *_open;
    UILabel *_contentLabel;
    UIButton *_detailButton;
    UILabel *_nameLabel;
    id _obj;
}
@end

@implementation EnvelopAnimationView

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
        [self initLayout];
        [self initSubviews];
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
    
    _backControl = [[UIControl alloc]initWithFrame:self.bounds];
    [self addSubview:_backControl];
    _backControl.backgroundColor = ApHexColor(@"#000000", 0.4);
    [_backControl addTarget:self action:@selector(disMiss) forControlEvents:UIControlEventTouchUpInside];
    
    CGFloat w = CDScreenWidth-25;
    CGFloat h = (CDScreenWidth-25)/0.8125;
    CGFloat y = CDScreenHeight /2 - h/2;
    _redView = [[EnvelopBackImg alloc]initWithFrame:CGRectMake(12.5, y, w, h)];
    [_backControl addSubview:_redView];
    _redView.backgroundColor = HexColor(@"#C5513F");
    _redView.layer.cornerRadius = 8;
    _redView.layer.masksToBounds = YES;
    
    _open = [[UIButton alloc]initWithFrame:CGRectMake(w/2-40, h*0.665-40, 80, 80)];
    [_redView addSubview:_open];
    _open.layer.cornerRadius = 40;
    _open.layer.masksToBounds = YES;
    _open.backgroundColor = HexColor(@"#FFE6A2");
    [_open setTitle:@"开" forState:UIControlStateNormal];
    [_open setTitleColor:HexColor(@"#4D4D4D") forState:UIControlStateNormal];
    _open.titleLabel.font = [UIFont scaleFont:40];
    [_open addTarget:self action:@selector(openRedPacketAction) forControlEvents:UIControlEventTouchUpInside];
    
    _headIcon = [UIImageView new];
    [_redView addSubview:_headIcon];
    _headIcon.layer.cornerRadius = CD_Scal(58, 667)/2;
    _headIcon.layer.masksToBounds = YES;
    
    [_headIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self->_redView);
        make.top.equalTo(self->_redView.mas_top).offset(CD_Scal(60, 667));
        make.width.height.equalTo(@(CD_Scal(58, 667)));
    }];
    
    _nameLabel = [UILabel new];
    [_redView addSubview:_nameLabel];
    _nameLabel.font = [UIFont scaleFont:17];
    _nameLabel.textColor = HexColor(@"#FFE6A2");
    
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self -> _headIcon.mas_bottom).offset(CD_Scal(7, 667));
        make.centerX.equalTo(self -> _redView);
    }];
    
    _contentLabel = [UILabel new];
    [_redView addSubview:_contentLabel];
    _contentLabel.numberOfLines = 0;
    _contentLabel.font = [UIFont scaleFont:14];
    _contentLabel.textAlignment = NSTextAlignmentCenter;
    _contentLabel.textColor = HexColor(@"#FFE6A2");
    [_contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self->_redView);
        make.top.equalTo(self->_nameLabel.mas_bottom).offset(CD_Scal(4, 667));
    }];
    
    
    _detailButton = [UIButton new];
    [_redView addSubview:_detailButton];
    _detailButton.titleLabel.font = [UIFont scaleFont:14];
    [_detailButton addTarget:self action:@selector(actionDetail) forControlEvents:UIControlEventTouchUpInside];
    [_detailButton setTitle:@"查看详情" forState:UIControlStateNormal];
    [_detailButton setTitleColor:HexColor(@"#FFE6A2") forState:UIControlStateNormal];//:@"查看详情"
    [_detailButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self->_redView.mas_bottom).offset(-11);
        make.centerX.equalTo(self->_redView);
    }];
}


- (void)showInView:(UIView *)view{
    if (self == nil) {
        return;
    }
    _redView.transform = CGAffineTransformMakeScale(0.1, 0.1);
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    
    [UIView animateWithDuration:0.6 delay:0 usingSpringWithDamping:0.4 initialSpringVelocity:0.6 options:0 animations:^{
        // 放大
        self->_redView.transform = CGAffineTransformMakeScale(1, 1);
        
    } completion:nil];
    
    
}

- (void)animation{
    [_open setTitle:nil forState:UIControlStateNormal];
    [_open setImage:[UIImage imageNamed:@"coins-icon"] forState:UIControlStateNormal];
    [_open.layer addAnimation:[self confirmViewRotateInfo] forKey:@"transform"];
}

- (void)remoAnimation{
    [_open.layer removeAllAnimations];
    [self disMiss];
    if (self.block) {
        self.block();
    }
}

- (void)actionDetail{
    [self disMiss];
    if (self.detail) {
        self.detail();
    }
}

- (void)openRedPacketAction{
    [self animation];
    [EnvelopeNet getEnvelop:@{@"uid":APP_MODEL.user.userId,@"redpacketId":_obj[@"id"]} Success:^(NSDictionary *info) {
        [self performSelector:@selector(remoAnimation) withObject:nil afterDelay:1.0f];
    } Failure:^(NSError *error) {
        SV_ERROR(error);
    }];
}

- (CAKeyframeAnimation *)confirmViewRotateInfo
{
    CAKeyframeAnimation *theAnimation = [CAKeyframeAnimation animation];
    
    theAnimation.values = [NSArray arrayWithObjects:
                           [NSValue valueWithCATransform3D:CATransform3DMakeRotation(0, 0, 0.5, 0)],
                           [NSValue valueWithCATransform3D:CATransform3DMakeRotation(M_PI, 0, 0.5, 0)],
                           [NSValue valueWithCATransform3D:CATransform3DMakeRotation(M_PI*2, 0, 0.5, 0)],
                           nil];
    
    theAnimation.cumulative = YES;
    theAnimation.duration = 1.0f;
    theAnimation.repeatCount = 1;
    theAnimation.removedOnCompletion = YES;
    theAnimation.fillMode = kCAFillModeForwards;
    theAnimation.delegate = self;
    
    return theAnimation;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    [self disMiss];
    //    if (self.block) {
    //        self.block();
    //    }
}

- (void)updateView:(id)obj{
    
    _obj = obj;
    [_headIcon cd_setImageWithURL:[NSURL URLWithString:[NSString cdImageLink:[obj objectForKey:@"avatar"]]] placeholderImage:[UIImage imageNamed:@"user-default"]];
    _nameLabel.text = [NSString stringWithFormat:@"%@",[obj objectForKey:@"nickname"]];
    
    NSInteger num = [[obj objectForKey:@"num"] integerValue];
    NSInteger left = [[obj objectForKey:@"left"] integerValue];
    NSInteger status = [[obj objectForKey:@"status"] integerValue];
    NSString *userId = [NSString stringWithFormat:@"%@",[obj objectForKey:@"userId"]];
    
    if (status == 1) {
        if ([userId isEqualToString:APP_MODEL.user.userId]) {
            if (num == left) {///<已领完
                _contentLabel.text = @"红包已经被领取完了";
                _contentLabel.font = [UIFont scaleFont:17];
                _open.hidden = YES;
                [_detailButton setTitle:@"看看大家手气 >" forState:UIControlStateNormal];
            }
            else{
                _contentLabel.text = [NSString stringWithFormat:@"发了一个红包%@\n",[obj objectForKey:@"money"]];
                _contentLabel.font = [UIFont scaleFont:14];
                _open.hidden = NO;
                _detailButton.hidden = NO;
                [_detailButton setTitle:@"查看详情" forState:UIControlStateNormal];
            }
        }else{
            if (num == left) {///<已领完
                _contentLabel.text = @"红包已经被领取完了";
                _contentLabel.font = [UIFont scaleFont:17];
                _open.hidden = YES;
                [_detailButton setTitle:@"看看大家手气 >" forState:UIControlStateNormal];
            }
            else{
                _contentLabel.text = [NSString stringWithFormat:@"发了一个红包%@\n",[obj objectForKey:@"money"]];
                _contentLabel.font = [UIFont scaleFont:14];
                _open.hidden = NO;
                _detailButton.hidden = YES;
            }
        }
    }else{
        if (num == 0) {///<已过期
            _contentLabel.text = @"已过期";
            _open.hidden = YES;
            _detailButton.hidden = YES;
        }
    }
}


- (void)disMiss{
    
    [UIView animateWithDuration:0.15 animations:^{
        self->_redView.transform = CGAffineTransformMakeScale(0.1, 0.1);
    } completion:^(BOOL finished) {
        if (finished) {
            [self removeFromSuperview];
        }
    }];
}

@end
