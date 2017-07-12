//
//  ZXVector2D.m
//  平面向量—绘画指挥家
//
//  Created by zxx_mbp on 2017/7/11.
//  Copyright © 2017年 zxx_mbp. All rights reserved.
//

#import "ZXVector2D.h"

@implementation ZXVector2D

- (instancetype)initWithStartPoint:(CGPoint)start endPoint:(CGPoint)end {
    self = [super init];
    _startPoint = start;
    _endPoint = end;
    return self;
}

- (instancetype)initWithCoordinateExpression:(CGPoint)position {
    self = [self initWithStartPoint:CGPointZero endPoint:position];
    return self;
}

+ (instancetype)vectorWithVector:(ZXVector2D *)vector {
    ZXVector2D* aVector = [[ZXVector2D alloc]initWithStartPoint:vector.startPoint endPoint:vector.endPoint];
    return aVector;
}

- (NSString*)description {
    return [NSString stringWithFormat:@"start:%@, end:%@, coordinate:%@",NSStringFromCGPoint(self.startPoint),NSStringFromCGPoint(self.endPoint),NSStringFromCGPoint([self coordinateExpression])];
}

@end

@implementation ZXVector2D (SpecialVectors)

#define IDENTITY_LENGTH 1

#pragma mark - 特殊向量

+ (ZXVector2D *)xPositiveIdentityVector {
    ZXVector2D* vector = [[ZXVector2D alloc]initWithCoordinateExpression:CGPointMake(IDENTITY_LENGTH, 0)];
    return vector;
}

+ (ZXVector2D *)xNegativeIdentityVector {
    ZXVector2D * vector = [[ZXVector2D alloc]initWithCoordinateExpression:CGPointMake(-IDENTITY_LENGTH, 0)];
    return vector;
}

+ (ZXVector2D *)yPositiveIdentityVector {
    ZXVector2D * vector = [[ZXVector2D alloc]initWithCoordinateExpression:CGPointMake(0, IDENTITY_LENGTH)];
    return vector;
}

+ (ZXVector2D *)yNegativeIdentityVector {
    ZXVector2D * vector = [[ZXVector2D alloc]initWithCoordinateExpression:CGPointMake(0, -IDENTITY_LENGTH)];
    return vector;
}

+ (ZXVector2D *)zeroVector {
    return [[ZXVector2D alloc]initWithCoordinateExpression:CGPointZero];
}

@end

@implementation ZXVector2D (VectorDescriptions)

- (CGFloat)length {
    return sqrt(pow(_startPoint.y - _endPoint.y, 2) + pow(_startPoint.x - _endPoint.x, 2));
}

- (void)setLength:(CGFloat)length {
    [self multipliedByNumber:length/self.length];
}

- (CGFloat)angleOfOtherVector:(ZXVector2D *)oVector {
    //通过向量点积的几何意义反解向量夹角
    CGFloat cos = [self dotProductedByOtherVector:oVector]/([self length]*[oVector length]);
    return acos(cos);
}

- (CGFloat)angleOfXAxisPositiveVector {
    return [self angleOfOtherVector:[ZXVector2D xPositiveIdentityVector]];
}

- (CGPoint)coordinateExpression {
    return CGPointMake(self.endPoint.x - self.startPoint.x, self.endPoint.y - self.startPoint.y);
}

- (BOOL)isEqualToVector:(ZXVector2D *)aVector {
    CGPoint selfExpression = [self coordinateExpression];
    CGPoint expression = [aVector coordinateExpression];
    return CGPointEqualToPoint(selfExpression, expression);
}

#pragma mark - 到角
//顺时针到角 = 另一个向量到该向量的逆时针到角
- (CGFloat)clockwiseAngleToVector:(ZXVector2D *)vector {
    return [vector antiClockwiseAngleToVector:self];
}

//如果另一个向量在这个向量的逆时针方向上（夹角小于pi），则到角 = 夹角
//若不是，则到角 = 2π - 夹角
- (CGFloat)antiClockwiseAngleToVector:(ZXVector2D *)vector {
    //判断是否在逆时针方向上
    //首先如果它们的夹角是π,则直接返回
    if ([self angleOfOtherVector:vector] == M_PI) {
        return M_PI;
    }
    
    //然后,将该向量沿逆时针方向旋转一度，如果它们的夹角减小，则是在逆时针方向
    CGFloat angle = [self angleOfOtherVector:vector];
    ZXVector2D * tempVector = [ZXVector2D vectorWithVector:self];
    [tempVector rotateAntiClockwiselyWithRadian:1/180.0*M_PI];
    if ([tempVector angleOfOtherVector:vector] < angle) {
        return angle;
    }
    return (2*M_PI) - angle;
}
@end

@implementation ZXVector2D (VectorArithmetic)

- (void)plusByOtherVector:(ZXVector2D *)vector {
    CGPoint tp = _startPoint;
    [self translationToPoint:CGPointZero];
    CGPoint p = [vector coordinateExpression];
    _endPoint = CGPointMake(_endPoint.x + p.x, _endPoint.y + p.y);
    [self translationToPoint:tp];
}

+ (ZXVector2D *)aVector:(ZXVector2D *)aVector plusByOtherVector:(ZXVector2D *)oVector {
    CGPoint p1 = [aVector coordinateExpression];
    CGPoint p2 = [oVector coordinateExpression];
    
    ZXVector2D* vector = [[ZXVector2D alloc]initWithStartPoint:CGPointZero endPoint:CGPointMake(p1.x + p2.x, p1.y + p2.y)];
    return vector;
}

- (void)substractedByOtherOtherVector:(ZXVector2D *)vector {
    CGPoint pt = _startPoint;
    [self translationToPoint:CGPointZero];
    CGPoint p = [vector coordinateExpression];
    _endPoint = CGPointMake(_endPoint.x - p.x, _endPoint.y - p.y);
    [self translationToPoint:pt];
}

- (void)multipliedByNumber:(CGFloat)number {
    CGPoint startPoint = self.startPoint;
    [self translationToPoint:CGPointZero];
    self.endPoint = CGPointMake(_endPoint.x*number, _endPoint.y*number);
    [self translationToPoint:startPoint];
}

-  (ZXVector2D *)aVector:(ZXVector2D *)aVector multipliedByNumber:(CGFloat)number {
    CGPoint tp = aVector.startPoint;
    [aVector translationToPoint:CGPointZero];
    CGPoint p = CGPointMake(aVector.endPoint.x*number, aVector.endPoint.y*number);
    ZXVector2D* vector = [[ZXVector2D alloc]initWithCoordinateExpression:p];
    [aVector translationToPoint:tp];
    return vector;
}

- (CGFloat)dotProductedByOtherVector:(ZXVector2D *)vector {
    return [ZXVector2D aVector:self dotProductedByOtherVector:vector];
}

+ (CGFloat)aVector:(ZXVector2D*)aVector dotProductedByOtherVector:(ZXVector2D*)oVector {
    CGPoint p = [aVector coordinateExpression];
    CGPoint op = [oVector coordinateExpression];
    return p.x*op.x+p.y*op.y;
}
@end
typedef NS_ENUM(NSInteger,ZXVectorCoordinateSystem) {
    ZXVectorCoordinateSystemOpenGL,
};
@implementation ZXVector2D (VectorTransforming)

- (void)translationToPoint:(CGPoint)point {
    _endPoint = CGPointMake(_endPoint.x + point.x - _startPoint.x, _endPoint.y + point.y - _startPoint.y);
    _startPoint = point;
}

- (void)rotateWithCoordinateSystem:(ZXVectorCoordinateSystem)coordinateSystem radian:(CGFloat)radian clockWisely:(BOOL)flag {
    if (coordinateSystem == ZXVectorCoordinateSystemOpenGL) {
        [self rotateInOpenGLSystemWithRadian:radian clockwisely:flag];
    }else {
        [self rotateInOpenGLSystemWithRadian:radian clockwisely:!flag];
    }
}

- (void)rotateInOpenGLSystemWithRadian:(CGFloat)radian clockwisely:(BOOL)flag {
    if (flag) {
        //首先将向量平移至原点
        CGPoint point = _startPoint;
        [self translationToPoint:CGPointZero];
        //计算沿着原点旋转后的endPoint
        CGFloat x1 = _endPoint.x * cos(radian) + _endPoint.y * sin(radian);
        CGFloat y1 = -_endPoint.x * sin(radian) + _endPoint.y * cos(radian);
        _endPoint = CGPointMake(x1, y1);
        //将startPoint移回原处
        [self translationToPoint:point];
    }else {
        //首先将向量平移至原点
        CGPoint point = _startPoint;
        [self translationToPoint:CGPointMake(0, 0)];
        //计算沿着原点旋转后的endpoint
        CGFloat x1 = _endPoint.x * cos(radian) - _endPoint.y*sin(radian);
        CGFloat y1 = _endPoint.x * sin(radian) + _endPoint.y*cos(radian);
        _endPoint = CGPointMake(x1, y1);
        //将startpoint移回原处
        [self translationToPoint:point];
    }
}

- (void)rotateClockwiselyWithRadian:(CGFloat)radian {
    [self rotateWithCoordinateSystem:ZXVectorCoordinateSystemOpenGL radian:radian clockWisely:YES];
}

- (void)rotateAntiClockwiselyWithRadian:(CGFloat)radian {
    [self rotateWithCoordinateSystem:ZXVectorCoordinateSystemOpenGL radian:radian clockWisely:NO];
}

- (void)reverse {
    CGPoint startPoint = self.startPoint;
    self.startPoint = self.endPoint;
    self.endPoint = startPoint;
}
@end
