//
//  UIViewController+Message.m
//  QRDemo
//
//  Created by zxx_mbp on 2017/5/22.
//  Copyright © 2017年 zxx_mbp. All rights reserved.
//

#import "UIViewController+Message.h"

@implementation UIViewController (Message)

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message handler:(void (^)(UIAlertAction *))handler {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:handler];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
