//
//  EnvelopAnimationView.h
//  Project
//
//  Created by mini on 2018/8/13.
//  Copyright © 2018年 CDJay. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^AnimationBlock)(void);
typedef void (^DetailBlock)(void);

@interface EnvelopAnimationView : UIView

- (void)updateView:(id)obj;
- (void)showInView:(UIView *)view;
@property (nonatomic ,copy) AnimationBlock block;
@property (nonatomic ,copy) DetailBlock detail;

@end
