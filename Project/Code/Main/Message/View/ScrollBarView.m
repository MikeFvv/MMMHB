//
//  ScrollBarView.m
//  Project
//
//  Created by fy on 2019/1/2.
//  Copyright © 2019 CDJay. All rights reserved.
//

#import "ScrollBarView.h"

@implementation ScrollBarView

+(ScrollBarView *)createWithFrame:(CGRect)rect{
    ScrollBarView *view = [[ScrollBarView alloc] initWithFrame:rect];
    return view;
}

-(instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        self.backgroundColor = [UIColor whiteColor];
        
        UIImageView *iconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"horn"]];
        iconView.backgroundColor = [UIColor clearColor];
        iconView.frame = CGRectMake(0, 0, 45, frame.size.height);
        iconView.contentMode = UIViewContentModeCenter;
        [self addSubview:iconView];
        
        UIImageView *shadowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"touying"]];
        shadowView.frame = CGRectMake(iconView.frame.size.width +iconView.frame.origin.x * 2 - 6, 8, 8, self.frame.size.height - 16);
        shadowView.contentMode = UIViewContentModeCenter;
        [self addSubview:shadowView];
        
        NSInteger startX = shadowView.frame.origin.x + shadowView.frame.size.width - 3;
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(startX, 0, self.frame.size.width - startX, self.frame.size.height)];
        view.clipsToBounds = YES;
        [self insertSubview:view belowSubview:shadowView];
        
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize2:15];
        label.textColor = Color_3;
        self.textLabel = label;
        [view addSubview:label];
    }
    return self;
}

-(void)initShow{
    NSMutableString *s = [[NSMutableString alloc] initWithString:@""];
    for (NSString *txt in self.textArray) {
        if(s.length > 0)
            [s appendString:@"     "];
        [s appendString:txt];
    }
    NSMutableAttributedString * attrString = [[NSMutableAttributedString alloc] initWithString:s];
    NSInteger i = 0;
    for (NSString *txt in self.textArray) {
        UIColor *color = nil;
        if(i%2 == 0)
            color = COLOR_X(100, 100, 100);
        else
            color = Color_3;
        NSRange range = [s rangeOfString:txt];
        [attrString addAttribute:NSForegroundColorAttributeName
                           value:color
                           range:range];
        i += 1;
    }
    self.textLabel.attributedText = attrString;
    [self.textLabel sizeToFit];
    CGRect rrr = self.textLabel.frame;
    rrr.size.height = self.textLabel.superview.frame.size.height;
    self.textLabel.frame = rrr;
//    self.textLabel.frame = CGRectMake(0, 0, sizeWidth, self.superview.frame.size.height);
}

-(void)start{
    [self initShow];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self update];
    });
}

-(void)update{
    float inv = self.textLabel.attributedText.length * 0.5;
    if(inv < 8)
        inv = 8;
    CGRect rect = self.textLabel.frame;
    rect.origin.x = self.textLabel.superview.frame.size.width;
    self.textLabel.frame = rect;
    WEAK_OBJ(weakSelf, self);
    [UIView animateWithDuration:inv delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        weakSelf.textLabel.frame = CGRectMake( - weakSelf.textLabel.frame.size.width, 0, weakSelf.textLabel.frame.size.width, weakSelf.frame.size.height);
    } completion:^(BOOL finished) {
        if(finished)
            [weakSelf update];
    }];
}

-(void)stop{
    [self.layer removeAllAnimations];
    self.textLabel.hidden = YES;
}

-(void)dealloc{
    [self stop];
}
@end
