//
//  MessageTableViewCell.m
//  Project
//
//  Created by mini on 2018/8/1.
//  Copyright © 2018年 CDJay. All rights reserved.
//

#import "MessageTableViewCell.h"
#import "MessageItem.h"
#import "SqliteManage.h"
#import "PushMessageModel.h"

@interface MessageTableViewCell()
@property (nonatomic,strong) UIImageView *headIcon;
@property (nonatomic,strong) UIView *dotView;
@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) UILabel *descLabel;
@property (nonatomic,strong) UILabel *dateLabel;
@end

@implementation MessageTableViewCell

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
    
    [_headIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(15));
        make.centerY.equalTo(self.contentView);
        make.height.width.equalTo(@(50));
    }];
    
    [_dotView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_right).offset(-15);
        make.centerY.equalTo(self);
        make.width.height.equalTo(@(12));
    }];
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self->_headIcon.mas_right).offset(14);
        make.right.equalTo(self.contentView.mas_right).offset(-12);
        make.top.equalTo(self->_headIcon.mas_top).offset(3);
    }];
    
    [_descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self->_titleLabel.mas_left);
        make.top.equalTo(self->_titleLabel.mas_bottom).offset(8);
        make.right.equalTo(self.contentView.mas_right).offset(-12);
    }];
    
    [_dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView.mas_right).offset(-12);
        make.top.equalTo(self->_titleLabel.mas_top);
    }];
}

#pragma mark ----- subView
- (void)initSubviews {
    
    _headIcon = [UIImageView new];
    [self.contentView addSubview:_headIcon];
    _headIcon.layer.cornerRadius = 6;
    _headIcon.layer.masksToBounds = YES;
    //    _headIcon.backgroundColor = [UIColor randColor];
    
    _dotView = [UIView new];
    [self.contentView addSubview:_dotView];
    _dotView.backgroundColor = [UIColor redColor];
    _dotView.layer.cornerRadius = 6;
    _dotView.layer.masksToBounds = YES;
    
    _titleLabel = [UILabel new];
    _titleLabel.numberOfLines = 1;
    [self.contentView addSubview:_titleLabel];
    _titleLabel.font = [UIFont systemFontOfSize2:16];
    _titleLabel.textColor = Color_0;
    //    _titleLabel.text = @"通知消息";
    
    _descLabel = [UILabel new];
    [self.contentView addSubview:_descLabel];
    _descLabel.font = [UIFont systemFontOfSize:13];
    _descLabel.textColor = COLOR_X(140, 140, 140);
    //    _descLabel.text = @"点击查看";
    _descLabel.numberOfLines = 1;
    
    _dateLabel = [UILabel new];
    [self.contentView addSubview:_dateLabel];
    _dateLabel.font = [UIFont systemFontOfSize2:12];
    _dateLabel.textColor = [UIColor lightGrayColor];
    //    _dateLabel.text = @"1-01 11:33";
    
}

- (void)setObj:(id)obj{
    MessageItem *item = nil;//
    if ([obj isKindOfClass:[MessageItem class]]) {
        item = (MessageItem *)obj;
        _titleLabel.text = item.chatgName;
    } else{
        item = [MessageItem mj_objectWithKeyValues:obj];
        _titleLabel.text = item.chatgName;
    }
    if (item.localImg.length>0) {
        _headIcon.image = [UIImage imageNamed:item.localImg];
    } else {
        [_headIcon cd_setImageWithURL:[NSURL URLWithString:[NSString cdImageLink:item.img]] placeholderImage:[UIImage imageNamed:@"msg3"]];
    }
    
    //
    //                        NSString *last = @"暂无最新消息";
    //                        int number = 0 ;
    //                        if (g) {
    //                            last = g.lastMessage;
    //                            number = g.number;
    //                        }
    //                        [group setObject:last forKey:@"lastMessage"];
    //                        [group setObject:@(number) forKey:@"number"];
    if (item.isMyJoined == YES) {
        PushMessageModel *pmModel = [SqliteManage queryById:item.groupId];
        if (pmModel.number >0) {
            
            if ([pmModel.lastMessage isEqualToString:RedPacketString] || [pmModel.lastMessage isEqualToString:CowCowMessageString]) {
                _descLabel.text = (pmModel.number>99)?[NSString stringWithFormat:@"【99+未读】【红包】"]:[NSString stringWithFormat:@"【%d条未读】【红包】",pmModel.number];
            } else {
                _descLabel.text = (pmModel.number>99)?[NSString stringWithFormat:@"【99+未读】%@",pmModel.lastMessage]:[NSString stringWithFormat:@"【%d条未读】%@",pmModel.number,pmModel.lastMessage];
            }
            
            _dotView.hidden = NO;
        } else {
            if (pmModel.lastMessage.length >0) {
                
                if ([pmModel.lastMessage isEqualToString:RedPacketString] || [pmModel.lastMessage isEqualToString:CowCowMessageString]) {
                    _descLabel.text = @"【红包】";
                } else {
                    _descLabel.text = pmModel.lastMessage;
                }
            } else {
                _descLabel.text = @"暂无未读消息";
            }
            _dotView.hidden = YES;
        }
    } else {
        if ([item.notice isEqualToString:RedPacketString] || [item.notice isEqualToString:CowCowMessageString]) {
             _descLabel.text = @"【红包】";
        } else {
            _descLabel.text = item.notice;
        }
        
        _dotView.hidden = YES;
    }
    
}



@end
