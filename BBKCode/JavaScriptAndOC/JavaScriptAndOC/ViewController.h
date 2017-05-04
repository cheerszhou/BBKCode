//
//  ViewController.h
//  JavaScriptAndOC
//
//  Created by zxx_mbp on 2017/5/3.
//  Copyright © 2017年 zxx_mbp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JavaScriptCore/JavaScriptCore.h>

@protocol JavaScriptObjctiveCDelegate <JSExport>

// JS调用此方法来调用OC的系统相册方法
- (void)callSystemCamera;

/**
 在JS中调用时函数名应该为showAlertMsg(arg1,arg2)
 这里是只有两个参数
 */
- (void)showAlert:(NSString*)title msg:(NSString*)msg;
// 通过JSON传过来
- (void)callWithDict:(NSDictionary*)params;
//JS调用OC，然后在OC中通过调用JS方法来传给JS
- (void)jsCallObjcAndObjcCallJsWithDict:(NSDictionary*)params;
@end

// 此模型用于注入JS的模型，这样就可以通过模型来调用方法。

@interface HYBJsObjCModel : NSObject<JavaScriptObjctiveCDelegate>

@property (nonatomic, weak) JSContext *jsContext;
@property (nonatomic, weak) UIWebView *webView;

@end

@implementation HYBJsObjCModel

- (void)callWithDict:(NSDictionary *)params {
    NSLog(@"Js调用了OC的方法，参数为：%@",params);
}

- (void)callSystemCamera {
    NSLog(@"Js调用了OC的方法，调用系统相册");;
    //JS调用OC后，又通过OC调用JS，但是这个是没有参数传递的
    JSValue *jsFunc = self.jsContext[@"jsFunc"];
    [jsFunc callWithArguments:nil];
}

- (void)jsCallObjcAndObjcCallJsWithDict:(NSDictionary *)params {
    NSLog(@"jsCallObjcAndObjcCallJsWithDict was called, params is %@", params);
    
    // 调用JS的方法
    JSValue *jsParamFunc = self.jsContext[@"jsParamFunc"];
    [jsParamFunc callWithArguments:@[@{@"age": @10, @"name": @"lili", @"height": @158}]];
}

- (void)showAlert:(NSString *)title msg:(NSString *)msg {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil , nil];
        [alert show];
        
    });

}

@end

@interface ViewController : UIViewController


@end

