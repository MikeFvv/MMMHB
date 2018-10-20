//
//  TabbarButton.m
//  Project
//
//  Created by mac on 2018/8/27.
//  Copyright © 2018年 CDJay. All rights reserved.
//

#import "TabbarButton.h"

@interface TabbarButton(){
    UIImageView *_iconImg;
    UILabel *_titleLabel;
    UILabel *_badeLabel;
    UIView *_badeBack;
}
@end

@implementation TabbarButton

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
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
    [_iconImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.centerY.equalTo(self).offset(-8);
    }];
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self->_iconImg.mas_bottom).offset(3);
    }];
    
    [_badeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self->_iconImg.mas_right);
        make.width.greaterThanOrEqualTo(@(10));
        make.height.equalTo(@(10));
        make.top.equalTo(self->_iconImg.mas_top).offset(-2);
    }];
    
    [_badeBack mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(12));
        make.width.equalTo(self->_badeLabel.mas_width).offset(2);
        make.center.equalTo(self->_badeLabel);
    }];
}

#pragma mark ----- subView
- (void)initSubviews{
    _iconImg = [UIImageView new];
    [self addSubview:_iconImg];
    
    _titleLabel = [UILabel new];
    [self addSubview:_titleLabel];
    _titleLabel.font = [UIFont scaleFont:11];
    
    _badeBack = [UIView new];
    [self addSubview:_badeBack];
    _badeBack.layer.cornerRadius = 6;
    _badeBack.layer.masksToBounds = YES;
    _badeBack.backgroundColor = _badeColor;
    _badeBack.hidden = YES;
    
    _badeLabel = [UILabel new];
    [self addSubview:_badeLabel];
    _badeLabel.font = [UIFont scaleFont:9];
    _badeLabel.textAlignment = NSTextAlignmentCenter;
    _badeLabel.hidden = YES;
    
    _badeLabel.textColor = [UIColor whiteColor];
    //    _badeLabel.text = @"2";
}

+ (TabbarButton *)tabbar{
    TabbarButton *item = [TabbarButton new];
    item.normalColor = Color_9;
    item.selectColor = TABSelectColor;
    item.badeColor = [UIColor redColor];
    return item;
}

- (void)setBadeColor:(UIColor *)badeColor{
    _badeColor = badeColor;
    _badeBack.backgroundColor = badeColor;
}

- (void)setTitle:(NSString *)title{
    _title = title;
    _titleLabel.text = title;
}

- (void)setBadeValue:(NSString *)badeValue{
    _badeValue = badeValue;
    if([badeValue isEqualToString:@"0"]){
        _badeLabel.hidden = YES;
        _badeBack.hidden = YES;
    }else{
        
        _badeLabel.hidden = NO;
        _badeBack.hidden = NO;
    }
}

- (void)setNormalImg:(UIImage *)normalImg{
    _normalImg = normalImg;
}

- (void)setSelectImg:(UIImage *)selectImg{
    _selectImg = selectImg;
}

- (void)setTabbarSelected:(BOOL)tabbarSelected{
    _tabbarSelected = tabbarSelected;
    _titleLabel.textColor = (tabbarSelected)?_selectColor:_normalColor;
    _iconImg.image = (tabbarSelected)?_selectImg:_normalImg;
}
@end
