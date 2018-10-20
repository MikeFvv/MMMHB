//
//  WithHisListTableViewCell.m
//  Project
//
//  Created by mini on 2018/8/15.
//  Copyright © 2018年 CDJay. All rights reserved.
//

#import "WithHisListTableViewCell.h"
#import "WithdrawalModel.h"

@interface WithHisListTableViewCell(){
    UILabel *_noLabel;
    UILabel *_nameLabel;
    UILabel *_titleLabel;
    UILabel *_areaLabel;
    UIImageView *_typeIcon;
    UILabel *_typeName;
}
@end

@implementation WithHisListTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
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
    [_noLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(15);
        make.top.equalTo(self.contentView.mas_top).offset(9);
        make.right.equalTo(self.contentView.mas_right).offset(-15);
    }];
    
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self->_noLabel.mas_bottom).offset(2);
        make.left.equalTo(self.contentView.mas_left).offset(15);
        make.right.equalTo(self.contentView.mas_right).offset(-15);
    }];
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self->_nameLabel.mas_bottom).offset(2);
        make.left.equalTo(self.contentView.mas_left).offset(15);
        make.right.equalTo(self.contentView.mas_right).offset(-15);
    }];
    
    [_areaLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self->_titleLabel.mas_bottom).offset(2);
        make.left.equalTo(self.contentView.mas_left).offset(15);
        make.right.equalTo(self.contentView.mas_right).offset(-15);
    }];
    
    [_typeIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self->_areaLabel.mas_bottom).offset(8);
        make.left.equalTo(self.contentView.mas_left).offset(15);
    }];
    
    [_typeName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self->_typeIcon);
        make.left.equalTo(self->_typeIcon.mas_right).offset(8);
        make.right.lessThanOrEqualTo(self.contentView.mas_right).offset(-15);
    }];
}

#pragma mark ----- subView
- (void)initSubviews{
    
    _noLabel = [UILabel new];
    [self.contentView addSubview:_noLabel];
    _noLabel.font = [UIFont scaleFont:14];
    _noLabel.textColor = Color_3;
    
    _nameLabel = [UILabel new];
    [self.contentView addSubview:_nameLabel];
    _nameLabel.font = [UIFont scaleFont:12];
    _nameLabel.textColor = HexColor(@"#3F3F3F");//[UIColor colorWithHexString:@""];
    
    _titleLabel = [UILabel new];
    [self.contentView addSubview:_titleLabel];
    _titleLabel.font = [UIFont scaleFont:12];
    _titleLabel.textColor = HexColor(@"#3F3F3F");
    
    _areaLabel = [UILabel new];
    [self.contentView addSubview:_areaLabel];
    _areaLabel.font = [UIFont scaleFont:12];
    _areaLabel.textColor = HexColor(@"#3F3F3F");
    
    _typeIcon = [UIImageView new];
    [self.contentView addSubview:_typeIcon];
    _typeIcon.image = [UIImage imageNamed:@"withtype-bank"];
    
    _typeName = [UILabel new];
    [self.contentView addSubview:_typeName];
    _typeName.font = [UIFont scaleFont:12];
    _typeName.textColor = HexColor(@"#3F3F3F");
    _typeName.text = @"银行卡";
}

- (void)setObj:(id)obj{
    WithdrawalModel *model = [WithdrawalModel mj_objectWithKeyValues:obj];
    _noLabel.text = [NSString stringWithFormat:@"卡号：%@",model.accNo];
    _nameLabel.text = [NSString stringWithFormat:@"持卡人：%@",model.accUser];
    _titleLabel.text = [NSString stringWithFormat:@"银行名称：%@",model.accTargetName];
    _areaLabel.text = [NSString stringWithFormat:@"开卡地区：%@",model.accAreaName];
}


@end

