//
//  OCJSHelper.m
//  WKWebViewDemo
//
//  Created by zxx_mbp on 2017/5/5.
//  Copyright © 2017年 zxx_mbp. All rights reserved.
//

#import "OCJSHelper.h"

@interface OCJSHelper ()
@property (nonatomic, weak) UIViewController *vc;
@end

@implementation OCJSHelper

- (instancetype)initWithDelegate:(id<OCJSHelperDelegate>)delegate vc:(UIViewController *)vc {
    if (self=[super init]) {
        self.delegate = delegate;
        self.vc = vc;
    }
    return self;
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    NSDictionary* dic = [NSDictionary dictionaryWithDictionary:message.body];
    NSLog(@"JS交互参数：%@",dic);
    
    if ([message.name isEqualToString:@"timefor"]&&[dic isKindOfClass:[NSDictionary class]]) {
        NSLog(@"currentThread ---- %@",[NSThread currentThread]);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString* code = dic[@"code"];
            if ([code isEqualToString:@"0001"]) {
                NSString* js = [NSString stringWithFormat:@"globalCallback('%@')",@"该设备的ID是：MYID****"];
                [self.webView evaluateJavaScript:js completionHandler:nil];
            }else{
                return ;
            }
        });

    }else{
        return;
    }
}

@end
