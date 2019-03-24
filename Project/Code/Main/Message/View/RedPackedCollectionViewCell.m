//
//  EnvelopeCollectionViewCell.m
//  Project
//
//  Created by mini on 2018/8/8.
//  Copyright © 2018年 CDJay. All rights reserved.
//

#import "RedPackedCollectionViewCell.h"
#import "EnvelopeMessage.h"
@class RCloudImageView;

@implementation RedPackedCollectionViewCell

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
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initData];
        [self initSubviews];
    }
    return self;
}


#pragma mark ----- Data
- (void)initData{
    
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
    _redIcon.image = [UIImage imageNamed:@"mess_packed_icon_nor"];
    
    [_redIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bubbleBackgroundView.mas_left).offset(13);
        make.top.equalTo(self.bubbleBackgroundView.mas_top).offset(15);
        make.size.mas_equalTo(CGSizeMake(29, 34));
    }];
    
    _contentLabel = [UILabel new];
    [self.bubbleBackgroundView addSubview:_contentLabel];
    _contentLabel.font = [UIFont boldSystemFontOfSize:15];
    _contentLabel.textColor = Color_F;
    _contentLabel.text = kRedpackedGongXiFaCaiMessage;
    
    [_contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bubbleBackgroundView.mas_top).offset(14);
        make.left.equalTo(self->_redIcon.mas_right).offset(8);
        make.right.lessThanOrEqualTo(self.bubbleBackgroundView.mas_right).offset(-14);
    }];
    
    _descLabel = [UILabel new];
    [self.bubbleBackgroundView addSubview:_descLabel];
    _descLabel.font = [UIFont systemFontOfSize:14];
    _descLabel.textColor = Color_F;
//    _descLabel.backgroundColor = [UIColor grayColor];
    
    
    [_descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentLabel.mas_bottom).offset(3);
        make.left.equalTo(self.redIcon.mas_right).offset(10);
    }];
    
    _redTypeLabel = [UILabel new];
    [self.bubbleBackgroundView addSubview:_redTypeLabel];
    _redTypeLabel.font = [UIFont systemFontOfSize:12];
    _redTypeLabel.textColor = Color_6;
    
    [_redTypeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bubbleBackgroundView.mas_left).offset(10);
        make.bottom.equalTo(self.bubbleBackgroundView.mas_bottom).offset(-3);
    }];
    
    
}

- (NSString *)typeString:(NSInteger)type {
    switch (type) {
        case 0:
            return @"福利红包";
            break;
        case 1:
            return @"扫雷红包";
            break;
        case 2:
            return @"牛牛红包";
            break;
        case 3:
            return @"禁抢红包";
            break;
        default:
            break;
    }
    return nil;
}

- (void)setDataModel:(RCMessageModel *)model {
    [super setDataModel:model];
    EnvelopeMessage *mess = (EnvelopeMessage *)model.content;
    RCUserInfo *info = mess.senderUserInfo;
    if(self.nicknameLabel.text.length == 0){
        if(info.name)
            self.nicknameLabel.text = info.name;
    }
    id imageView = self.portraitImageView;
    if([imageView respondsToSelector:@selector(imageURL)]){
//        NSURL *url = (NSURL *)[imageView imageURL];
//        if(url == nil){
        if(model.content.senderUserInfo.portraitUri.length > 0) {
            [imageView setImageURL:[NSURL URLWithString:model.content.senderUserInfo.portraitUri]];
        } else {
            NSLog(@"1");
        }
    } else {
        NSLog(@"1");
    }
    EnvelopeMessage *content = (EnvelopeMessage*)model.content;
    NSMutableDictionary *dic = model.extra.mj_JSONObject;
    NSInteger cellStatus = [dic[[NSString stringWithFormat:@"cellStatus-%@", APP_MODEL.user.userId]]integerValue];
    NSDictionary *contentDict = content.content.mj_JSONObject;
    
    NSInteger redPackedType = [contentDict[@"type"]integerValue];
    
   _redTypeLabel.text = [self typeString:redPackedType];
//    if(redPackedType == 0)
//        _redTypeLabel.textColor = Color_6;
//    else
//        _redTypeLabel.textColor = Color_6;
    
    if (redPackedType == 1) {
        self.contentLabel.hidden = NO;
        self.contentLabel.text = [NSString stringWithFormat:@"%@-%@",contentDict[@"money"],contentDict[@"num"]];
        
        self.redIcon.image = (cellStatus == 0)?[UIImage imageNamed:@"mess_packed_icon_nor"]:[UIImage imageNamed:@"mess_packed_icon_open"];
        self.redIcon.hidden = NO;
    } else if (redPackedType == 2) {
        self.contentLabel.hidden = NO;
        self.contentLabel.text = [NSString stringWithFormat:@"%@-%@",contentDict[@"money"],contentDict[@"count"]];
        self.redIcon.hidden = YES;
    } else if (redPackedType == 3) {
        
        NSDictionary *nograDict = (NSDictionary *)contentDict[@"nograbContent"];
        NSArray *bombNumListArray = [(NSString *)nograDict[@"bombList"] mj_JSONObject];
        bombNumListArray = [FUNCTION_MANAGER orderBombArray:bombNumListArray];
//        NSString *mineNumStr = @"[";
//
//        for (NSInteger index = 0; index < bombNumListArray.count; index++) {
//            if (index == bombNumListArray.count -1) {
//                mineNumStr = [mineNumStr stringByAppendingString: [NSString stringWithFormat:@"%@]", bombNumListArray[index]]];
//            } else {
//                mineNumStr = [mineNumStr stringByAppendingString: [NSString stringWithFormat:@"%@", bombNumListArray[index]]];
//            }
//        }
        NSString *mineNumStr = [FUNCTION_MANAGER formatBombArrayToString:bombNumListArray];
        mineNumStr = [mineNumStr stringByAppendingString: [nograDict[@"type"] integerValue] == 1 ? @"" : @" 不"];
//        self.contentLabel.text = [NSString stringWithFormat:@"%zd-%@", [contentDict[@"money"] integerValue], mineNumStr];
        self.contentLabel.text = [NSString stringWithFormat:@"%@",  mineNumStr];

        self.contentLabel.hidden = NO;
//        _contentLabel.text = [NSString stringWithFormat:@"%@-%@",contentDict[@"money"],contentDict[@"num"]];
        self.redIcon.image = (cellStatus == 0)?[UIImage imageNamed:@"mess_packed_icon_nor"]:[UIImage imageNamed:@"mess_packed_icon_open"];
        self.redIcon.hidden = NO;
    } else {
        self.contentLabel.hidden = YES;
        self.redIcon.hidden = YES;
    }
    
    if (cellStatus == 0) {
        self.descLabel.text = @"查看红包";
    } else if (cellStatus == 1) {
        self.descLabel.text = @"红包已领取";
    } else if (cellStatus == 2) {
        self.descLabel.text = @"红包已被领完";
    } else {
        self.descLabel.text = @"红包已过期";
    }
    
    if (redPackedType == 0) {
        [self.contentLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.bubbleBackgroundView.mas_top).offset(14);
        }];

        if (MessageDirection_SEND == self.messageDirection) {
            [_descLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.contentLabel.mas_bottom).offset(8);
                make.left.mas_equalTo(self.bubbleBackgroundView.mas_left).offset(56);
            }];
           
        } else {
            [self.descLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.contentLabel.mas_bottom).offset(8);
                make.right.mas_equalTo(self.bubbleBackgroundView.mas_right).offset(-52);
            }];
        }
        
    } else if (redPackedType == 2) {
        [self.contentLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.bubbleBackgroundView.mas_top).offset(25);
        }];
        
        if (MessageDirection_SEND == self.messageDirection) {
            [self.descLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.contentLabel.mas_bottom).offset(2);
                make.left.mas_equalTo(self.contentLabel.mas_left);
            }];
        } else {
            [self.contentLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.bubbleBackgroundView.mas_top).offset(25);
                make.left.equalTo(self.redIcon.mas_right).offset(12);
            }];
            [self.descLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.contentLabel.mas_bottom).offset(2);
                make.left.mas_equalTo(self.redIcon.mas_right).offset(14);
            }];
        }
    } else {
        [self.descLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.contentLabel.mas_bottom).offset(3);
            make.left.mas_equalTo(self.redIcon.mas_right).offset(10);
        }];
    }
    
    
    CGRect bubbleFrame = self.messageContentView.frame;
    CGRect messageFrame = self.messageContentView.frame;
//    NSLog(@"%@", [NSString stringWithFormat:@"111 %@----------%@", NSStringFromCGRect(messageFrame), NSStringFromCGRect(bubbleFrame)]);
//    messageFrame.origin.x = (MessageDirection_RECEIVE == self.messageDirection)?HeadAndContentSpacing +
//    [RCIM sharedRCIM].globalMessagePortraitSize.width + 10:
//    self.baseContentView.bounds.size.width - (messageFrame.size.width + HeadAndContentSpacing +
//                                              [RCIM sharedRCIM].globalMessagePortraitSize.width + 10);

    if (MessageDirection_RECEIVE == self.messageDirection) {
        messageFrame.origin.x = HeadAndContentSpacing +
        [RCIM sharedRCIM].globalMessagePortraitSize.width + 10;
    } else {
        messageFrame.origin.x = self.baseContentView.bounds.size.width - (messageFrame.size.width + HeadAndContentSpacing +
                                                                          [RCIM sharedRCIM].globalMessagePortraitSize.width + 10);
    }
//    NSLog(@"%@", [NSString stringWithFormat:@"111 %@----------%@", NSStringFromCGRect(messageFrame), NSStringFromCGRect(bubbleFrame)]);
    UIImage *bubbleImage;
    if (MessageDirection_SEND == self.messageDirection) {
        
        if (redPackedType == 0) {
            bubbleImage = (cellStatus == 0)?[UIImage imageNamed:@"redp_back_fu_S"]:[UIImage imageNamed:@"redp_back_fu_disabled_S"];
            
        } else if (redPackedType == 2) {
            bubbleImage = (cellStatus == 0)?[UIImage imageNamed:@"redp_back_cow_S"]:[UIImage imageNamed:@"redp_back_cow_disabled_S"];
        } else {
            bubbleImage = (cellStatus == 0)?[UIImage imageNamed:@"redp_back_S"]:[UIImage imageNamed:@"redp_back_disabled_S"];
            
            [_redIcon mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.bubbleBackgroundView.mas_left).offset(14);
                make.top.equalTo(self.bubbleBackgroundView.mas_top).offset(15);
            }];
        }
         _descLabel.textAlignment = NSTextAlignmentLeft;
        [_redTypeLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.bubbleBackgroundView.mas_left).offset(10);
            make.bottom.equalTo(self.bubbleBackgroundView.mas_bottom).offset(-3);
        }];
        
    } else {
        if (redPackedType == 0) {
            bubbleImage = (cellStatus == 0)?[UIImage imageNamed:@"redp_back_fu_R"]:[UIImage imageNamed:@"redp_back_fu_disabled_R"];
        } else if (redPackedType == 2) {
            bubbleImage = (cellStatus == 0)?[UIImage imageNamed:@"redp_back_cow_R"]:[UIImage imageNamed:@"redp_back_cow_disabled_R"];
        } else {
            bubbleImage = (cellStatus == 0)?[UIImage imageNamed:@"redp_back_R"]:[UIImage imageNamed:@"redp_back_disabled_R"];
            
            [self.redIcon mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.bubbleBackgroundView.mas_left).offset(21);
                make.top.equalTo(self.bubbleBackgroundView.mas_top).offset(15);
            }];
        }
        
        self.descLabel.textAlignment = NSTextAlignmentRight;
        [self.redTypeLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.bubbleBackgroundView.mas_left).offset(18);
            make.bottom.equalTo(self.bubbleBackgroundView.mas_bottom).offset(-3);
        }];
        
    }
    
    
    
    bubbleFrame = (MessageDirection_SEND == self.messageDirection)?CGRectMake(0, 0, messageFrame.size.width, messageFrame.size.height):CGRectMake(0, 0, messageFrame.size.width, messageFrame.size.height);
    bubbleImage = (MessageDirection_SEND == self.messageDirection)?[bubbleImage resizableImageWithCapInsets:UIEdgeInsetsMake(bubbleImage.size.height * 0.8, bubbleImage.size.width * 0.8,
                                                                                                                             bubbleImage.size.height * 0.2, bubbleImage.size.width * 0.2)]:[bubbleImage resizableImageWithCapInsets:UIEdgeInsetsMake(bubbleImage.size.height * 0.8, bubbleImage.size.width * 0.2,
                                                                                                                                                                                                                                                     bubbleImage.size.height * 0.2, bubbleImage.size.width * 0.8)];
    
    self.bubbleBackgroundView.image = bubbleImage;
    self.messageContentView.frame = messageFrame;
    self.bubbleBackgroundView.frame = bubbleFrame;
    
//    NSLog(@"%@", [NSString stringWithFormat:@"111 %@----------%@", NSStringFromCGRect(messageFrame), NSStringFromCGRect(bubbleFrame)]);
}

- (void)tapTextMessage:(UIGestureRecognizer *)gestureRecognizer {
    if ([self.delegate respondsToSelector:@selector(didTapMessageCell:)]) {
        [self.delegate didTapMessageCell:self.model];
    }
}


@end
