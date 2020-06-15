//
//  WebViewBrigdeViewController.m
//  OCAndJSDemo
//
//  Created by 刘李斌 on 2020/6/15.
//  Copyright © 2020 Brilliance. All rights reserved.
//

#import "WebViewBrigdeViewController.h"
#import <WebKit/WebKit.h>
#import <WebViewJavascriptBridge.h>

@interface WebViewBrigdeViewController ()<WKUIDelegate, WKNavigationDelegate>

/** webView */
@property(nonatomic, strong) WKWebView *webView;

/** WebViewJavascriptBridge */
@property(nonatomic, strong) WebViewJavascriptBridge *wjb;

@end

@implementation WebViewBrigdeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupUI];
    
}

- (void)setupUI {
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"oc2js" style:UIBarButtonItemStylePlain target:self action:@selector(rightItemClick)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    NSString *script = @"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);";
    WKUserScript *uScript = [[WKUserScript alloc] initWithSource:script injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
    WKUserContentController *uContent = [[WKUserContentController alloc] init];
    [uContent addUserScript:uScript];
    config.userContentController = uContent;
    
    self.webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:config];
    self.webView.UIDelegate = self;
    [self.view addSubview:self.webView];
    
    NSString *urlStr = [[NSBundle mainBundle] pathForResource:@"index.html" ofType:nil];
    NSURL *url = [NSURL fileURLWithPath:urlStr];
    [self.webView loadFileURL:url allowingReadAccessToURL:url];
    
    //JS -> OC   WebViewJavascriptBridge
    self.wjb = [WebViewJavascriptBridge bridgeForWebView:self.webView];
    //如果要实现WKNavigationDelegate的代理,需要设置代理, 不要实现self.webView.navigationDelegate
//    [self.wjb setWebViewDelegate:self];
    
    [self.wjb registerHandler:@"jsCallsOC" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"jsCallsOC:   %@-----%@----%@",[NSThread currentThread], data, responseCallback);
    }];
}


- (void)rightItemClick {
    //OC -> JS
    [self.wjb callHandler:@"OCCallJSFunction" data:@"OC传入数据" responseCallback:^(id responseData) {
        NSLog(@"OCCallJSFunction:   %@-----%@",[NSThread currentThread], responseData);
    }];
}

#pragma mark - WKUIDelegate
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提醒" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

@end
