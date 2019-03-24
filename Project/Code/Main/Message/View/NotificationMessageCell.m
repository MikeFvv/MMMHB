//
//  NotificationMessageCell.m
//  Project
//
//  Created by Mike on 2019/2/13.
//  Copyright © 2019 CDJay. All rights reserved.
//

#import "NotificationMessageCell.h"
#import "NotificationMessageModel.h"

@implementation NotificationMessageCell

+ (CGSize)sizeForMessageModel:(RCMessageModel *)model
      withCollectionViewWidth:(CGFloat)collectionViewWidth
         referenceExtraHeight:(CGFloat)extraHeight
{
    CGFloat __messagecontentview_height = 15.0f;
    __messagecontentview_height += extraHeight;
    return CGSizeMake(collectionViewWidth, __messagecontentview_height);
}


- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self initData];
        [self initSubviews];
    }
    return self;
}

#pragma mark - Data
- (void)initData{
    self.allowsSelection = NO;
}


#pragma mark - Layout
- (void)initLayout {
    self.tipLabel.frame = self.baseContentView.bounds;
}

#pragma mark - subView
- (void)initSubviews{
    self.tipLabel = [UILabel new];
    [self.baseContentView addSubview:self.tipLabel];
    
    self.tipLabel.textAlignment = NSTextAlignmentCenter;
    self.tipLabel.textColor = [UIColor whiteColor];
    self.tipLabel.font = [UIFont systemFontOfSize2:14];
    self.tipLabel.backgroundColor = [UIColor colorWithRed:0.788 green:0.788 blue:0.788 alpha:1.000];
    self.tipLabel.layer.cornerRadius = 3;
    self.tipLabel.layer.masksToBounds = YES;
    
    [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.baseContentView.mas_centerX);
        make.centerY.mas_equalTo(self.baseContentView.mas_centerY);
        make.height.mas_equalTo(22);
    }];
}

- (void)setDataModel:(RCMessageModel *)model{
    [super setDataModel:model];
    NotificationMessageModel *messageModel = (NotificationMessageModel *)model.content;
    
    if (messageModel.messagetype == 1) {
        self.tipLabel.text = @"发送的消息超过规定长度";
    } else if (messageModel.messagetype == 2) {
        if (messageModel.talkTime > 0) {
            self.tipLabel.text = [NSString stringWithFormat:@"消息需要间隔%ld秒才能再次发送", (long)messageModel.talkTime];
        } else {
            self.tipLabel.text = @"发送消息的间隔时间没到，请稍后再试";
        }
    } else if (messageModel.messagetype == 3) {
        self.tipLabel.text = @"服务器连接错误";
    } else {
        self.tipLabel.text = @"系统历史消息";
    }
}


@end

