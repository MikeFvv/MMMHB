//
//  UIButtonCus.m
//  FjeapStudy
//
//  Created by fjeap.com on 16/7/12.
//  Copyright © 2016年 wc All rights reserved.
//

#import "UIButton+Ani.h"

@implementation UIButton(UIButtonAni)

-(void)addTouchAni{
    [self addTarget:self action:@selector(starAni) forControlEvents:UIControlEventTouchDown];
    [self addTarget:self action:@selector(endAni) forControlEvents:UIControlEventTouchDragOutside];
    [self addTarget:self action:@selector(endAni) forControlEvents:UIControlEventTouchUpInside];

}

-(void)starAni{
    self.transform = CGAffineTransformMakeScale(1.05, 1.05);
}

-(void)endAni{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [UIView animateWithDuration:0.2 animations:^{
        self.transform = CGAffineTransformMakeScale(1.0, 1.0);
    }];
}

-(void)delayEnable {//延迟一段时间才能点
    [self addTarget:self action:@selector(delayEnableAction) forControlEvents:UIControlEventTouchUpInside];
}

-(void)delayEnableAction{
    self.userInteractionEnabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.userInteractionEnabled = YES;
    });
}
@end
