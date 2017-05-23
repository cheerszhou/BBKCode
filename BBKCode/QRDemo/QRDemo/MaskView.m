//
//  MaskView.m
//  QRDemo
//
//  Created by zxx_mbp on 2017/5/22.
//  Copyright © 2017年 zxx_mbp. All rights reserved.
//

#import "MaskView.h"

@interface MaskView ()
@property (nonatomic, strong) CALayer *lineLayer;
@end

@implementation MaskView

- (void)drawRect:(CGRect)rect {
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    
    CGFloat pickingFieldWidth = 300;
    CGFloat pickingFieldHeight = 300;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGContextSetRGBFillColor(context, 0, 0, 0, 0.12);
    CGContextSetLineWidth(context, 3);
    
    CGRect pickingFieldRect = CGRectMake((width-pickingFieldWidth)/2, (height-pickingFieldHeight)/2, pickingFieldWidth, pickingFieldHeight);
    UIBezierPath *pickingFieldPath = [UIBezierPath bezierPathWithRect:pickingFieldRect];
    UIBezierPath *beizerPathRect = [UIBezierPath bezierPathWithRect:rect];
    [beizerPathRect appendPath:pickingFieldPath];
    //使用奇偶填充法则
    beizerPathRect.usesEvenOddFillRule = YES;
    [beizerPathRect fill];
    CGContextSetLineWidth(context, 2);
    CGContextSetRGBStrokeColor(context, 27/255.0, 181/255.0, 254/255.0, 1);
    
    [pickingFieldPath stroke];
    CGContextRestoreGState(context);
    self.layer.contentsGravity = kCAGravityCenter;
    
    
}


- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.5];
    self.lineLayer = [CALayer layer];
    self.lineLayer.contents = (id)[UIImage imageNamed:@"line"].CGImage;
    [self.layer addSublayer:self.lineLayer];
    [self resumeAnimation];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resumeAnimation) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopAnimation:) name:UIApplicationDidEnterBackgroundNotification object:nil];
}


- (void)layoutSubviews {
    [super layoutSubviews];
    [self setNeedsDisplay];
    self.lineLayer.frame = CGRectMake((self.frame.size.width - 300)/2, (self.frame.size.height - 300)/2, 300, 2);
}


- (void)stopAnimation {
    [self.lineLayer removeAnimationForKey:@"translationY"];
}

- (void)resumeAnimation {
    CABasicAnimation* basic = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    basic.fromValue = @(0);
    basic.toValue = @(300);
    basic.duration = 1.5;
    basic.repeatCount = NSIntegerMax;
    basic.autoreverses = @"";
    [self.lineLayer addAnimation:basic forKey:@"translationY"];
    
}
@end
