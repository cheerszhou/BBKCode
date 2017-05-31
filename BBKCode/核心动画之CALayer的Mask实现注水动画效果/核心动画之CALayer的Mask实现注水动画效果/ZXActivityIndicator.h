//
//  ZXActivityIndicator.h
//  核心动画之CALayer的Mask实现注水动画效果
//
//  Created by zxx_mbp on 2017/5/27.
//  Copyright © 2017年 zxx_mbp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZXActivityIndicator : UIView
@property (nonatomic, assign) BOOL hidesWhenStopped;

- (void)startAnimation;
- (void)stopAnimation;
@end
