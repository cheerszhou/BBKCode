//
//  KeyFrameAnimationFromUIView.m
//  核心动画CoreAnimation和图层CALayer的使用举例Demo
//
//  Created by zxx_mbp on 2017/6/2.
//  Copyright © 2017年 zxx_mbp. All rights reserved.
//

#import "KeyFrameAnimationFromUIView.h"

@interface KeyFrameAnimationFromUIView (){
    UIImageView* _imageView;
}

@end

@implementation KeyFrameAnimationFromUIView

- (void)viewDidLoad {
    [super viewDidLoad];
    //设置背景
    UIImage* background = [UIImage imageNamed:@"bg.jpg"];
    self.view.backgroundColor = [UIColor colorWithPatternImage:background];
    
    //创建显示控件
    _imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"blackBall"]];
    _imageView.center = CGPointMake(50, 150);
    [self.view addSubview:_imageView];
}


-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    //关键帧动画，options
    
    [UIView animateKeyframesWithDuration:5.0 delay:0 options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
        //第二关键帧（准确的说第一个关键帧是开始位置）：从0秒开始持续50%的时间，也就是5*0.5 = 2.5秒
        [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:0.5 animations:^{
            _imageView.center = CGPointMake(80, 220);
        }];
        
        //第三帧，从0.5*5.0秒开始，持续时间：5.0*0.25 = 1.25秒
        [UIView addKeyframeWithRelativeStartTime:0.5 relativeDuration:0.25 animations:^{
            _imageView.center = CGPointMake(40, 300);
        }];
        
        //第四帧，从0.75*5.0秒开始，持续时间：5.0*0.25秒
        [UIView addKeyframeWithRelativeStartTime:0.75f relativeDuration:0.25 animations:^{
            _imageView.center = CGPointMake(67, 400);
        }];
    } completion:^(BOOL finished) {
        NSLog(@"animation ended");
    }];
    
    
    /*
     options 的补充
     UIViewKeyframeAnimationOptionCalculationModeLinear：连续运算模式。
     
     UIViewKeyframeAnimationOptionCalculationModeDiscrete ：离散运算模式。
     
     UIViewKeyframeAnimationOptionCalculationModePaced：均匀执行运算模式。
     
     UIViewKeyframeAnimationOptionCalculationModeCubic：平滑运算模式。
     
     UIViewKeyframeAnimationOptionCalculationModeCubicPaced：平滑均匀运算模式。
     */
}


@end
