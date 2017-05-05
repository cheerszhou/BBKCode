//
//  UIWebView+ZXX_JavaScriptContext.m
//  SpotJavaScriptContext
//
//  Created by zxx_mbp on 2017/5/5.
//  Copyright © 2017年 zxx_mbp. All rights reserved.
//

#import "UIWebView+ZXX_JavaScriptContext.h"
#import <objc/runtime.h>

static NSHashTable* g_webViews = nil;
static const char kTSJavaScriptContext[] = "zxx_javaScriptContext";


@interface UIWebView (ZXX_JavaScriptCore_private)
- (void) zxx_didCreateJavaScriptContext:(JSContext*)zxx_javaScriptContext;

@end

@protocol ZXXWebFrame <NSObject>
- (id)parentFrame;

@end

@implementation NSObject (ZXX_JavaScriptContext)

- (void)webView:(id)unused didCreateJavaScriptContext:(JSContext*)ctx forFrame:(id<ZXXWebFrame>)frame {
    NSParameterAssert([frame respondsToSelector:@selector(parentFrame)]);
    // only interested in root-level frames
    if ([frame respondsToSelector:@selector(parentFrame)]&&[frame parentFrame] != nil) return;
    
    void (^notifyDidCreateeJavaScriptContext)() = ^{
        for (UIWebView* webView in g_webViews) {
            NSString* cookie = [NSString stringWithFormat:@"zxx_jscWebView_%lud",webView.hash];
            [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"var %@ = '%@'",cookie,cookie]];
            if ([ctx[cookie].toString isEqualToString:cookie]) {
                [webView zxx_didCreateJavaScriptContext:ctx];
                return ;
            }
        }
    };
    if ([NSThread isMainThread]) {
        notifyDidCreateeJavaScriptContext();
    }else{
        dispatch_async(dispatch_get_main_queue(), notifyDidCreateeJavaScriptContext);

    }
}

@end

@implementation UIWebView (ZXX_JavaScriptContext)

+ (id)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_webViews = [NSHashTable weakObjectsHashTable];
    });
    
    NSAssert([NSThread isMainThread], @"Not in the main thread");
    id webView = [super allocWithZone:zone];
    [g_webViews addObject:webView];
    return webView;
}

- (void)zxx_didCreateJavaScriptContext:(JSContext *)zxx_javaScriptContext {
    [self willChangeValueForKey:@"zxx_javaScriptContext"];
    objc_setAssociatedObject(self, kTSJavaScriptContext, zxx_javaScriptContext, OBJC_ASSOCIATION_RETAIN);
    [self didChangeValueForKey:@"zxx_javaScriptContext"];
    if ([self.delegate respondsToSelector:@selector(webView:didCreateJavaScriptContext:)]) {
        id<ZXXWebViewDelegate>delegate = (id<ZXXWebViewDelegate>)self.delegate;
        [delegate webView:self didCreateJavaScriptContext:zxx_javaScriptContext];
    }
}

- (JSContext*)zxx_javaScriptContext {
    JSContext* javaScriptContext = objc_getAssociatedObject(self, kTSJavaScriptContext);
    return javaScriptContext;
}

@end
