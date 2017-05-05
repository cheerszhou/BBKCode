//
//  ViewController.m
//  SpotJavaScriptContext
//
//  Created by zxx_mbp on 2017/5/4.
//  Copyright © 2017年 zxx_mbp. All rights reserved.
//

#import "ViewController.h"
#import "UIWebView+ZXX_JavaScriptContext.h"

@protocol JS_ZXXViewController <JSExport>

- (void)sayGoodbye;

@end

@interface ViewController ()<ZXXWebViewDelegate,JS_ZXXViewController>
@property (nonatomic, strong) UIWebView *webView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSURL *htmlURL = [[NSBundle mainBundle] URLForResource:@"testWebView" withExtension:@"htm"];
    [self.webView loadRequest:[NSURLRequest requestWithURL:htmlURL]];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)webView:(UIWebView *)webView didCreateJavaScriptContext:(JSContext *)ctx {
    ctx[@"sayHello"] = ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView* av = [[UIAlertView alloc]initWithTitle:@"Hello, world!" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil , nil];
            [av show];
        });

    };
    ctx[@"viewController"] = self;
}

- (void)sayGoodbye {
    UIAlertView* av = [[UIAlertView alloc]initWithTitle:@"Goodbye, World!" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [av show];
}

- (UIWebView *)webView {
    if (!_webView) {
        _webView = [[UIWebView alloc]initWithFrame:self.view.bounds];
        _webView.delegate = self;
        [self.view addSubview:self.webView];
    }
    return _webView;
}

@end
