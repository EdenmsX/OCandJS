//
//  WKViewController.m
//  OCAndJSDemo
//
//  Created by 刘李斌 on 2020/6/11.
//  Copyright © 2020 Brilliance. All rights reserved.
//

#import "WKViewController.h"
#import <WebKit/WebKit.h>

#import "WebViewBrigdeViewController.h"

@interface WKViewController () <WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler>

/** webview */
@property(nonatomic, strong) WKWebView *webView;

@end

@implementation WKViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithTitle:@"brigde" style:UIBarButtonItemStylePlain target:self action:@selector(leftItemClick)];
    self.navigationItem.rightBarButtonItem = leftItem;
    
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    //如果不做如下的config配置,加载出来的web页面的内容会特别小
    NSString *jScript = @"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);";
    WKUserScript *wkUScript = [[WKUserScript alloc] initWithSource:jScript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
    WKUserContentController *wkUController = [[WKUserContentController alloc] init];
    [wkUController addUserScript:wkUScript];
    config.userContentController = wkUController;
    
    self.webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:config];
    self.webView.UIDelegate = self;
    self.webView.navigationDelegate = self;
    [self.view addSubview:self.webView];
    
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"index.html" withExtension:nil];
//    NSURLRequest *requet = [NSURLRequest requestWithURL:url];
//    [self.webView loadRequest:requet];
    [self.webView loadFileURL:url allowingReadAccessToURL:url];
}

- (void)leftItemClick {
    WebViewBrigdeViewController *vc = [[WebViewBrigdeViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)getSum {
    NSLog(@"oc getSum");
}
- (void)getPlus {
    NSLog(@"oc getPlus");
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.webView.configuration.userContentController addScriptMessageHandler:self name:@"messgaeOC"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"messgaeOC"];
}
#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    //相当于- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
    //拦截操作
    if ([navigationAction.request.URL.scheme isEqualToString:@"test"]) {
        NSString *host = navigationAction.request.URL.host;
        if ([host isEqualToString:@"getSum"]) {
            
                [self getSum];
                decisionHandler(WKNavigationActionPolicyCancel);
            return;
        }
    }
    
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    self.title = webView.title;
}

#pragma mark - WKUIDelegate
//将js页面的alter改为OC自己的Alter
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提醒" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    NSLog(@"\n %@---%@",message.name, message.body);
}

@end
