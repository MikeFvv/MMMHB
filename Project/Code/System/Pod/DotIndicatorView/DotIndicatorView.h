//
//  TYDotIndicatorView.h
//  TYDotIndicatorView
//
//  Created by Tu You on 14-1-12.
//  Copyright (c) 2014年 Tu You. All rights reserved.
//

#import <UIKit/UIKit.h>

#define INDICATOR_VIEW [DotIndicatorView sharedInstance]

typedef NS_ENUM(NSInteger, TYDotIndicatorViewStyle)
{
    TYDotIndicatorViewStyleSquare,
    TYDotIndicatorViewStyleRound,
    TYDotIndicatorViewStyleCircle
};

@interface DotIndicatorView : UIView{
    UILabel *_textLabel;
}

+(DotIndicatorView *)sharedInstance;
+(void)destroyInstance;

@property (nonatomic, assign) BOOL hidesWhenStopped;

- (id)initWithFrame:(CGRect)frame
           dotStyle:(TYDotIndicatorViewStyle)style
           dotColor:(UIColor *)dotColor
            dotSize:(CGSize)dotSize;

- (void)startAnimating;
- (void)stopAnimating;
- (BOOL)isAnimating;

-(void)showWithText:(NSString *)text;
-(void)showWithText:(NSString *)text andSuperView:(UIView *)view;

-(void)dismiss;
@end
