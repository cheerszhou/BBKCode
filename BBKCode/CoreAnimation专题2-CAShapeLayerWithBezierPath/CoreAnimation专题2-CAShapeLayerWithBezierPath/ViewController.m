//
//  ViewController.m
//  CoreAnimation专题2-CAShapeLayerWithBezierPath
//
//  Created by zxx_mbp on 2017/7/5.
//  Copyright © 2017年 zxx_mbp. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (nonatomic, strong) CAShapeLayer *layer;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CAShapeLayer* layer = [CAShapeLayer layer];
    layer.strokeColor = [UIColor redColor].CGColor;
    layer.lineWidth = 3.0;
    layer.fillColor = [UIColor clearColor].CGColor;
    self.layer = layer;
    [self.view.layer  addSublayer:layer];
}

- (IBAction)drawRect:(id)sender {
    UIBezierPath* path = [UIBezierPath bezierPathWithRect:CGRectMake(3, 3, 80, 80)];
    self.layer.path = path.CGPath;
}

- (IBAction)drawLine:(id)sender {
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint:CGPointMake(10, 10)];
    [bezierPath addLineToPoint:CGPointMake(100, 10)];
    [bezierPath addLineToPoint:CGPointMake(100, 100)];
    self.layer.path = bezierPath.CGPath;
}

- (IBAction)drawCircleAndLine:(id)sender {
    UIBezierPath* circlePath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(30, 30, 200, 200)];
    [circlePath moveToPoint:CGPointMake(30, 130)];
    [circlePath addLineToPoint:CGPointMake(230, 130)];
    self.layer.path = [self conjuctionPath].CGPath;

}

- (UIBezierPath*)conjuctionPath {
    UIBezierPath* circlePath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(30, 30, 200, 200)];
    UIBezierPath* subLinePath = [UIBezierPath bezierPath];
    [subLinePath moveToPoint:CGPointMake(30, 130)];
    [subLinePath addLineToPoint:CGPointMake(230, 130)];
//    [circlePath appendPath:subLinePath];
    [subLinePath appendPath:circlePath];
    return subLinePath;
}

- (IBAction)drawArc:(id)sender {
    
    UIBezierPath* path = [UIBezierPath bezierPath];
//    [path moveToPoint:CGPointMake(50, 350)];
    [path addArcWithCenter:CGPointMake(200, 200) radius:100 startAngle:0 endAngle:M_PI clockwise:YES];
    [path addLineToPoint:CGPointMake(120, 20)];
    self.layer.path = path.CGPath;
}

- (IBAction)drawBezierArc:(id)sender {
    UIBezierPath* path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(250, 250)];
    [path addQuadCurveToPoint:CGPointMake(30, 30) controlPoint:CGPointMake(400, 50)];
    self.layer.path = [self thirdOrderBezierCurve].CGPath;
}

- (UIBezierPath*)thirdOrderBezierCurve {
    UIBezierPath* path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(40, 40)];
    [path addCurveToPoint:CGPointMake(350, 600) controlPoint1:CGPointMake(10, 220) controlPoint2:CGPointMake(380, 380)];
    return path;
}

- (IBAction)drawSin:(id)sender {
    UIBezierPath* path = [UIBezierPath bezierPath];
    CGFloat height = self.view.frame.size.height;
    CGFloat width  = self.view.frame.size.width;
    
    [path moveToPoint:CGPointMake(0, height/2)];
    for (int i = 1; i < width; i++) {
        CGFloat y = height/4 * sin(2*M_PI*i/100)+height/2;
        [path addLineToPoint:CGPointMake(i, height-y)];
        
    }
    self.layer.path = path.CGPath;
}

- (IBAction)strokeStartAnimation:(id)sender {
    UIBezierPath* path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(200, 200) radius:100 startAngle:M_PI_2 endAngle:0 clockwise:YES];
    self.layer.path = path.CGPath;
    
    //为strokeStart添加动画
    CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animation.duration = 3;
    animation.fromValue = @0;
    animation.toValue = @1;
    //添加一个延迟这样看的更明白些
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.layer addAnimation:animation forKey:@""];
        
    });
}

- (IBAction)shapeLayerPathAnimation:(id)sender {
    self.layer.fillColor = [UIColor orangeColor].CGColor;
    
    CGFloat screenWidth = self.view.frame.size.width;
    CGFloat screenHeight = self.view.frame.size.height;
    
    //构造fromPath
    UIBezierPath* fromPath = [UIBezierPath bezierPath];
    // 从左上角开始画
    [fromPath moveToPoint:CGPointZero];
    //向下拉一条直线
    [fromPath addLineToPoint:CGPointMake(0, 200)];
    //向右拉一条曲线，因为是向下弯的并且是从中间开始弯的，所以控制点x是宽度的一半，y比起始值和结束点的y要大
    [fromPath addQuadCurveToPoint:CGPointMake(screenWidth, 200) controlPoint:CGPointMake(screenWidth/2, screenHeight - 150)];
    //向上拉一条直线
    [fromPath addLineToPoint:CGPointMake(screenWidth, 0)];
    //封闭路径
    [fromPath closePath];
    
    self.layer.path = fromPath.CGPath;
    
    //构造toPath
    UIBezierPath* toPath = [UIBezierPath bezierPath];
    
    //同样从左上角开始
    [toPath moveToPoint:CGPointZero];
    //向下拉一条线，要拉到屏幕外
    [toPath addLineToPoint:CGPointMake(0, screenHeight + 50)];
    //向右拉一条曲线，同样因为弯的地方在中间并且是向上的，所以控制点的x是宽度的一半，y比起始点和结束点的y要小
    [toPath addQuadCurveToPoint:CGPointMake(screenWidth, screenHeight + 50) controlPoint:CGPointMake(screenWidth/2, screenHeight - 50)];
    //向上拉一条直线
    [toPath addLineToPoint:CGPointMake(screenWidth, 0)];
    //封闭路径
    [toPath closePath];
    
    //构造动画
    CABasicAnimation* animation = [CABasicAnimation animation];
    animation.keyPath = @"path";
    animation.duration = 5;
    
    //fromValue应该是一个CGPathRef（因为path属性就是一个CGPathRef),它是一个结构体指针，使用桥接吧结构体指针转成OC的对象类型
    animation.fromValue = (__bridge id)(fromPath.CGPath);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.layer.path = toPath.CGPath;
        [self.layer addAnimation:animation forKey:nil];
    });
    
}

@end
