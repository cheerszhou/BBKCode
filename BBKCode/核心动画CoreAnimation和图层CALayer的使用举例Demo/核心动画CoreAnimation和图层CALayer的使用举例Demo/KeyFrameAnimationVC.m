//
//  KeyFrameAnimationVC.m
//  核心动画CoreAnimation和图层CALayer的使用举例Demo
//
//  Created by zxx_mbp on 2017/6/1.
//  Copyright © 2017年 zxx_mbp. All rights reserved.
//

#import "KeyFrameAnimationVC.h"

@interface KeyFrameAnimationVC ()
@property (nonatomic, strong) CALayer *layer;
@end

@implementation KeyFrameAnimationVC

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
    [self translationAnimation_values];
    //[self translationAnimation_path];
}


- (void)translationAnimation_path {
    
    //1.创建关键帧动画并设置动画属性
    CAKeyframeAnimation* keyFrameAnimation =[CAKeyframeAnimation animationWithKeyPath:@"position"];
    
    //2.设置路径
    //贝塞尔曲线
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, self.layer.position.x, self.layer.position.y);
    CGPathAddCurveToPoint(path, NULL, 160, 280, -30, 300, 55, 400);//绘制二次贝塞尔曲线
    keyFrameAnimation.path = path;
    CGPathRelease(path);
    
    
    keyFrameAnimation.duration = 5.0;
    keyFrameAnimation.beginTime = CACurrentMediaTime() + 2;//设置延迟2秒执行
    
    
    //3.添加动画到图层，添加动画后就会行动画
    [self.layer addAnimation:keyFrameAnimation forKey:@"myAnimation"];
    
}

- (void)translationAnimation_values {
    //1.创建关键帧动画并设置动画属性
    CAKeyframeAnimation* keyFrameAnimation =[CAKeyframeAnimation animationWithKeyPath:@"position"];
    
    //2.设置关键帧，这里有四个关键帧
    NSValue* key1 = [NSValue valueWithCGPoint:self.layer.position];//对于关键帧动画初始值不能省略
    NSValue* key2 = [NSValue valueWithCGPoint:CGPointMake(80, 220)];
    NSValue* key3 = [NSValue valueWithCGPoint:CGPointMake(45, 320)];
    NSValue* key4 = [NSValue valueWithCGPoint:CGPointMake(75, 420)];
    //设置其他属性
    keyFrameAnimation.values = @[key1,key2,key3,key4];
    keyFrameAnimation.duration = 7;
    //keyFrameAnimation.beginTime = CACurrentMediaTime() + 2;//设置延迟2秒执行
    keyFrameAnimation.keyTimes = @[@(2/7.0),@(5.5/7),@(6.25/7),@1.0];
    
    
    //3.添加动画到图层，添加动画后就会行动画
    [self.layer addAnimation:keyFrameAnimation forKey:@"myAnimation"];
    
    
    
}


@end
