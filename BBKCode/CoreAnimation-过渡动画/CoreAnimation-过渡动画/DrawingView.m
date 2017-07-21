//
//  DrawingView.m
//  CoreAnimation-过渡动画
//
//  Created by zxx_mbp on 2017/7/19.
//  Copyright © 2017年 zxx_mbp. All rights reserved.
//

#import "DrawingView.h"

@interface DrawingView ()
@property (nonatomic, strong) UIBezierPath *bezierPath;
@end

@implementation DrawingView

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setup];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.bezierPath = [UIBezierPath bezierPath];
    self.bezierPath.lineWidth = 2;
    self.bezierPath.lineCapStyle = kCGLineCapRound;
    self.bezierPath.lineJoinStyle = kCGLineJoinRound;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint start = [[touches anyObject] locationInView:self];
    [self.bezierPath moveToPoint:start];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint move = [[touches anyObject] locationInView:self];
    [self.bezierPath addLineToPoint:move];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    [[UIColor blackColor] setStroke];
    [self.bezierPath stroke];
}

@end
