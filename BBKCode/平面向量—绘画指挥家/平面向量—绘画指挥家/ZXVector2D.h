//
//  ZXVector2D.h
//  平面向量—绘画指挥家
//
//  Created by zxx_mbp on 2017/7/11.
//  Copyright © 2017年 zxx_mbp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//确定了一个向量的起点和终点，那么和这个向量就一定能确定下来了
@interface ZXVector2D : NSObject

@property (nonatomic, assign) CGPoint startPoint;
@property (nonatomic, assign) CGPoint endPoint;


/**
 用两个点初始化一个向量

 @param start 起始点
 @param end 终点
 @return 生成的向量
 */
- (instancetype)initWithStartPoint:(CGPoint)start endPoint:(CGPoint)end;

/**
 指定一个角度生成一个单位向量

 @param radian 该向量在逆时针方向上到x轴正方向的角度·
 @return 生成的向量
 */
- (instancetype)initAsIdentityVectorWithAngleToXPositiveAxis:(CGPoint)radian;

/**
 用一个CGPoint作为坐标表达式初始化一个向量，起点默认在原点（0，0）

 @param position 向量坐标表达式
 @return 生成的向量
 */
- (instancetype)initWithCoordinateExpression:(CGPoint)position;

/**
 复制一个向量

 @param vector 要被复制的向量
 @return 生成的向量
 */
+ (instancetype)vectorWithVector:(ZXVector2D*)vector;

@end


//除了我们制定一些参数初始化的向量以外，我们还可以直接生成一些特殊的向量
@interface ZXVector2D (SpecialVectors)

/**
 x轴正方向的单位向量
 */
+ (ZXVector2D*)xPositiveIdentityVector;

/**
 x轴负方向的单位向量
 */
+ (ZXVector2D*)xNegativeIdentityVector;

/**
 y轴正方向的单位向量
 */
+ (ZXVector2D*)yPositiveIdentityVector;

/**
 y轴负方向的单位向量
 */
+ (ZXVector2D*)yNegativeIdentityVector;

/**
 零向量
 */
+ (ZXVector2D*)zeroVector;
@end

@interface ZXVector2D (VectorDescriptions)

/**
 向量长度

 */
- (CGFloat)length;

/**
 起点和方向不变，改变终点位置以让向量长度等于传入的长度

 @param length 要改变的长度
 */
- (void)setLength:(CGFloat)length;

/**
 向量间的夹角，是弧度值，<π

 @param oVector 与这个向量的夹角
 @return 夹角弧度值
 */
- (CGFloat)angleOfOtherVector:(ZXVector2D*)oVector;

/**
 与x轴正方向的夹角

 @return 夹角弧度
 */
- (CGFloat)angleOfXAxisPositiveVector;

/**
 向量的坐标形式，也就是将起点移到原点后终止点所在的位置

 @return 向量坐标表达式
 */
- (CGPoint)coordinateExpression;

/**
 判断两个向量是否相等

 @param aVector 要比较的向量
 */
- (BOOL)isEqualToVector:(ZXVector2D*)aVector;

/**
 该向量到某个向量的顺时针到角

 @param vector 要到的向量
 @return 到角弧度值
 */
- (CGFloat)clockwiseAngleToVector:(ZXVector2D*)vector;

/**
 该向量到某个向量的逆时针到角

 @param vector 要到的向量
 @return 到角的弧度值
 */
- (CGFloat)antiClockwiseAngleToVector:(ZXVector2D*)vector;
@end

@interface ZXVector2D (VectorArithmetic)

/**
 向量加法，自身被另一个向量加，方法将改变自身的结束点

 @param vector 要加的向量
 */
- (void)plusByOtherVector:(ZXVector2D*)vector;

/**
 向量加法，将两个向量相加然后返回，不影响自身的结束点

 @param aVector 要加的向量
 @param oVector 另一要加的向量
 @return 加起来后的结果
 */
+ (ZXVector2D*)aVector:(ZXVector2D*)aVector plusByOtherVector:(ZXVector2D*)oVector;

/**
 本向量被另个一个向量减：self - vector，将影响自身的结束点

 */
- (void)substractedByOtherOtherVector:(ZXVector2D*)vector;

/**
 用一个向量减去另一个向量，不影响自身的结束点

 @param aVector 被减向量
 @param oVector 减向量
 */
+ (ZXVector2D*)aVector:(ZXVector2D*)aVector substractedByOtherVector:(ZXVector2D*)oVector;

/**
 数乘，将会影响自身结束点

 @param number 成数
 */
- (void)multipliedByNumber:(CGFloat)number;

/**
 用一个向量乘以一个数，返回乘后的向量，不影响自身的结束点

 @param aVector 被乘的向量
 @param number 乘数
 @return 乘后的向量
 */
- (ZXVector2D*)aVector:(ZXVector2D*)aVector multipliedByNumber:(CGFloat)number;

/**
 向量数量积、点积，自身点乘另一个向量，不影响自身的结束点

 @param vector 要点乘的向量
 @return 点乘结果，是标量值
 */
- (CGFloat)dotProductedByOtherVector:(ZXVector2D*)vector;

/**
 用一个向量点乘另一个向量不影响自身的结束点

 @param aVector 一个向量
 @param oVector 点乘另个一个向量
 @return 点乘结果是变量值
 */
- (CGFloat)aVector:(ZXVector2D*)aVector dotProductedByOtherVector:(ZXVector2D*)oVector;

@end

@interface ZXVector2D (VectorTransforming)

/**
 将起始点平移至某个点，和原向量相等

 @param point 要平移到的点
 */
- (void)translationToPoint:(CGPoint)point;

/**
 顺时针旋转一个弧度

 @param radian 要旋转的弧度值
 */
- (void)rotateClockwiselyWithRadian:(CGFloat)radian;

/**
 逆时针旋转一个弧度

 @param radian 要旋转的弧度值
 */
- (void)rotateAntiClockwiselyWithRadian:(CGFloat)radian;

/**
 将向量反向
 */
- (void)reverse;
@end
