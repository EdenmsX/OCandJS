//
//  ViewController.m
//  OCAndJSDemo
//
//  Created by 刘李斌 on 2020/6/10.
//  Copyright © 2020 Brilliance. All rights reserved.
//

#import "ViewController.h"
#import <objc/message.h>
#import <JavaScriptCore/JavaScriptCore.h>

#import "lbJsObject.h"

#import "WKViewController.h"



@interface ViewController () <UIWebViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

/** webView */
@property(nonatomic, strong) UIWebView *webview;

/**  */
@property(nonatomic, strong) JSContext *jscontext;

/** i */
@property(nonatomic, strong) UIImagePickerController *imageP;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"Test" style:UIBarButtonItemStylePlain target:self action:@selector(rightBtnClick)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithTitle:@"WK" style:UIBarButtonItemStylePlain target:self action:@selector(leftBtnClick)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    self.webview = [[UIWebView alloc] initWithFrame:self.view.bounds];
    self.webview.delegate = self;
    [self.view addSubview:self.webview];
    
//    NSURL *url = [NSURL URLWithString:@"https://www.baidu.com"];
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"index.html" withExtension:nil];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    [self.webview loadRequest:req];
}
- (void)leftBtnClick {
    
    WKViewController *vc = [[WKViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)rightBtnClick {
    NSLog(@"right click");
    //OC调用JS  进入点击事件后调用JS页面的showAlert方法
//    [self.webview stringByEvaluatingJavaScriptFromString:@"showAlert('abc')"];
    
//    [self.jscontext evaluateScript:@"submit()"];
    [self.jscontext evaluateScript:@"dgasfgjas()"];
}

- (void)getSum {
    NSLog(@"oc getSum");
}
- (void)getPlus {
    NSLog(@"oc getPlus");
}

#pragma mark - UIWebViewDelegate
//每次js页面有响应事件触发都会进入这个方法

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    //加载所有请求数据  并且控制是否拦截
    if ([request.URL.scheme isEqualToString:@"test"]) {
//        NSArray *paths = request.URL.pathComponents;
        NSString *host = request.URL.host;
//        if ([host isEqualToString:@"getSum"]) {
//            [self getSum];
//        } else if ([host isEqualToString:@"getPlus"]) {
//            [self getPlus];
//        } else {
//
//        }
        /* 方式二
        SEL method = NSSelectorFromString(host);
        if ([self respondsToSelector:method]) {
            [self performSelector:method];
        } else {
            NSLog(@"没有响应");
        }
        */
        SEL method = NSSelectorFromString(host);
        if ([self respondsToSelector:method]) {
//            [self performSelector:method];
            objc_msgSend(self, method, @"123");
        } else {
            NSLog(@"没有响应");
        }
        
        //需要自定义的时间就进行拦截,return NO,不执行JS页面原始的响应
        return NO;
    }
    
    
    //return YES, JS页面可以继续打开其他的页面,  return NO,拦截JS页面的事件,不让其继续进行(不让点击事件等事件触发)
    return YES;
}
- (void)webViewDidStartLoad:(UIWebView *)webView {
    NSLog(@"开始加载");
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSLog(@"加载完成");
    
    NSString *title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    self.title = title;
    
    //获取JS页面的上下文
    JSContext *context = [self.webview valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    self.jscontext = context;
    //创建全局变量
    [context evaluateScript:@"var arr = ['NSLOG', 'NSArray', 'NSString']"];
    
    //创建JS页面的showMessage方法的调用方法, 当js页面调用了showMessage方法,就会调用这个代码块
    context[@"showMessage"] = ^{
        NSArray *arr = [JSContext currentArguments];
        NSLog(@"\n %@", arr);
        JSValue *thisValue = [JSContext currentThis];
        NSLog(@"\n thist value = %@", thisValue);
        JSValue *thisCallee = [JSContext currentCallee];
        NSLog(@"\n thist Callee = %@", thisCallee);
        
        //调用JS中的其他方法
        NSDictionary *dict = @{
            @"name": @"zhangsan",
            @"age": @"12"
        };
        //调用ocCalljs方法,并传参
        [[JSContext currentContext][@"ocCalljs"] callWithArguments:@[dict]];
    };
    
    //异常收集
    self.jscontext.exceptionHandler = ^(JSContext *context, JSValue *exception) {
        NSLog(@"\n %@", exception);
    };
    
    //JS操作OC对象
    lbJsObject *obj = [lbJsObject new];
    self.jscontext[@"lbObject"] = obj;
    
    
    //JS操作OC使用空间
    NSLog(@"----%@",[NSThread currentThread]);
    __weak typeof(self) weakSelf = self;
    self.jscontext[@"getImage"] = ^{
        NSLog(@"%@",[NSThread currentThread]);
        //block在子线程  需要手动切换线程更新UI
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf openImgPickerView];
        });
    };
    
    
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"加载 出错   %@", error);
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey, id> *)info {
    NSLog(@"--%@",info);
    
    UIImage *image = [info objectForKey:@"UIImagePickerControllerEditedImage"];
    NSData *imageData = UIImageJPEGRepresentation(image, 0.01);
    NSString *encodeImageStr = [imageData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    NSString *newImageStr = [self removeSpaceAndNewline:encodeImageStr];
    [self dismissViewControllerAnimated:YES completion:nil];
    NSString *jsFuncStr = [NSString stringWithFormat:@"showImage('%@')", newImageStr];
    [self.jscontext evaluateScript:jsFuncStr];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
}


- (NSString *)removeSpaceAndNewline:(NSString *)str
{
    NSString *temp = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
    temp = [temp stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    temp = [temp stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    return temp;
}


//- (void)openAlbum{
//    self.imagePicker = [[UIImagePickerController alloc] init];
//    self.imagePicker.delegate = self;
//    self.imagePicker.allowsEditing = YES;
//    self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
//    [self presentViewController:self.imagePicker animated:YES completion:nil];
//}

- (void)openImgPickerView {
    self.imageP = [[UIImagePickerController alloc] init];
    self.imageP.delegate = self;
    self.imageP.allowsEditing = YES;
    self.imageP.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:self.imageP animated:YES completion:^{
        NSLog(@"打开相册");
    }];
}



@end
