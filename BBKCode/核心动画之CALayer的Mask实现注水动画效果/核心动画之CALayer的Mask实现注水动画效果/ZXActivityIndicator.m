//
//  ZXActivityIndicator.m
//  核心动画之CALayer的Mask实现注水动画效果
//
//  Created by zxx_mbp on 2017/5/27.
//  Copyright © 2017年 zxx_mbp. All rights reserved.
//

#import "ZXActivityIndicator.h"

@interface ZXActivityIndicator ()
@property (nonatomic, strong) UIImageView *animationCircle;
@end

@implementation ZXActivityIndicator

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}


- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    UIImageView *logo = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"loading_logo"]];
    [self addSubview:logo];
    self.animationCircle = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loading_indicator"]];
    [self addSubview:self.animationCircle];
}

- (void)startAnimation {
    CAAnimation * existAnimation = [self.animationCircle.layer animationForKey:@"rotate"];
    if (existAnimation) {
        return;
    }
    self.hidden = NO;
    CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.fromValue = @0;
    animation.toValue = @(2*M_PI);
    animation.duration = 1.5f;
    animation.repeatCount = HUGE_VALF;
    [self.animationCircle.layer addAnimation:animation forKey:@"rotate"];
}

- (void)stopAnimation {
    if (self.hidesWhenStopped) {
        self.hidden = YES;
    }
    [self.animationCircle.layer removeAllAnimations];
}


- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    self.bounds = CGRectMake(0, 0, 30.f, 30.f);
}
@end
