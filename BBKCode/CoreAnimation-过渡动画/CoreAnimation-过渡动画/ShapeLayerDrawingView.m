//
//  ShapeLayerDrawingView.m
//  CoreAnimation-过渡动画
//
//  Created by zxx_mbp on 2017/7/19.
//  Copyright © 2017年 zxx_mbp. All rights reserved.
//

#import "ShapeLayerDrawingView.h"

@interface ShapeLayerDrawingView ()
@property (nonatomic, strong) UIBezierPath *path;
@end

@implementation ShapeLayerDrawingView

+ (Class)layerClass {
    return [CAShapeLayer class];
}

- (void)awakeFromNib {

    [super awakeFromNib];
    self.path = [UIBezierPath bezierPath];
    
    CAShapeLayer *shapeLayer = (CAShapeLayer*)self.layer;
    shapeLayer.strokeColor = [UIColor redColor].CGColor;
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
    self.path.lineJoinStyle = kCGLineJoinRound;
    self.path.lineCapStyle = kCGLineCapRound;
    shapeLayer.lineWidth = 1.0;
    shapeLayer.contentsScale = [UIScreen mainScreen].scale;
    
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint move = [[touches anyObject] locationInView:self];
    [self.path addLineToPoint:move];
    ((CAShapeLayer*)self.layer).path = [self.path CGPath];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint start = [[touches anyObject] locationInView:self];
    [self.path moveToPoint:start];
}

@end
