//
//  GroupRuleView.h
//  Project
//
//  Created by Mike on 2019/1/12.
//  Copyright © 2019 Mike. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MessageItem;

NS_ASSUME_NONNULL_BEGIN

@interface GroupRuleView : UIView

- (void)showInView:(UIView *)view;
- (void)updateView:(MessageItem *)messageItem;
    
@end

NS_ASSUME_NONNULL_END
