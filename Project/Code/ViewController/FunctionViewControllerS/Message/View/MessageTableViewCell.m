//
//  MessageTableViewCell.m
//  Project
//
//  Created by mini on 2018/8/1.
//  Copyright © 2018年 CDJay. All rights reserved.
//

#import "MessageTableViewCell.h"
#import "MessageItem.h"
#import "ModelHelper.h"

@interface MessageTableViewCell(){
    UIImageView *_headIcon;
    UILabel *_dotView;
    UILabel *_titleLabel;
    UILabel *_descLabel;
    UILabel *_dateLabel;
}
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
        make.left.equalTo(@(12));
        make.centerY.equalTo(self.contentView);
        make.height.width.equalTo(@(40));
    }];
    
    [_dotView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView.mas_right).offset(-15);
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.width.height.equalTo(@(16));
    }];
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self->_headIcon.mas_right).offset(8);
        make.top.equalTo(self->_headIcon.mas_top);
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
- (void)initSubviews{
    
    _headIcon = [UIImageView new];
    [self.contentView addSubview:_headIcon];
    _headIcon.layer.cornerRadius = 4;
    _headIcon.layer.masksToBounds = YES;
    //    _headIcon.backgroundColor = [UIColor randColor];
    
    _dotView = [[UILabel alloc] init];
    _dotView.font = [UIFont systemFontOfSize:10];
    _dotView.textColor = [UIColor whiteColor];
    _dotView.textAlignment = NSTextAlignmentCenter;
    
    [self.contentView addSubview:_dotView];
    _dotView.backgroundColor = [UIColor redColor];
    _dotView.layer.cornerRadius = 8;
    _dotView.layer.masksToBounds = YES;
    
    _titleLabel = [UILabel new];
    [self.contentView addSubview:_titleLabel];
    _titleLabel.font = [UIFont scaleFont:15];
    _titleLabel.textColor = [UIColor blackColor];
    //    _titleLabel.text = @"通知消息";
    
    _descLabel = [UILabel new];
    [self.contentView addSubview:_descLabel];
    _descLabel.font = [UIFont scaleFont:12];
    _descLabel.textColor = [UIColor lightGrayColor];
    //    _descLabel.text = @"点击查看";
    _descLabel.numberOfLines = 2;
    
    _dateLabel = [UILabel new];
    [self.contentView addSubview:_dateLabel];
    _dateLabel.font = [UIFont scaleFont:12];
    _dateLabel.textColor = [UIColor lightGrayColor];
    //    _dateLabel.text = @"1-01 11:33";
    
}

- (void)setObj:(id)obj{
    MessageItem *item = nil;//
    if ([obj isKindOfClass:[MessageItem class]]) {
        item = (MessageItem *)obj;
    }
    else{
        //item = [MessageItem mj_objectWithKeyValues:obj];
        if([obj isKindOfClass:[MessageItem class]])
            item = obj;
        else
            item = [MODEL_HELPER getMessageItem:obj];
    }
    if (item.localImg.length>0) {
        _headIcon.image = [UIImage imageNamed:item.localImg];
    }else{
        [_headIcon cd_setImageWithURL:[NSURL URLWithString:[NSString cdImageLink:item.img]] placeholderImage:[UIImage imageNamed:@"msg3"]];
    }
    _titleLabel.text = item.groupName;
    _descLabel.text = item.notice;
    //
    //                        NSString *last = @"暂无最新消息";
    //                        int number = 0 ;
    //                        if (g) {
    //                            last = g.lastMessage;
    //                            number = g.number;
    //                        }
    //                        [group setObject:last forKey:@"lastMessage"];
    //                        [group setObject:@(number) forKey:@"number"];
    _dotView.hidden = YES;
    if (item.localType == 1) {
        NSString *groupId = item.groupId;
        for (NSDictionary *dic in APP_MODEL.unReadNumberArray) {
            NSString *gId = dic[@"chatId"];
            if([gId isEqualToString:groupId]){
                NSInteger unreadNum = [dic[@"unreadNum"] integerValue];
                if(unreadNum > 0){
                    _dotView.hidden = NO;
                    if(unreadNum < 10)
                        _dotView.text = [NSString stringWithFormat:@"%ld",unreadNum];
                    else
                        _dotView.text = @"···";
                }
            }
        }
    }
}


@end
