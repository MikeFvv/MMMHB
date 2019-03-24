//
//  ScrollBarView.h
//  Project
//
//  Created by fy on 2019/1/2.
//  Copyright © 2019 CDJay. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ScrollBarView : UIView
@property(nonatomic,strong)UILabel *textLabel;
@property(nonatomic,strong)NSArray *textArray;
@property(nonatomic,copy)CallbackBlock tapBlock;

+(ScrollBarView *)createWithFrame:(CGRect)rect;
-(void)start;
-(void)stop;

@end
NS_ASSUME_NONNULL_END
