//
//  WebViewController.h
//  Project
//
//  Created by mini on 2018/8/14.
//  Copyright © 2018年 CDJay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController

- (instancetype)initWithUrl:(NSString *)url;
- (instancetype)initWithHtmlString:(NSString *)string;

@end
