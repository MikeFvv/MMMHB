//
//  EnvelopeCollectionViewCell.m
//  Project
//
//  Created by mini on 2018/8/8.
//  Copyright © 2018年 CDJay. All rights reserved.
//

#import "EnvelopeCollectionViewCell.h"
#import "EnvelopeMessage.h"

@implementation EnvelopeCollectionViewCell

+ (CGSize)sizeForMessageModel:(RCMessageModel *)model
      withCollectionViewWidth:(CGFloat)collectionViewWidth
         referenceExtraHeight:(CGFloat)extraHeight
{
    CGFloat __messagecontentview_height = 68;
    __messagecontentview_height += extraHeight;
    return CGSizeMake(collectionViewWidth, __messagecontentview_height);
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initData];
        [self initSubviews];
        [self initLayout];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initData];
        [self initSubviews];
        //        [self initLayout];
    }
    return self;
}


#pragma mark ----- Data
- (void)initData{
    
}


#pragma mark ----- Layout
- (void)initLayout{
    
    
}

#pragma mark ----- subView
- (void)initSubviews{
    
    //    self.backgroundColor = [UIColor randColor];
    self.bubbleBackgroundView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self.messageContentView addSubview:self.bubbleBackgroundView];
    UITapGestureRecognizer *textMessageTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapTextMessage:)];
    textMessageTap.numberOfTapsRequired = 1;
    textMessageTap.numberOfTouchesRequired = 1;
    [self.bubbleBackgroundView addGestureRecognizer:textMessageTap];
    self.bubbleBackgroundView.userInteractionEnabled = YES;
    
    
    _redIcon = [UIImageView new];
    [self.bubbleBackgroundView addSubview:_redIcon];
    _redIcon.image = [UIImage imageNamed:@"red-icon"];
    
    [_redIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bubbleBackgroundView.mas_left).offset(15);
        make.top.equalTo(self.bubbleBackgroundView.mas_top).offset(15);
    }];
    
    _contentLabel = [UILabel new];
    [self.bubbleBackgroundView addSubview:_contentLabel];
    _contentLabel.font = [UIFont scaleFont:15];
    _contentLabel.textColor = Color_F;
    _contentLabel.text = @"恭喜发财大吉大利";
    
    [_contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bubbleBackgroundView.mas_top).offset(15);
        make.left.equalTo(self->_redIcon.mas_right).offset(8.1);
        make.right.lessThanOrEqualTo(self.bubbleBackgroundView.mas_right).offset(-14);
    }];
    
    _descLabel = [UILabel new];
    [self.bubbleBackgroundView addSubview:_descLabel];
    _descLabel.font = [UIFont scaleFont:10];
    _descLabel.textColor = Color_F;
    _descLabel.text = @"领取红包";
    
    [_descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self->_contentLabel.mas_bottom).offset(4);
        make.left.equalTo(self->_redIcon.mas_right).offset(10);
    }];
    
    _redType = [UILabel new];
    [self.bubbleBackgroundView addSubview:_redType];
    _redType.font = [UIFont scaleFont:10];
    _redType.textColor = Color_6;
    
    [_redType mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bubbleBackgroundView).offset(15);
        make.bottom.equalTo(self.bubbleBackgroundView.mas_bottom).offset(-2);
    }];
}

- (NSString *)typeString:(NSInteger)type{
    switch (type) {
        case 0:
            return @"福利包";
            break;
        case 1:
            return @"扫雷红包游戏";
            break;
        case 2:
            return @"牛牛红包游戏";
            break;
        default:
            break;
    }
    return nil;
}

- (void)setDataModel:(RCMessageModel *)model {
    [super setDataModel:model];
    [self initLayout];
    EnvelopeMessage *content = (EnvelopeMessage*)model.content;
    NSMutableDictionary *dic = model.extra.mj_JSONObject;
    NSInteger type = [dic[@"type"]integerValue];
    NSDictionary *conDic = content.content.mj_JSONObject;

    if (conDic) {
        NSString *money = conDic[@"money"];
        if([money isKindOfClass:[NSNumber class]])
            money = [(NSNumber *)money stringValue];
        NSString *num = conDic[@"num"];
        if([num isKindOfClass:[NSNumber class]])
            num = [(NSNumber *)num stringValue];
        _contentLabel.text = [NSString stringWithFormat:@"%@-%@",money,num];
        _redType.text = [self typeString:[conDic[@"type"]integerValue]];
    }
    
    _redIcon.image = (type == 0)?[UIImage imageNamed:@"red-icon"]:[UIImage imageNamed:@"red-icon-disabled"];
    CGRect bubbleFrame,messageFrame = self.messageContentView.frame;
    messageFrame.origin.x = (MessageDirection_RECEIVE == self.messageDirection)?HeadAndContentSpacing +
    [RCIM sharedRCIM].globalMessagePortraitSize.width + 10:
    self.baseContentView.bounds.size.width - (messageFrame.size.width + HeadAndContentSpacing +
                                              [RCIM sharedRCIM].globalMessagePortraitSize.width + 10);
    
    UIImage *bubbleImage;
    if (MessageDirection_SEND == self.messageDirection) {
        bubbleImage = (type == 0)?[UIImage imageNamed:@"redsend-new"]:[UIImage imageNamed:@"redsend-old"];
    }else{
        bubbleImage = (type == 0)?[UIImage imageNamed:@"redreceived-new"]:[UIImage imageNamed:@"redreceived-old"];
    }
    //    (MessageDirection_SEND == self.messageDirection)? [RCKitUtility imageNamed:@"chat_to_bg_normal" ofBundle:@"RongCloud.bundle"]:[RCKitUtility imageNamed:@"chat_from_bg_normal" ofBundle:@"RongCloud.bundle"];
    bubbleFrame = (MessageDirection_SEND == self.messageDirection)?CGRectMake(0, 0, messageFrame.size.width, messageFrame.size.height):CGRectMake(0, 0, messageFrame.size.width, messageFrame.size.height);
    bubbleImage = (MessageDirection_SEND == self.messageDirection)?[bubbleImage resizableImageWithCapInsets:UIEdgeInsetsMake(bubbleImage.size.height * 0.8, bubbleImage.size.width * 0.8,
                                                                                                                             bubbleImage.size.height * 0.2, bubbleImage.size.width * 0.2)]:[bubbleImage resizableImageWithCapInsets:UIEdgeInsetsMake(bubbleImage.size.height * 0.8, bubbleImage.size.width * 0.2,
                                                                                                                                                                                                                                                     bubbleImage.size.height * 0.2, bubbleImage.size.width * 0.8)];
    
    self.bubbleBackgroundView.image = bubbleImage;
    self.messageContentView.frame = messageFrame;
    self.bubbleBackgroundView.frame = bubbleFrame;
}

- (void)tapTextMessage:(UIGestureRecognizer *)gestureRecognizer {
    if ([self.delegate respondsToSelector:@selector(didTapMessageCell:)]) {
        [self.delegate didTapMessageCell:self.model];
    }
}


@end
