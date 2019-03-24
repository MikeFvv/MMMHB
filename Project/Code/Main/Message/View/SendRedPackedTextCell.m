//
//  SendRedPackedTextCell.m
//  Project
//
//  Created by Mike on 2019/2/28.
//  Copyright © 2019 CDJay. All rights reserved.
//

#import "SendRedPackedTextCell.h"
#import "SendRPCollectionViewCell.h"
#import "SendRedPacketController.h"

#define kTableViewImageWidth 20

static NSString * const kCellSendRedPackedTextId = @"SendRedPackedTextCell";

@interface SendRedPackedTextCell ()



@end

@implementation SendRedPackedTextCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

+ (instancetype)cellWithTableView:(UITableView *)tableView reusableId:(NSString *)ID
{
    SendRedPackedTextCell *cell = [[SendRedPackedTextCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
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
    
    self.backgroundColor = [UIColor clearColor];
    
    _titleLabel = [UILabel new];
    _titleLabel.text = @"-";
    _titleLabel.font = [UIFont systemFontOfSize2:16];
    _titleLabel.textColor = Color_0;
    [self.contentView addSubview:_titleLabel];
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(kTableViewImageWidth+15);
        make.centerY.equalTo(self.contentView.mas_centerY);
    }];
    
    
    _deTextField = [UITextField new];
    //    _deTextField.layer.cornerRadius = width/2;
    //    _deTextField.layer.masksToBounds = YES;
//    _deTextField.backgroundColor = [UIColor redColor];
    _deTextField.font = [UIFont systemFontOfSize2:16];
    _deTextField.keyboardType = UIKeyboardTypeNumberPad;
    _deTextField.textAlignment = NSTextAlignmentRight;
    _deTextField.clearButtonMode = UITextFieldViewModeAlways;
    
//    [_deTextField addTarget:self action:@selector(onNoButton) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_deTextField];
    
    [_deTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView.mas_right).offset(-(kTableViewImageWidth+50));
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(200, 35));
    }];
    
    _unitLabel = [UILabel new];
    _unitLabel.text = @"-";
    _unitLabel.font = [UIFont systemFontOfSize2:16];
    _unitLabel.textColor = Color_0;
    [self.contentView addSubview:_unitLabel];
    
    [_unitLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView.mas_right).offset(-(kTableViewImageWidth+20));
        make.centerY.equalTo(self.contentView.mas_centerY);
    }];
    
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = [UIColor colorWithRed:0.945 green:0.945 blue:0.945 alpha:1.000];
    [self.contentView addSubview:lineView];
    
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView.mas_left).offset(kTableViewImageWidth +10);
        make.right.mas_equalTo(self.contentView.mas_right).offset(-(kTableViewImageWidth +10));
        make.height.mas_equalTo(@(1));
        make.bottom.mas_equalTo(self.contentView.mas_bottom);
    }];
}



- (void)setModel:(id)model {
    //    self.resultDataArray = [NSMutableArray arrayWithArray:(NSArray *)model];
    //    [self.collectionView reloadData];
    //    _titleLabel.text =  [dict objectForKey:@"pokerCount"];
}


- (void)layoutSubviews {
    [super layoutSubviews];
    
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end



