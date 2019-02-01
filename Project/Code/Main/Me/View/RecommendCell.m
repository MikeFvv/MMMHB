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
    UILabel *_total;
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
        make.height.width.equalTo(@(44));
        make.centerY.equalTo(self.conView.mas_centerY).offset(-19);
    }];
    
    [_name mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self->_headIcon.mas_right).offset(10.9);
        make.top.equalTo(self.conView.mas_top).offset(13);
    }];
    
    [_account mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self->_headIcon.mas_right).offset(11.9);
        make.top.equalTo(self->_name.mas_bottom).offset(6);
    }];
}

#pragma mark ----- subView
- (void)initSubviews{
    self.backgroundColor = BaseColor;
    UIView *conView = [[UIView alloc] init];
    conView.backgroundColor = [UIColor whiteColor];
    self.conView = conView;
    [self.contentView addSubview:conView];
    [conView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-8);
    }];
    _headIcon = [UIImageView new];
    [conView addSubview:_headIcon];
    _headIcon.layer.cornerRadius = 5.0f;
    _headIcon.layer.masksToBounds = YES;
//    _headIcon.backgroundColor = [UIColor randColor];
    
    _name = [UILabel new];
    [conView addSubview:_name];
    _name.font = [UIFont systemFontOfSize2:16];
    _name.textColor = Color_0;
    
    UIView *sexBack = [UIView new];
    [conView addSubview:sexBack];
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
    [conView addSubview:_account];
    _account.font = [UIFont systemFontOfSize2:13];
    _account.textColor = Color_6;
    
    _total = [UILabel new];
    [conView addSubview:_total];
    _total.font = [UIFont systemFontOfSize2:16];
    _total.textColor = Color_0;
    _total.textAlignment = NSTextAlignmentRight;
    [_total mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self->_name.mas_centerY);
        make.right.equalTo(conView).offset(-10);
    }];
    _total.text = @"分成总计：0";
    
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = COLOR_X(245, 245, 245);
    [conView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@0.5);
        make.left.right.equalTo(conView);
        make.bottom.equalTo(conView.mas_bottom).offset(-36);
    }];
    
    _detailButton = [UIButton new];
    [conView addSubview:_detailButton];
    _detailButton.titleLabel.font = [UIFont systemFontOfSize2:14];
    [_detailButton setTitle:@"查看详情" forState:UIControlStateNormal];
    [_detailButton setTitleColor:HexColor(@"#4976f2") forState:UIControlStateNormal];//:@"查看详情"
    [_detailButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(conView.mas_bottom);
        make.left.right.equalTo(self.contentView);
        make.height.equalTo(@36);
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)setObj:(id)obj{
    RecommmendObj *model = [RecommmendObj mj_objectWithKeyValues:obj];
    NSString *url = [NSString cdImageLink:model.avatar];
    [_headIcon cd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"user-default"]];
    _name.text = model.nick;
    _sexIcon.image = (model.gender == 0)?[UIImage imageNamed:@"male"]:[UIImage imageNamed:@"female"];
    _account.text = [NSString stringWithFormat:@"账号：%@   代理数：%@   总玩家数：%@",model.userId,model.childAgentCount,model.childPlayerCount];
    _total.text = [NSString stringWithFormat:@"分成总计：%@",model.profitCommission];
    
}

@end
