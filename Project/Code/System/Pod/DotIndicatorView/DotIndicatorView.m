//
//  TYDotIndicatorView.m
//  TYDotIndicatorView
//
//  Created by Tu You on 14-1-12.
//  Copyright (c) 2014年 Tu You. All rights reserved.
//

#import "DotIndicatorView.h"

static const NSUInteger dotNumber = 3;
static const CGFloat dotSeparatorDistance = 12.0f;

@interface DotIndicatorView (){
}

@property (nonatomic, assign) TYDotIndicatorViewStyle dotStyle;
@property (nonatomic, assign) CGSize dotSize;
@property (nonatomic, retain) NSMutableArray *dots;
@property (nonatomic, assign) BOOL animating;
@property (nonatomic, assign) BOOL show;
@property (nonatomic, assign) BOOL needDismiss;

@end

@implementation DotIndicatorView
static DotIndicatorView *indicatorView = nil;

+ (DotIndicatorView *)sharedInstance
{
    if(indicatorView == nil){
        indicatorView = [[DotIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 140, 80) dotStyle:TYDotIndicatorViewStyleCircle dotColor:[UIColor colorWithWhite:1.0 alpha:1.0] dotSize:CGSizeMake(13, 13)];
        indicatorView.backgroundColor = COLOR_X(40, 40, 40, 0.9);
    };
    return indicatorView;
}

+(void)destroyInstance{
    if(indicatorView){
        [indicatorView removeFromSuperview];
        indicatorView = nil;
    }
}

-(void)showWithText:(NSString *)text{
    [self showWithText:text andSuperView:nil];
}

-(void)showWithText:(NSString *)text andSuperView:(UIView *)view{
    self.needDismiss = NO;

    UILabel *label = (UILabel *)[self viewWithTag:99];
    if(self.show){
        label.text = text;
        return;
    }
    CGRect rect = self.frame;
    if(text == nil){
        rect.size.height = 50;
    }else
        rect.size.height = 75;
    
    label.text = text;
    self.frame = rect;
    
    if(view == nil)
        view = [self getMainView];
    [view addSubview:self];
    
    self.center = CGPointMake(view.frame.size.width/2.0, view.frame.size.height/2.0 - 30);

    self.alpha = 0.0;
    self.show = YES;
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 1.0;
    } completion:^(BOOL finished) {
        if(self.needDismiss){
            self.needDismiss = NO;
            [self clearSelf];
        }
    }];

    [self startAnimating];
}

- (id)initWithFrame:(CGRect)frame
           dotStyle:(TYDotIndicatorViewStyle)style
           dotColor:(UIColor *)dotColor
            dotSize:(CGSize)dotSize{
    self = [super initWithFrame:frame];
    
    if (self){
        _dotStyle = style;
        _dotSize = dotSize;
        _hidesWhenStopped = YES;
        
        _dots = [[NSMutableArray alloc] init];
        
        CGFloat xPos = CGRectGetWidth(frame) / 2 - dotSize.width * 3 / 2 - dotSeparatorDistance;
        CGFloat yPos = 50 / 2 - _dotSize.height / 2;
        
        for (int i = 0; i < dotNumber; i++){
            CAShapeLayer *dot = [CAShapeLayer new];
            dot.path = [self createDotPath].CGPath;
            dot.frame = CGRectMake(xPos, yPos, _dotSize.width, _dotSize.height);
            dot.opacity = 0.3 * i;
            dot.fillColor = dotColor.CGColor;
            
            [self.layer addSublayer:dot];
            
            [_dots addObject:dot];
            
            xPos = xPos + (dotSeparatorDistance + _dotSize.width);
        }

        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 42, frame.size.width, 16)];
        label.textColor = [UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1.0];
        label.font = [UIFont systemFontOfSize:[UIFont systemFontSize] + 1];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.tag = 99;
        [self addSubview:label];
        
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 8.0;
    }
    return self;
}

- (UIBezierPath *)createDotPath{
    CGFloat cornerRadius = 0.0f;
    if (_dotStyle == TYDotIndicatorViewStyleSquare){
        cornerRadius = 0.0f;
    }
    else if (_dotStyle == TYDotIndicatorViewStyleRound){
        cornerRadius = 2;
    }
    else if (_dotStyle == TYDotIndicatorViewStyleCircle){
        cornerRadius = self.dotSize.width / 2;
    }
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, self.dotSize.width, self.dotSize.height) cornerRadius:cornerRadius];
    
    return bezierPath;
}

- (CAAnimation *)fadeInAnimation:(CFTimeInterval)delay{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.fromValue = @(0.3f);
    animation.toValue = @(1.0f);
    animation.duration = 0.9f;
    animation.beginTime = delay;
    animation.autoreverses = YES;
    animation.repeatCount = HUGE_VAL;
    return animation;
}

- (void)startAnimating{
    if (_animating){
        return;
    }
    _animating = YES;

    for (int i = 0; i < _dots.count; i++){
        [_dots[i] addAnimation:[self fadeInAnimation:i * 0.4] forKey:@"fadeIn"];
    }
}

- (void)stopAnimating{
    if (!_animating){
        return;
    }
    _animating = NO;
    for (int i = 0; i < _dots.count; i++){
        [_dots[i] removeAllAnimations];
    }
}

- (BOOL)isAnimating{
    return _animating;
}

-(void)dismiss{
    if(self.show == NO){
        self.needDismiss = YES;
        return;
    }
    [self clearSelf];
}

-(void)clearSelf{
    __weak __typeof(self)weakSelf = self;
    [UIView animateWithDuration:0.25 animations:^{
        weakSelf.alpha = 0.0;
    } completion:^(BOOL finished) {
        weakSelf.show = NO;
        indicatorView = nil;
        [weakSelf removeFromSuperview];
    }];
}

- (void)removeFromSuperview{
    [self stopAnimating];
    [super removeFromSuperview];
    indicatorView = nil;
}

-(UIView *)getMainView{
    UIView *view = nil;
    NSEnumerator *frontToBackWindows = [[[UIApplication sharedApplication]windows]reverseObjectEnumerator];
    for (UIWindow *window in frontToBackWindows)
        if (window.windowLevel == UIWindowLevelNormal) {
            view = window;
            break;
        }
    return view;
}
@end
