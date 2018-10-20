//
//  MemberCell.m
//  Project
//
//  Created by mini on 2018/8/1.
//  Copyright © 2018年 CDJay. All rights reserved.
//

#import "MemberCell.h"
#import "MemberRow.h"

@interface MemberCell(){
    UIImageView *_itemIcon;
    UILabel *_itemLabel;
    UILabel *_rightLabel;
}
@end

@implementation MemberCell

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
    [_itemIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView.mas_left).offset(23);
        make.centerY.equalTo(self.contentView);
    }];
    
    [_itemLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(38);
        make.centerY.equalTo(self.contentView);
    }];
    
    [_rightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).offset(-15);
        make.centerY.equalTo(self.contentView);
    }];
}

#pragma mark ----- subView
- (void)initSubviews{
    self.backgroundColor = [UIColor whiteColor];
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    _itemIcon = [UIImageView new];
    [self.contentView addSubview:_itemIcon];
    
    _itemLabel = [UILabel new];
    [self.contentView addSubview:_itemLabel];
    _itemLabel.font = [UIFont scaleFont:14];
    _itemLabel.textColor = Color_3;
    
    _rightLabel = [UILabel new];
    [self.contentView addSubview:_rightLabel];
    _rightLabel.font = [UIFont scaleFont:14];
    _rightLabel.textColor = Color_6;
}

- (void)setObj:(id)obj{
    MemberRow *row = (MemberRow *)obj;
    _itemIcon.image = [UIImage imageNamed:row.imageName];
    _itemLabel.text = row.title;
    _rightLabel.text = row.subValue;
    self.accessoryType = row.type;
}


@end
