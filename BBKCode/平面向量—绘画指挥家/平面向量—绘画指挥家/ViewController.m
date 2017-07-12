//
//  ViewController.m
//  平面向量—绘画指挥家
//
//  Created by zxx_mbp on 2017/7/11.
//  Copyright © 2017年 zxx_mbp. All rights reserved.
//

#import "ViewController.h"
#import "ZXVector2D.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self drawRegularPolygonAtCenter:self.view.center edgeCount:7 edgeLength:100];
}

- (void)drawRegularPolygonAtCenter:(CGPoint)center edgeCount:(int)edgeCount edgeLength:(CGFloat)length {
    //相邻两个顶点和中心点连接后形成的角度
    CGFloat innerAngle = M_PI*2/edgeCount;
    //计算左下角那个顶点的坐标（我这里并没有使用余弦定理，cot是余切
    CGFloat x1 = -length/2;
    CGFloat cot = cos(innerAngle/2)/sin(innerAngle/2);
    CGFloat y1 = length/2*cot;
    //构造初始向量
    ZXVector2D * vector = [[ZXVector2D alloc] initWithCoordinateExpression:CGPointMake(x1, y1)];
    [vector translationToPoint:center];
    NSMutableArray * vertexes = [NSMutableArray arrayWithCapacity:0];
    for (int i = 0; i < edgeCount; ++i) {
        NSValue* vertex = [NSValue valueWithCGPoint:vector.endPoint];
        [vertexes addObject:vertex];
        //旋转向量
        [vector rotateClockwiselyWithRadian:innerAngle];
    }
    
    //绘制
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [vertexes enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGPoint vertex = [obj CGPointValue];
        if (idx == 0) {
            
            [bezierPath moveToPoint:vertex];
        }else {
            [bezierPath addLineToPoint:vertex];
        }
    }];
    
    [bezierPath closePath];
    
    CAShapeLayer * shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = bezierPath.CGPath;
    shapeLayer.strokeColor = [UIColor blackColor].CGColor;
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
    [self.view.layer addSublayer:shapeLayer];
}


@end
