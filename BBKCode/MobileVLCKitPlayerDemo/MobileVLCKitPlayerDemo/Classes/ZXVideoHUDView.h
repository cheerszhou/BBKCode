//
//  ZXVideoHUDView.h
//  MobileVLCKitPlayerDemo
//
//  Created by zxx_mbp on 2017/5/9.
//  Copyright © 2017年 zxx_mbp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZXVideoHUDView : UIView

@end

@interface ZXVideoAlertView : UIView
@property (nonatomic, strong) UILabel *msgLabel;

+ (instancetype)sharedInstance;

- (void)show;
@end

