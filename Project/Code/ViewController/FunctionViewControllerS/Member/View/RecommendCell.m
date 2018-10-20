//
//  RecommendCell.m
//  Project
//
//  Created by mini on 2018/8/2.
//  Copyright © 2018年 CDJay. All rights reserved.
//

#import "RecommendCell.h"
#import "RecommmendObj.h"

@interface RecommendCell(){
    UIImageView *_headIcon;
    UIImageView *_sexIcon;
    UILabel *_name;
    UILabel *_account;
    UILabel *_layNumber;
    UILabel *_playerNumber;
    UILabel *_backMoney;
    UIButton *_detail;
}
@end

@implementation RecommendCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
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
        make.left.equalTo(@(15));
        make.top.equalTo(@(14));
        make.height.width.equalTo(@(40));
    }];
    
    [_name mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self->_headIcon.mas_right).offset(10.9);
        make.top.equalTo(self.contentView.mas_top).offset(15);
    }];
    
    [_backMoney mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView.mas_right).offset(-15);
        make.top.equalTo(self.contentView.mas_top).offset(15);
    }];
    
    [_account mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self->_headIcon.mas_right).offset(11.9);
        make.top.equalTo(self->_name.mas_bottom).offset(5);
    }];
    
    [_layNumber mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self->_name.mas_left);
        make.top.equalTo(self->_account.mas_bottom).offset(12);
    }];
    
    [_playerNumber mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self->_layNumber.mas_right).offset(34);
        make.centerY.equalTo(self->_layNumber);
    }];
    
    [_detail mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView.mas_right).offset(-15);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-13);
        make.width.equalTo(@(62));
        make.height.equalTo(@(23));
    }];
}

#pragma mark ----- subView
- (void)initSubviews{
    _headIcon = [UIImageView new];
    [self.contentView addSubview:_headIcon];
    _headIcon.layer.cornerRadius = 5.0f;
    _headIcon.layer.masksToBounds = YES;
//    _headIcon.backgroundColor = [UIColor randColor];
    
    _name = [UILabel new];
    [self.contentView addSubview:_name];
    _name.font = [UIFont scaleFont:14];
    _name.textColor = Color_3;
    
    UIView *sexBack = [UIView new];
    [self.contentView addSubview:sexBack];
    sexBack.backgroundColor = SexBack;
    sexBack.layer.cornerRadius = 7.5;
    sexBack.layer.masksToBounds = YES;
    [sexBack mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self->_name.mas_right).offset(3);
        make.centerY.equalTo(self->_name);
        make.height.width.equalTo(@(15));
    }];
    
    _sexIcon = [UIImageView new];
    [sexBack addSubview:_sexIcon];
    [_sexIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(sexBack);
    }];
    
    _account = [UILabel new];
    [self.contentView addSubview:_account];
    _account.font = [UIFont scaleFont:12];
    _account.textColor = Color_9;
    
    _layNumber = [UILabel new];
    [self.contentView addSubview:_layNumber];
    _layNumber.font = [UIFont scaleFont:12];
    _layNumber.textColor = Color_9;
    
    _playerNumber = [UILabel new];
    [self.contentView addSubview:_playerNumber];
    _playerNumber.font = [UIFont scaleFont:12];
    _playerNumber.textColor = Color_9;
    
    _backMoney = [UILabel new];
    [self.contentView addSubview:_backMoney];
    _backMoney.font = [UIFont scaleFont:12];
    _backMoney.textColor = HexColor(@"#FF334C");
 
    
    _detail = [UIButton new];
    [self.contentView addSubview:_detail];
    _detail.titleLabel.font = [UIFont scaleFont:12];
    _detail.layer.cornerRadius = 6;
    _detail.layer.masksToBounds = YES;
    _detail.backgroundColor = HexColor(@"#FF334C");
    [_detail setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_detail setTitle:@"查看详情" forState:UIControlStateNormal];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)setObj:(id)obj{
    RecommmendObj *model = [RecommmendObj mj_objectWithKeyValues:obj];
    NSString *url = [NSString cdImageLink:model.avatar];
    [_headIcon cd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"user-default"]];
    _name.text = model.nickname;
    _sexIcon.image = (model.gender == 0)?[UIImage imageNamed:@"male"]:[UIImage imageNamed:@"female"];
    _account.text = [NSString stringWithFormat:@"ID:%@",model.rId];
    NSString *back = [NSString stringWithFormat:@"返点总计：%@",model.rate];
    NSMutableAttributedString *AttributedStr = [[NSMutableAttributedString alloc]initWithString:back];
    NSRange rang = [back rangeOfString:@"返点总计："];
    [AttributedStr addAttribute:NSForegroundColorAttributeName value:Color_3 range:rang];
    _backMoney.attributedText = AttributedStr;
    _playerNumber.text = [NSString stringWithFormat:@"总玩家：%ld",model.player_num];
    _layNumber.text = [NSString stringWithFormat:@"代理数：%ld",model.daili_num];

}

@end
