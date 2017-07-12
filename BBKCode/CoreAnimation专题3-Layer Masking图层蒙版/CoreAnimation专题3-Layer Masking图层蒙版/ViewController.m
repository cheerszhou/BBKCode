//
//  ViewController.m
//  CoreAnimation专题3-Layer Masking图层蒙版
//
//  Created by zxx_mbp on 2017/7/8.
//  Copyright © 2017年 zxx_mbp. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self 使用背景透明内容不透明的png图片来创建蒙版];
//    [self shapeLayer_mask1];
//    [self shapeLayer_mask2];
    [self mask_animation];
}


- (void)使用背景透明内容不透明的png图片来创建蒙版 {
    CALayer* layer = [CALayer layer];
    layer.frame = CGRectMake(20, 80, 300, 400);
    layer.contents = (__bridge id _Nullable)([UIImage imageNamed:@"01"].CGImage);
    [self.view.layer addSublayer:layer];
    
    CALayer* maskLayer = [CALayer layer];
    maskLayer.frame = CGRectMake(20, 80, 300, 400);
    maskLayer.contents = (__bridge id _Nullable)([UIImage imageNamed:@"imgMask"].CGImage);
    layer.mask = maskLayer;
}

- (void)shapeLayer_mask1 {
    CALayer* layer = [CALayer layer];
    layer.frame = CGRectMake(80, 80, 300, 300);
    //直接设置layer的contents属性，它可以是一张图片
    layer.contents = (__bridge id _Nullable)([UIImage imageNamed:@"01"].CGImage);
    [self.view.layer addSublayer:layer];
    
    //创建shapeLayer
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint:CGPointMake(150, 0)];
    [bezierPath addLineToPoint:CGPointMake(40, 150)];
    [bezierPath addQuadCurveToPoint:CGPointMake(260, 150) controlPoint:CGPointMake(150, 300)];
    [bezierPath closePath];

    CAShapeLayer *maskShapeLayer = [CAShapeLayer layer];
    maskShapeLayer.path = bezierPath.CGPath;
    layer.mask = maskShapeLayer;
    
}

- (void)shapeLayer_mask2 {
    CALayer* layer = [CALayer layer];
    layer.frame = CGRectMake(80, 80, 300, 300);
    //直接设置layer的contents属性，它可以是一张图片
    layer.contents = (__bridge id _Nullable)([UIImage imageNamed:@"01"].CGImage);
    [self.view.layer addSublayer:layer];
    
    //创建shapeLayer
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint:CGPointMake(150, 10)];
    [bezierPath addLineToPoint:CGPointMake(40, 150)];
    [bezierPath addQuadCurveToPoint:CGPointMake(260, 150) controlPoint:CGPointMake(150, 300)];
    [bezierPath closePath];
    bezierPath.lineWidth = 20;
    bezierPath.lineJoinStyle = kCGLineCapRound;
    
    CAShapeLayer *maskShapeLayer = [CAShapeLayer layer];
    maskShapeLayer.path = bezierPath.CGPath;
    maskShapeLayer.strokeColor = [UIColor redColor].CGColor;
    maskShapeLayer.fillColor = (__bridge CGColorRef _Nullable)([UIColor clearColor]);
    maskShapeLayer.lineWidth = 10;
    maskShapeLayer.lineJoin = @"round";
    
    layer.mask = maskShapeLayer;
}


- (void)mask_animation {
    [self shapeLayer_mask2];
    CABasicAnimation* animation = [CABasicAnimation animation];
    animation.keyPath = @"strokeEnd";
    animation.duration = 3;
    animation.fromValue = @0;
    animation.repeatCount = MAXFLOAT;

    
    //由于maskLayer默认的strokend就是1，所以这里不需要重新设置modelLayer的属性
    [[self.view.layer.sublayers lastObject].mask addAnimation:animation forKey:nil];
}
@end
