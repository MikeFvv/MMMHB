//
//  EnvelopTableViewCell.m
//  Project
//
//  Created by mac on 2018/8/20.
//  Copyright © 2018年 CDJay. All rights reserved.
//

#import "EnvelopTableViewCell.h"
#import "EnvelopeNet.h"

@interface EnvelopTableViewCell(){
    UIImageView *_icon;
    UILabel *_name;
    UIImageView *_sex;
    UILabel *_date;
    UILabel *_money;
    UILabel *_max;
    UIImageView *_maxImg;
}
@end

@implementation EnvelopTableViewCell



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
    [_icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(15);
        make.centerY.equalTo(self.contentView);
        make.height.width.equalTo(@(40));
    }];
    
    [_name mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self ->_icon.mas_right).offset(10);
        make.top.equalTo(self.contentView).offset(16);
    }];
    
    [_date mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self ->_icon.mas_right).offset(11);
        make.top.equalTo(self ->_name.mas_bottom).offset(6);
    }];
    
    [_money mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView.mas_right).offset(-15);
        make.top.equalTo(self.contentView).offset(15);
    }];
    
    [_max mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView.mas_right).offset(-15);
        make.top.equalTo(self ->_money.mas_bottom).offset(6);
    }];
    
    [_maxImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self ->_max.mas_left).offset(-2);
        make.centerY.equalTo(self ->_max.mas_centerY);
    }];
}

#pragma mark ----- subView
- (void)initSubviews{
    _icon = [UIImageView new];
    [self.contentView addSubview:_icon];
    _icon.layer.cornerRadius = 20;
    _icon.layer.masksToBounds = YES;
    
    _name = [UILabel new];
    [self.contentView addSubview:_name];
    _name.textColor = Color_3;
    _name.font = [UIFont scaleFont:14];
    
    UIView *sexBack = [UIView new];
    [self.contentView addSubview:sexBack];
    sexBack.layer.cornerRadius = 7.5;
    sexBack.layer.masksToBounds = YES;
    sexBack.backgroundColor = SexBack;
    [sexBack mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self -> _name.mas_right).offset(3);
        make.centerY.equalTo(self ->_name);
        make.width.height.equalTo(@(15));
    }];
    
    _sex = [UIImageView new];
    [sexBack addSubview:_sex];
    [_sex mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(sexBack);
    }];
    
    _date = [UILabel new];
    [self.contentView addSubview:_date];
    _date.textColor = Color_9;
    _date.font = [UIFont scaleFont:12];
    
    _money = [UILabel new];
    [self.contentView addSubview:_money];
    _money.textColor = Color_3;
    _money.font = [UIFont scaleFont:14];
    
    _max = [UILabel new];
    [self.contentView addSubview:_max];
    _max.textColor = MBTNColor;
    _max.font = [UIFont scaleFont:12];
    _max.text = @"手气最佳";
    
    _maxImg = [UIImageView new];
    [self.contentView addSubview:_maxImg];
    _maxImg.image = [UIImage imageNamed:@"icon_max"];
    
}

- (void)setObj:(id)obj{
    NSString *avatar = [NSString cdImageLink:[obj objectForKey:@"avatar"]];
    NSString *grap_money = [NSString stringWithFormat:@"%@",[obj objectForKey:@"grap_money"]];
    NSString *nickname = [NSString stringWithFormat:@"%@",[obj objectForKey:@"nickname"]];
    [_icon cd_setImageWithURL:[NSURL URLWithString:avatar] placeholderImage:[UIImage imageNamed:@"user-default"]];
    NSInteger sex = [[obj objectForKey:@"gender"] integerValue];
    _money.text = (![grap_money isKindOfClass:[NSNull class]])?grap_money:@"";
    _date.text = dateString_stamp([[obj objectForKey:@"dateline"] integerValue],nil);
    _name.text = (![nickname isKindOfClass:[NSNull class]])?nickname:@"";;
    _sex.image = (sex==0)?[UIImage imageNamed:@"male"]:[UIImage imageNamed:@"female"];
    EnvelopeNet *model = [EnvelopeNet shareInstance];
    NSArray *mids = [model.mids componentsSeparatedByString:@","];
    NSString *userId = [NSString stringWithFormat:@"%@",[obj objectForKey:@"userId"]];
    for (NSString *i in mids) {
        if ([userId isEqualToString:i]) {
            NSInteger length = 0;
            if (grap_money.length >0) {
                length = grap_money.length - 1;
            }
            NSRange r = NSMakeRange(length, 1);
            _money.text = [grap_money stringByReplacingCharactersInRange:r withString:@"*"];
            break;
        }
    }
    if (model.IsEnd) {
        CGFloat m = [grap_money floatValue];
        _max.hidden = (m == model.maxMoney)?NO:YES;
        _maxImg.hidden = (m == model.maxMoney)?NO:YES;
    }else{
        _max.hidden = YES;
        _maxImg.hidden = YES;
    }
  
    
    
}

@end
