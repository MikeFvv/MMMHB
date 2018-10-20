//
//  BillTableViewCell.m
//  Project
//
//  Created by mini on 2018/8/14.
//  Copyright © 2018年 CDJay. All rights reserved.
//

#import "BillTableViewCell.h"
#import "BillItem.h"

@interface BillTableViewCell(){
    UILabel *_state;
    UILabel *_date;
    UILabel *_name;
    UILabel *_money;
    UILabel *_content;
}
@end

@implementation BillTableViewCell

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
    [_state mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(15);
        make.top.equalTo(self.contentView).offset(11);
        make.width.lessThanOrEqualTo(@(200));
    }];
    
    [_date mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView.mas_right).offset(-15);
        make.top.equalTo(self.contentView).offset(11);
    }];
    
    [_name mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(15);
        make.top.equalTo(self->_state.mas_bottom).offset(13);
    }];
    
    [_money mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView.mas_right).offset(-15);
        make.top.equalTo(self.contentView).offset(11);
    }];
    
    [_content mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(15);
        make.right.equalTo(self.contentView.mas_right).offset(-15);
        make.top.equalTo(self->_name.mas_bottom).offset(26);
    }];
}

#pragma mark ----- subView
- (void)initSubviews{
    _state = [UILabel new];
    [self.contentView addSubview:_state];
    _state.font = [UIFont scaleFont:15]; //#369b3c收入 #ff4646支出
    
    _date = [UILabel new];
    [self.contentView addSubview:_date];
    _date.font = [UIFont scaleFont:13];
    _date.textColor = Color_9;
    
    _name = [UILabel new];
    [self.contentView addSubview:_name];
    _name.font = [UIFont scaleFont:14];
    _name.textColor = Color_6;
    
    _money = [UILabel new]; //#369b3c收入 #ff4646支出
    [self.contentView addSubview:_money];
    _money.font = [UIFont scaleFont:15];
    _money.textColor = HexColor(@"#369b3c");
    
    _content = [UILabel new]; //#369b3c收入 #ff4646支出
    [self.contentView addSubview:_content];
    _content.font = [UIFont scaleFont:13];
    _content.textColor = Color_3;
    
    UIImageView *line = [[UIImageView alloc]initWithFrame:CGRectMake(0, 71, CDScreenWidth, 2)];
    [self.contentView addSubview:line];
    line.image = CD_DRline(line);
}

- (void)setObj:(id)obj{
    BillItem *item = [BillItem mj_objectWithKeyValues:obj];
    BOOL b = [item.billMoney containsString:@"-"];
    _state.textColor = (b)?HexColor(@"#ff4646"):HexColor(@"#369b3c");
    _state.text = (b)?@"支出":@"收入";
    _date.text = dateString_stamp(item.dateline,nil);
    _name.text = item.billtTile;
    if(b == NO)
        _money.text = [NSString stringWithFormat:@"+%@元",item.billMoney];
    else
        _money.text = [NSString stringWithFormat:@"%@元",item.billMoney];;
    _money.textColor = (b)?HexColor(@"#ff4646"):HexColor(@"#369b3c");
    _content.text = dateString_stamp([item.createTime integerValue],nil);;
}


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
