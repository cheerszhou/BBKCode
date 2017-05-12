//
//  UIViewController+Present.m
//  动态改变app icon(二)
//
//  Created by zxx_mbp on 2017/5/12.
//  Copyright © 2017年 zxx_mbp. All rights reserved.
//

#import "UIViewController+Present.h"
#import <objc/runtime.h>

@implementation UIViewController (Present)
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method presentM = class_getInstanceMethod([self class], @selector(presentViewController:animated:completion:));
        Method presentSwizzlingM = class_getInstanceMethod(self.class, @selector(zx_presentViewController:animated:completion:));
        
        method_exchangeImplementations(presentM, presentSwizzlingM);
    });
}

- (void)zx_presentViewController:(UIViewController*) viewControllerToPresent animated:(BOOL)flag completion:(void(^)(void))completion {
    if ([viewControllerToPresent isKindOfClass:[UIAlertController class]]) {
        NSLog(@"title : %@",viewControllerToPresent.title);
        NSLog(@"message:%@",((UIAlertController*)viewControllerToPresent).message);
        
        UIAlertController *alertController = (UIAlertController*)viewControllerToPresent;
        if (alertController.title==nil&&alertController.message==nil) {
            return;
        }else{
            [self zx_presentViewController:viewControllerToPresent animated:flag completion:completion];
            return;
        }
    }
    [self zx_presentViewController:viewControllerToPresent animated:flag completion:completion];
}
@end
