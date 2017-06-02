//
//  AnimationGroupVC.m
//  核心动画CoreAnimation和图层CALayer的使用举例Demo
//
//  Created by zxx_mbp on 2017/6/1.
//  Copyright © 2017年 zxx_mbp. All rights reserved.
//

#import "AnimationGroupVC.h"

@interface AnimationGroupVC ()<CAAnimationDelegate>
@property (nonatomic, strong) CALayer *layer;
@end

@implementation AnimationGroupVC

- (void)viewDidLoad {
    [super viewDidLoad];
    //设置背景（注意这个图片其实在根图层）
    UIImage* backgroundImage = [UIImage imageNamed:@"bg.jpg"];
    self.view.backgroundColor = [UIColor colorWithPatternImage:backgroundImage];
    
    //自定义一个图层
    self.layer = [[CALayer alloc]init];
    self.layer.bounds= CGRectMake(0, 0, 10, 20);
    self.layer.position = CGPointMake(50, 150);
    self.layer.contents = (id)[UIImage imageNamed:@"雪"].CGImage;
    [self.view.layer addSublayer:self.layer];
    
    //创建动画
    [self groupAnimation];
    
}

#pragma mark - 添加基础旋转动画
- (CABasicAnimation*)rotationAnimation {
    CABasicAnimation* basicAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    CGFloat toValue = M_PI_2*3;
    
    basicAnimation.toValue = [NSNumber numberWithFloat:toValue];
    basicAnimation.autoreverses = YES;
    basicAnimation.repeatCount = HUGE_VAL;
    basicAnimation.removedOnCompletion = NO;
    
    [basicAnimation setValue:[NSNumber numberWithFloat:toValue] forKey:@"ZXBaiscAnimationProperty_toValue"];
    return basicAnimation;
}
#pragma mark - 添加关键帧移动动画
- (CAKeyframeAnimation*)translationAnimation {
    CAKeyframeAnimation* keyframeAnim = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    CGPoint endPoint = CGPointMake(55, 400);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, self.layer.position.x, self.layer.position.y);
    CGPathAddCurveToPoint(path, NULL, 160, 280, -30, 300, endPoint.x, endPoint.y);
    keyframeAnim.path = path;
    CGPathRelease(path);
    [keyframeAnim setValue:[NSValue valueWithCGPoint:endPoint] forKey:@"ZXKeyFrameAnimationProperty_endPosition"];
    
    return keyframeAnim;
}
#pragma mark - 创建动画组
- (void)groupAnimation {
    //1.创建动画组
    CAAnimationGroup* animationGroup = [CAAnimationGroup animation];
    
    //2.设置组中的动画和其他属性
    CABasicAnimation* basicAnimation = [self rotationAnimation];
    CAKeyframeAnimation* keyFrameAnimation = [self translationAnimation];
    animationGroup.animations = @[basicAnimation,keyFrameAnimation];
    
    animationGroup.delegate = self;
    animationGroup.duration = 10.0;//设置动画时间，如果动画组中动画已经设置过动画属性则不再生效
    animationGroup.beginTime = CACurrentMediaTime() + 5;//延迟5秒执行
    
    //3.给图层添加动画
    [self.layer addAnimation:animationGroup forKey:nil];
}
#pragma mark - 代理方法
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    CAAnimationGroup* animationGroup = (CAAnimationGroup*)anim;
    CABasicAnimation* basicAnimation = (CABasicAnimation*)animationGroup.animations[0];
    CAKeyframeAnimation* keyFrameAnimation = (CAKeyframeAnimation*)animationGroup.animations[1];
    CGFloat toValue = [[basicAnimation valueForKey:@"ZXBaiscAnimationProperty_toValue"] floatValue];
    CGPoint endPoint = [[keyFrameAnimation valueForKey:@"ZXKeyFrameAnimationProperty_endPosition"] CGPointValue];
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    //设置动画的最终状态
    self.layer.position = endPoint;
    self.layer.transform = CATransform3DMakeRotation(toValue, 0, 0, 1);
    [CATransaction commit];
    
}


@end
