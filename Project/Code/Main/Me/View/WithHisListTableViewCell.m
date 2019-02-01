//
//  WithHisListTableViewCell.m
//  Project
//
//  Created by mini on 2018/8/15.
//  Copyright © 2018年 CDJay. All rights reserved.
//

#import "WithHisListTableViewCell.h"
#import "UIImageView+WebCache.h"

@interface WithHisListTableViewCell(){
    UILabel *_noLabel;
    UILabel *_nameLabel;
    UILabel *_titleLabel;
    UILabel *_areaLabel;
    UIImageView *_typeIcon;
}
@property(nonatomic,strong)UIView *bgView;
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
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(8);
        make.right.equalTo(self.contentView).offset(-8);
        make.top.equalTo(self.contentView).offset(4);
        make.bottom.equalTo(self.contentView).offset(-4);
    }];
    [_typeIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(self.bgView).offset(10);
        make.width.height.equalTo(@40);
    }];
    
//    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self->_noLabel.mas_bottom).offset(8);
//        make.left.equalTo(self->_noLabel.mas_left);
//        make.right.equalTo(self.bgView.mas_right).offset(-15);
//    }];
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self->_typeIcon.mas_top).offset(1);
        make.left.equalTo(self->_typeIcon.mas_right).offset(8);
    }];
    
    [_areaLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self->_titleLabel.mas_bottom).offset(3);
        make.left.equalTo(self->_titleLabel.mas_left);
    }];
    
    [_noLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self->_titleLabel.mas_left);
        make.bottom.equalTo(self->_bgView).offset(-8);
    }];
}

#pragma mark ----- subView
- (void)initSubviews{
    UIView *bgView = [[UIView alloc] init];
    bgView.backgroundColor = [UIColor whiteColor];
    bgView.layer.masksToBounds = YES;
    bgView.layer.cornerRadius = 6.0;
    bgView.layer.borderWidth = 0.5;
    bgView.layer.borderColor = COLOR_X(240, 240, 240).CGColor;
    [self.contentView addSubview:bgView];
    self.bgView = bgView;
    
    _typeIcon = [UIImageView new];
    [bgView addSubview:_typeIcon];
    _typeIcon.image = [UIImage imageNamed:@"withtype-bank"];
    _typeIcon.backgroundColor = Color_9;
    _typeIcon.layer.masksToBounds = YES;
    _typeIcon.layer.cornerRadius = 20;
    [_typeIcon setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
   
    
//    _nameLabel = [UILabel new];
//    [bgView addSubview:_nameLabel];
//    _nameLabel.font = [UIFont systemFontOfSize2:14];
//    _nameLabel.textColor = COLOR_X(170, 170, 170);
    
    _titleLabel = [UILabel new];
    [bgView addSubview:_titleLabel];
    _titleLabel.font = [UIFont boldSystemFontOfSize2:16];
    _titleLabel.textColor = [UIColor blackColor];
    
    _areaLabel = [UILabel new];
    [bgView addSubview:_areaLabel];
    _areaLabel.font = [UIFont systemFontOfSize2:14];
    _areaLabel.textColor = COLOR_X(180, 180, 180);
    
    _noLabel = [UILabel new];
    [bgView addSubview:_noLabel];
    _noLabel.font = [UIFont boldSystemFontOfSize2:16];
    _noLabel.textColor = COLOR_X(140, 140, 140);
}

- (void)setObj:(id)obj{
//    WithdrawalModel *model = [WithdrawalModel mj_objectWithKeyValues:obj];
    _noLabel.text = [NSString stringWithFormat:@"%@",obj[@"bankNum"]];
    //_nameLabel.text = [NSString stringWithFormat:@"持卡人：%@",obj[@"user"]];
    _titleLabel.text = [NSString stringWithFormat:@"%@",obj[@"bankName"]];
    _areaLabel.text = [NSString stringWithFormat:@"%@",obj[@"bankRegion"]];
    NSString *img = obj[@"img"];
    [_typeIcon sd_setImageWithURL:[NSURL URLWithString:img]];
}


@end

