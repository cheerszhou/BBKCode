//
//  OCJSHelper.h
//  WKWebViewDemo
//
//  Created by zxx_mbp on 2017/5/5.
//  Copyright © 2017年 zxx_mbp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>


@protocol OCJSHelperDelegate <NSObject>

@end

@interface OCJSHelper : NSObject<WKScriptMessageHandler>
@property (nonatomic, weak) WKWebView *webView;
@property (nonatomic, weak) id<OCJSHelperDelegate> delegate;


/**
 指定初始化方法

 @param delegate 代理
 @param vc 实现WebView的VC
 @return 返回自身实现
 */
- (instancetype)initWithDelegate:(id<OCJSHelperDelegate>)delegate vc:(UIViewController*)vc;
@end
