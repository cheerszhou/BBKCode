//
//  UIViewController+Message.h
//  QRDemo
//
//  Created by zxx_mbp on 2017/5/22.
//  Copyright © 2017年 zxx_mbp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Message)
- (void)showAlertWithTitle:(NSString*)title message:(NSString*)message handler:(void(^)(UIAlertAction*action))handler;
@end
