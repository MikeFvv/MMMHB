//
//  WebViewController.h
//  Project
//
//  Created by mini on 2018/8/14.
//  Copyright © 2018年 CDJay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "WebProgressView.h"

@interface WebViewController : SuperViewController{
    NSString *_url;
}
@property(nonatomic,strong)WKWebView *webView;

- (instancetype)initWithUrl:(NSString *)url;
- (instancetype)initWithHtmlString:(NSString *)string;

@end
