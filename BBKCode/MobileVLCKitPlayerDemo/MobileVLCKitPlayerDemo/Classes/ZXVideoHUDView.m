//
//  ZXVideoHUDView.m
//  MobileVLCKitPlayerDemo
//
//  Created by zxx_mbp on 2017/5/9.
//  Copyright © 2017年 zxx_mbp. All rights reserved.
//

#import "ZXVideoHUDView.h"
#import "ZXVideoConst.h"

@interface ZXVideoHUDView ()
@property (nonatomic, strong) CAShapeLayer *leftLayer;
@property (nonatomic, strong) CAShapeLayer *rightLayer;
@end

@implementation ZXVideoHUDView
- (instancetype)init {
    if (self=[super init]) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    [self setupAnimation];
}

- (void)setupAnimation {
    self.leftLayer = [CAShapeLayer layer];
    self.leftLayer.bounds = CGRectMake(0, 0, [self getCycleLayerSize].width, [self getCycleLayerSize].height);
    self.leftLayer.position  = kHUDCenter;
    self.leftLayer.strokeColor = [UIColor whiteColor].CGColor;
    self.leftLayer.fillColor = [UIColor clearColor].CGColor;
    self.leftLayer.lineWidth = KHUDCycleLineWidth;
    self.leftLayer.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, [self getCycleLayerSize].width, [self getCycleLayerSize].height)].CGPath;
    self.leftLayer.strokeEnd = 0.25;
    
    
    self.rightLayer = [CAShapeLayer layer];
    self.rightLayer.bounds = CGRectMake(0, 0, [self getCycleLayerSize].width, [self getCycleLayerSize].height);
    self.rightLayer.position = kHUDCenter;
    self.rightLayer.fillColor = [UIColor clearColor].CGColor;
    self.rightLayer.strokeColor = [UIColor whiteColor].CGColor;
    self.rightLayer.lineWidth = KHUDCycleLineWidth;
    self.rightLayer.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, [self getCycleLayerSize].width, [self getCycleLayerSize].height)].CGPath;
    self.rightLayer.strokeStart = 0.5;
    self.rightLayer.strokeEnd = 0.75;
    
    
    CAGradientLayer *gLayer_l = [CAGradientLayer layer];
    gLayer_l.backgroundColor = [UIColor redColor].CGColor;
    gLayer_l.bounds = self.bounds;
    gLayer_l.position = kHUDCenter;
    gLayer_l.colors = @[(id)[UIColor cyanColor].CGColor,(id)[UIColor orangeColor].CGColor,(id)[UIColor yellowColor].CGColor,];
    
    CAGradientLayer *gLayer_r = [CAGradientLayer layer];
    gLayer_r.backgroundColor = [UIColor redColor].CGColor;
    gLayer_r.bounds = self.bounds;
    gLayer_r.position = kHUDCenter;
    gLayer_r.colors = @[(id)[UIColor yellowColor].CGColor,(id)[UIColor orangeColor].CGColor,(id)[UIColor cyanColor].CGColor,];
    
    gLayer_r.mask = self.rightLayer;
    gLayer_l.mask = self.leftLayer;
    
    CABasicAnimation * animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.duration = kHUDCycleTimeInterval;
    animation.repeatCount = HUGE_VAL;
    animation.fromValue = [NSNumber numberWithFloat:0.f];
    animation.toValue = [NSNumber numberWithFloat:M_PI*2];
    
    [self.leftLayer addAnimation:animation forKey:nil];
    [self.rightLayer addAnimation:animation forKey:nil];
    
    [self.layer addSublayer:gLayer_l];
    [self.layer addSublayer:gLayer_r];
    
}

- (CGSize)getCycleLayerSize {
    return CGSizeMake(CGRectGetWidth(self.bounds) - KHUDCycleLineWidth, CGRectGetHeight(self.bounds) - KHUDCycleLineWidth);
}

@end


@interface ZXVideoAlertView ()

@end
@implementation ZXVideoAlertView

+ (instancetype)sharedInstance {
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ZXVideoAlertView alloc]init];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        self.msgLabel = [UILabel new];
        self.msgLabel.frame = self.bounds;
        self.msgLabel.backgroundColor = [UIColor redColor];
        self.msgLabel.textColor = [UIColor whiteColor];
        self.msgLabel.textAlignment = NSTextAlignmentCenter;
        self.msgLabel.text = @"I'm a Alert";
        [self addSubview:self.msgLabel];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    self.backgroundColor = [UIColor redColor];
}

- (void)dismiss {
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.alpha = 0;
                     }];
}


- (void)show {
    self.alpha = 1;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(dismiss) object:nil];
    [self performSelector:@selector(dismiss) withObject:nil afterDelay:2.0f];
}
@end
