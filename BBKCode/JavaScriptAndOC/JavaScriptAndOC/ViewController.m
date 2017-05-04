//
//  ViewController.m
//  JavaScriptAndOC
//
//  Created by zxx_mbp on 2017/5/3.
//  Copyright © 2017年 zxx_mbp. All rights reserved.
//

#import "ViewController.h"


/**
 ObjC与JS交互方式
 
 通过JSContext，我们有两种调用JS代码的方法：
 
 1、直接调用JS代码
 2、在ObjC中通过JSContext注入模型，然后调用模型的方法
 */
@interface ViewController ()<UIWebViewDelegate>

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) JSContext *jsContext;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //一、直接调用JS代码
   /*
    // 一个JSContext对象，就类似于Js中的window，
    // 只需要创建一次即可。
    self.jsContext = [[JSContext alloc] init];
    
    //  jscontext可以直接执行JS代码。
    [self.jsContext evaluateScript:@"var num = 10"];
    [self.jsContext evaluateScript:@"var squareFunc = function(value) { return value * 2 }"];
    // 计算正方形的面积
    JSValue *square = [self.jsContext evaluateScript:@"squareFunc(num)"];
    
    // 也可以通过下标的方式获取到方法
    JSValue *squareFunc = self.jsContext[@"squareFunc"];
    JSValue *value = [squareFunc callWithArguments:@[@"20"]];
    NSLog(@"%@", square.toNumber);
    NSLog(@"%@", value.toNumber);
    */
    
    [self.view addSubview:self.webView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIWebView *)webView {
    if (!_webView) {
        _webView = [[UIWebView alloc]initWithFrame:self.view.bounds];
        _webView.scalesPageToFit = YES;
        NSURL *url = [[NSBundle mainBundle] URLForResource:@"test" withExtension:@"html"];
        NSURLRequest* request = [NSURLRequest requestWithURL:url];
        [_webView loadRequest:request];
        _webView.delegate = self;
    }
    return _webView;
}

#pragma mark - UIWebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    //二、通过注入模型的方式交互
    self.jsContext = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    //通过模型调用方法，这种方法更好些
    HYBJsObjCModel* model = [[HYBJsObjCModel alloc]init];
    self.jsContext[@"OCModel"] = model;
    model.jsContext = self.jsContext;
    model.webView = self.webView;
    
    self.jsContext.exceptionHandler = ^(JSContext *context, JSValue *exception) {
        context.exception = exception;
        NSLog(@"异常信息：%@",exception);
    };
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    
}
@end
