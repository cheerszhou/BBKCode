//
//  ViewController.m
//  WKWebViewDemo
//
//  Created by zxx_mbp on 2017/5/5.
//  Copyright © 2017年 zxx_mbp. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>
#import "OCJSHelper.h"

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

static CGFloat addViewHeight = 500;   // 添加自定义 View 的高度
static BOOL showAddView = YES;        // 是否添加自定义 View
static BOOL useEdgeInset = NO;        // 用哪种方法添加自定义View， NO 使用 contentInset，YES 使用 div


@interface ViewController ()<WKUIDelegate,WKNavigationDelegate,UIScrollViewDelegate>
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) OCJSHelper *ocjsHelper;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, assign) CGFloat delayTime;
@property (nonatomic, assign) CGFloat contentHeight;
@property (nonatomic, strong) UIView *addView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    WKWebViewConfiguration* config= [[WKWebViewConfiguration alloc]init];
    config.userContentController = [[WKUserContentController alloc]init];
    //交互对象设置
    [config.userContentController addScriptMessageHandler:(id)self.ocjsHelper name:@"timefor"];
    //支持内嵌视屏播放，不然网页中的视频无法播放
    config.allowsInlineMediaPlayback = YES;
    
    self.webView = [[WKWebView alloc]initWithFrame:self.view.bounds configuration:config];
    self.ocjsHelper.webView = self.webView;
    [self.view addSubview:self.webView];
    
    self.webView.scrollView.delegate = self;
    self.webView.navigationDelegate = self;
    self.webView.UIDelegate = self;
    //开始右滑返回手势
    self.webView.allowsBackForwardNavigationGestures = YES;
    NSString* path = [[NSBundle mainBundle] pathForResource:@"Test" ofType:@"html"];
    NSString* urlstr = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    NSURL* url = [NSURL URLWithString:urlstr];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[[NSBundle mainBundle] URLForResource:@"Test" withExtension:@"html"]]];
    
    self.progressView =[[UIProgressView alloc]initWithFrame:CGRectMake(0, 64, kScreenWidth, 2)];
    [self.view addSubview:self.progressView];
    self.progressView.progressTintColor = [UIColor greenColor];
    self.progressView.trackTintColor = [UIColor clearColor];
    
    NSKeyValueObservingOptions observingOptions = NSKeyValueObservingOptionNew;
    //KVO监听属性，除了下面列举的两个，还有其他的一些属性，具体参考WKWebView.h
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:observingOptions context:nil];
    [self.webView addObserver:self forKeyPath:@"title" options:observingOptions context:nil];
    
    //监听 self.webView.scrollView的contentSize 属性改变，从而对底部添加自定义view进行位置调整
    [self.webView.scrollView addObserver:self forKeyPath:@"contentSize" options:observingOptions context:nil];
}

- (void)dealloc {
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
    [self.webView removeObserver:self forKeyPath:@"title"];
    [self.webView.scrollView removeObserver:self forKeyPath:@"contentSize"];
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"timefor"];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        [self.progressView setProgress:self.webView.estimatedProgress animated:YES];
        if (self.webView.estimatedProgress < 1.0) {
            self.delayTime = 1 - self.webView.estimatedProgress;
            return;
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.delayTime*NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.progressView.progress = 0;
        });
    }else if([keyPath isEqualToString:@"title"]) {
        self.title = self.webView.title;
    }else if([keyPath isEqualToString:@"contentSize"]){
        if (self.contentHeight != self.webView.scrollView.contentSize.height) {
            self.contentHeight = self.webView.scrollView.contentSize.height;
            self.addView.frame = CGRectMake(0, self.contentHeight - addViewHeight, kScreenWidth, addViewHeight);
            NSLog(@"----------%@", NSStringFromCGSize(self.webView.scrollView.contentSize));
        }

    }
}

#pragma mark - WKNavigationDelegate
// 开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"didStartProvisionalNavigation   ====    %@", navigation);
}
// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"didFailProvisionalNavigation   ====    %@\nerror   ====   %@", navigation, error);
}

// 内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"didCommitNavigation   ====    %@", navigation);
}

// 在发送请求之前，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSLog(@"decidePolicyForNavigationAction   ====    %@", navigationAction);
    decisionHandler(WKNavigationActionPolicyAllow);
}

// 在收到响应后，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    NSLog(@"decidePolicyForNavigationResponse   ====    %@", navigationResponse);
    decisionHandler(WKNavigationResponsePolicyAllow);
}

//页面加载完调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    NSLog(@"didfinishNavigation ====   %@",navigation);
    if (!showAddView) {
        return;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.webView.scrollView addSubview:self.addView];
        if (useEdgeInset) {
            //url 使用 test.html
            self.webView.scrollView.contentInset = UIEdgeInsetsMake(64, 0, addViewHeight, 0);
        }else{
            NSString* js = [NSString stringWithFormat:@"\
                            var appendDiv = document.getElementById(\"AppAppendDIV\");\
                            if (appendDiv) {\
                            appendDiv.style.height = %@+\"px\";\
                            } else {\
                            var appendDiv = document.createElement(\"div\");\
                            appendDiv.setAttribute(\"id\",\"AppAppendDIV\");\
                            appendDiv.style.width=%@+\"px\";\
                            appendDiv.style.height=%@+\"px\";\
                            document.body.appendChild(appendDiv);\
                            }\
                            ", @(addViewHeight), @(kScreenWidth), @(addViewHeight)];
            [self.webView evaluateJavaScript:js completionHandler:^(id _Nullable value, NSError * _Nullable error) {
                //执行完上面的那段 JS，webView.scrollView.contentSize.height 的高度已经是加上 div 的高度
                self.addView.frame = CGRectMake(0, self.webView.scrollView.contentSize.height-addViewHeight, kScreenWidth, addViewHeight);
            }];
        }
    });
}

//加载HTTPS 的链接，需要权限认证时调用\如果 HTTPS 是用证书在信任列表中这不要此代理方法
- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler {
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        if ([challenge previousFailureCount] == 0) {
            NSURLCredential* credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
            completionHandler(NSURLSessionAuthChallengeUseCredential,credential);
        }else{
            completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge,nil);
        }
    }else{
        completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge,nil);
    }
}


#pragma mark - WKUIDelegate
//提示框
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"提示框" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }]];
    [self presentViewController:alert animated:YES completion:NULL];
}

//确认框
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"确认框" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }]];
    [self presentViewController:alert animated:YES completion:NULL];
}

//输入框
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"输入框" message:prompt preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.textColor = [UIColor blackColor];
        textField.placeholder = defaultText;
    }];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler([[alert.textFields lastObject] text]);
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(nil);
    }]];
    [self presentViewController:alert animated:YES completion:NULL];
    
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.webView evaluateJavaScript:@"parseFloat(document.getElementById(\"AppAppendDIV\").style.width);" completionHandler:^(id value, NSError * _Nullable error) {
        NSLog(@"scrollViewDidScroll ======= %@", value);
    }];
}



- (OCJSHelper *)ocjsHelper {
    if (!_ocjsHelper) {
        _ocjsHelper = [[OCJSHelper alloc]initWithDelegate:(id)self vc:self];
    }
    return _ocjsHelper;
}

- (UIView *)addView {
    if (!_addView) {
        _addView = [[UIView alloc] init];
        _addView.backgroundColor = [UIColor redColor];
    }
    return _addView;
}

@end
