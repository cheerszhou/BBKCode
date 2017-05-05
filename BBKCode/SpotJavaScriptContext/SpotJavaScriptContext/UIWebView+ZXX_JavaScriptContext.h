//
//  UIWebView+ZXX_JavaScriptContext.h
//  SpotJavaScriptContext
//
//  Created by zxx_mbp on 2017/5/5.
//  Copyright © 2017年 zxx_mbp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JavaScriptCore/JavaScriptCore.h>

@protocol ZXXWebViewDelegate <UIWebViewDelegate>

@optional
- (void)webView:(UIWebView*)webView didCreateJavaScriptContext:(JSContext*)ctx;

@end

@interface UIWebView (ZXX_JavaScriptContext)
@property (nonatomic, readonly) JSContext *zxx_javaScriptContext;

@end
