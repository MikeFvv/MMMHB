//
//  CDAlertViewController.h
//  Project
//
//  Created by mac on 2018/9/7.
//  Copyright © 2018年 CDJay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CDAlertViewController : UIViewController
@property(nonatomic,strong)  UIDatePicker *picker;
+ (void)showDatePikerDate:(void (^)(NSString *))date;
+ (void)showDatePikerDate:(void (^)(NSString *))date defaultTime:(double)defaultTime;
@end
