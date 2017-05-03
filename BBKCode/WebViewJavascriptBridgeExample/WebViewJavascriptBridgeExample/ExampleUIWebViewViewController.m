//
//  ExampleUIWebViewViewController.m
//  WebViewJavascriptBridgeExample
//
//  Created by zxx_mbp on 2017/4/29.
//  Copyright © 2017年 zxx_mbp. All rights reserved.
//

#import "ExampleUIWebViewViewController.h"
#import "WebViewJavascriptBridge.h"

#define kJavascriptHandlerName @"testJavascriptHandler"
#define kObjcCallbackName @"testObjcCallback"

#define kOpenWebViewBridgeArticle @"openWebviewBridgeArticle"
#define kGetUserIdFromObjc @"getUserIdFromObjC"

@interface ExampleUIWebViewViewController ()
@property (nonatomic, strong) WebViewJavascriptBridge *bridge;
@end

@implementation ExampleUIWebViewViewController

- (void)viewWillAppear:(BOOL)animated {
    if (_bridge) {
        return;
    }
    // 1.创建WebView
    UIWebView* webView = [[UIWebView alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:webView];
    
    // 2.开启日志，方便调试
    [WebViewJavascriptBridge enableLogging];
    
    // 3.给webview建立JS与OjbC的沟通桥梁
    _bridge = [WebViewJavascriptBridge bridgeForWebView:webView];
    
    // 4.设置代理，如果不需要实现，可以不设置
    [_bridge setWebViewDelegate:self];
    
    /**
       5.注册HandleName，用于给JS端调用iOS端
     
     JS主动调用OjbC的方法
     这是JS会调用getUserIdFromObjC方法，这是OC注册给JS调用的
     JS需要回调，当然JS也可以传参数过来。data就是JS所传的参数，不一定需要传
     OC端通过responseCallback回调JS端，JS就可以得到所需要的数据
     
     */
    [_bridge registerHandler:@"getUserIdFromObjC" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"testObjcCallback called:%@",data);
        
        // 反馈给JS,OC回调JS
        responseCallback(@"Resonse from testObjcCallback");
    }];
    
    // 6.OC直接调用JS端注册名为textJavascriptHandler的方法
    [_bridge callHandler:@"openWebviewBridgeArticle" data:@{@"foo":@"before ready"} responseCallback:^(id responseData) {
        //反馈给OC，JS回调OC
        NSLog(@"from js:%@", responseData);
    }];
    
    [self renderButtons:webView];
    [self loadExamplePage:webView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIWebViewDelegate
- (void)webViewDidStartLoad:(UIWebView *)webView {
    NSLog(@"%s",__func__);
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSLog(@"%s",__func__);
}

- (void)renderButtons:(UIWebView*)webView {
    UIFont* font = [UIFont fontWithName:@"HelveticaNeue" size:11.0];
    
    UIButton* callbackButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [callbackButton setTitle:@"Call handler" forState:UIControlStateNormal];
    [callbackButton addTarget:self action:@selector(callHandler:) forControlEvents:UIControlEventTouchUpInside];
    [self.view insertSubview:callbackButton aboveSubview:webView];
    callbackButton.frame = CGRectMake(0, 400, 100, 35);
    callbackButton.titleLabel.font = font;
    
    UIButton* reloadButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [reloadButton setTitle:@"Reload webView" forState:UIControlStateNormal];
    [reloadButton addTarget:self action:@selector(reload) forControlEvents:UIControlEventTouchUpInside];
    [self.view insertSubview:reloadButton aboveSubview:webView];
    reloadButton.frame = CGRectMake(90, 400, 100, 35);
    reloadButton.titleLabel.font = font;
    
    UIButton *safetyTimeoutButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [safetyTimeoutButton setTitle:@"Disable safety timeout" forState:UIControlStateNormal];
    [safetyTimeoutButton addTarget:self action:@selector(disableSafetyTimeout) forControlEvents:UIControlEventTouchUpInside];
    safetyTimeoutButton.frame = CGRectMake(190, 400, 120, 35);
    safetyTimeoutButton.titleLabel.font = font;
    [self.view insertSubview:safetyTimeoutButton aboveSubview:webView];
}

- (void)disableSafetyTimeout {
    [self.bridge disableJavscriptAlertBoxSafetyTimeout];
}

- (void)callHandler:(id)sender {
    id data = @{
                @"greetingFromObjC":@"Hi there, JS!"
                };
    [_bridge callHandler:@"openWebviewBridgeArticle" data:data responseCallback:^(id responseData) {
        NSLog(@"testJavascriptHandler responded:%@", data);
    }];
}

- (void)loadExamplePage:(UIWebView*)webView {
    NSString* htmlPath = [[NSBundle mainBundle] pathForResource:@"ExampleApp" ofType:@"html"];
    NSString* appHtml = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
    NSURL* baseUrl = [NSURL fileURLWithPath:htmlPath];
    [webView loadHTMLString:appHtml baseURL:baseUrl];
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
