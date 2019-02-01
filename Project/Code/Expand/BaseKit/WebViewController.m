//
//  WebViewController.m
//  Project
//
//  Created by mini on 2018/8/14.
//  Copyright © 2018年 CDJay. All rights reserved.
//

#import "WebViewController.h"
#import <WebKit/WebKit.h>
#import "WebProgressView.h"

@interface WebViewController ()<WKUIDelegate,WKNavigationDelegate,UINavigationBarDelegate>{
    WKWebView *_webView;
    WebProgressView *_progress;
    NSString *_url;
    NSString *_htmlString;
}
@end

@implementation WebViewController
- (instancetype)initWithUrl:(NSString *)url{
    self = [super init];
    if (self) {
        _url = url;
    }
    return self;
}

- (instancetype)initWithHtmlString:(NSString *)string{
    self = [super init];
    if (self) {
        _htmlString = string;
    }
    return self;
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [_progress removeFromSuperview];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initData];
    [self initSubviews];
    [self initLayout];
}


#pragma mark Data
- (void)initData{
    
}

#pragma mark subView
- (void)initSubviews{
    
    //    UIBarButtonItem *leftItem = self.navigationItem.backBarButtonItem;
    
    _webView = [[WKWebView alloc]init];
    [self.view addSubview:_webView];
    _webView.UIDelegate = self;
    _webView.navigationDelegate = self;
    _webView.backgroundColor = CDCOLOR(245, 245, 245);
    
    [_webView addObserver:self forKeyPath:@"estimatedProgress"options:NSKeyValueObservingOptionNew context:NULL];
    
    CGRect frame = self.navigationController.navigationBar.bounds;
    _progress = [[WebProgressView alloc]initWithFrame:CGRectMake(0, frame.size.height-2, frame.size.width, 2)];
    [self.navigationController.navigationBar addSubview:_progress];
    [_progress setProgress:0 animated:NO];
}

#pragma mark Layout
- (void)initLayout{
    [_webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    if (_url.length) {
         [self loadUrl];
    }
    if (_htmlString) {
        [self loadHtml];
    }
}

- (void)loadUrl{
    NSURLRequest *req = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:_url]];
    [_webView loadRequest:req];
}

- (void)loadHtml{
    [_webView loadHTMLString:_htmlString baseURL:nil];
}

- (BOOL)navigationShouldPopOnBackButton {
    BOOL cangoBack = [_webView canGoBack];
    if (cangoBack) {
        [_webView goBack];
        return NO;
    }
    else{
        CDPop(self.navigationController, YES);
        return YES;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        NSLog(@"%.2f",_webView.estimatedProgress);
        [_progress setProgress:_webView.estimatedProgress animated:YES];
    }
}

#pragma mark - WKNavigationDelegate
// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    
}
// 当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation{
    
}
// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    [_progress setProgress:0 animated:NO];
    self.navigationItem.title = webView.title;
    NSLog(@"%@",webView.title);
}

// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error{
    self.navigationItem.title = @"加载失败，请检查网络";
    [_progress setProgress:0 animated:NO];
}

- (void)dealloc {
    [_progress removeFromSuperview];
    [_webView removeObserver:self forKeyPath:@"estimatedProgress"];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
