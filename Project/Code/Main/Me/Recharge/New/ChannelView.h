//
//  ChannelView.h
//  Project
//
//  Created by fangyuan on 2019/5/11.
//  Copyright © 2019 CDJay. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, RechargeType){
    RechargeType_nil = 0,//默认
    RechargeType_gf = 1,//官方
    RechargeType_weiXin = 2,//微信
    RechargeType_zhiFuBao = 3,//支付宝
    RechargeType_yinLian = 4,//银联
};

NS_ASSUME_NONNULL_BEGIN

@interface ChannelView : UIView
@property(nonatomic,copy)CallbackBlock selectBlock;
@property(nonatomic,strong)NSArray *channelArray;
@property(nonatomic,assign)RechargeType rechargeType;

@end

NS_ASSUME_NONNULL_END
