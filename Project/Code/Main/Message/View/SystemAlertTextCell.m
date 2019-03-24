//
//  SystemAlertTextCell.m
//  Project
//
//  Created by 罗耀生 on 2019/3/20.
//  Copyright © 2019 CDJay. All rights reserved.
//

#import "SystemAlertTextCell.h"


@interface SystemAlertTextCell()

@property (nonatomic, strong) UILabel *contentLabel;

@end

@implementation SystemAlertTextCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

+ (instancetype)cellWithTableView:(UITableView *)tableView reusableId:(NSString *)ID
{
    SystemAlertTextCell *cell = [[SystemAlertTextCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupUI];
    }
    return self;
}


- (void)setupUI {
    
    _contentLabel = [UILabel new];
    [self addSubview:_contentLabel];
    _contentLabel.font = [UIFont vvFontOfSize:15];
    _contentLabel.numberOfLines = 0;
    _contentLabel.textColor = [UIColor colorWithRed:0.525 green:0.525 blue:0.525 alpha:1.000];
    
    [_contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(30);
        make.right.equalTo(self.mas_right).offset(-10);
        make.centerY.equalTo(self.mas_centerY);
    }];
 
    
//    UIView *lineView = [[UIView alloc] init];
//    lineView.backgroundColor = [UIColor lightGrayColor];
//    [self addSubview:lineView];
//
//    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.mas_left).offset(30);
//        make.bottom.right.equalTo(self);
//        make.height.equalTo(@(0.7));
//    }];
    
}



- (void)setModel:(id)model {
    _contentLabel.text = model;
    
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end


