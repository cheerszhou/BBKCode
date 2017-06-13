//
//  AnimationFromUIView.m
//  核心动画CoreAnimation和图层CALayer的使用举例Demo
//
//  Created by zxx_mbp on 2017/6/2.
//  Copyright © 2017年 zxx_mbp. All rights reserved.
//

#import "AnimationFromUIView.h"

@interface AnimationFromUIView (){
    UIImageView* _imageView;
    UIImageView* _ball;
}

@end

@implementation AnimationFromUIView

- (void)viewDidLoad {
    [super viewDidLoad];
    //设置背景
    UIImage* background = [UIImage imageNamed:@"bg.jpg"];
    self.view.backgroundColor = [UIColor colorWithPatternImage:background];
    
    //创建图像显示空间
    _imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"timg_0000.png"]];
    _imageView.center = CGPointMake(50, 150);
    [self.view addSubview:_imageView];
    
    _ball = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"blackBall.png"]];
    _ball.center = self.view.center;
    [self.view addSubview:_ball];
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch * touch = [touches anyObject];
    CGPoint location = [touch locationInView:self.view];
    [self startBasicAnimate:location];
    
    [self startSpringAnimate:location];
    
}


- (void)uiViewOpitons {
    /*
     补充--动画设置参数
     
     在动画方法中有一个option参数，UIViewAnimationOptions类型，它是一个枚举类型，动画参数分为三类，可以组合使用：
     
     1.常规动画属性设置（可以同时选择多个进行设置）
     
     UIViewAnimationOptionLayoutSubviews：动画过程中保证子视图跟随运动。
     
     UIViewAnimationOptionAllowUserInteraction：动画过程中允许用户交互。
     
     UIViewAnimationOptionBeginFromCurrentState：所有视图从当前状态开始运行。
     
     UIViewAnimationOptionRepeat：重复运行动画。
     
     UIViewAnimationOptionAutoreverse ：动画运行到结束点后仍然以动画方式回到初始点。
     
     UIViewAnimationOptionOverrideInheritedDuration：忽略嵌套动画时间设置。
     
     UIViewAnimationOptionOverrideInheritedCurve：忽略嵌套动画速度设置。
     
     UIViewAnimationOptionAllowAnimatedContent：动画过程中重绘视图（注意仅仅适用于转场动画）。
     
     UIViewAnimationOptionShowHideTransitionViews：视图切换时直接隐藏旧视图、显示新视图，而不是将旧视图从父视图移除（仅仅适用于转场动画）
     
     UIViewAnimationOptionOverrideInheritedOptions ：不继承父动画设置或动画类型。
     
     2.动画速度控制（可从其中选择一个设置）
     
     UIViewAnimationOptionCurveEaseInOut：动画先缓慢，然后逐渐加速。
     
     UIViewAnimationOptionCurveEaseIn ：动画逐渐变慢。
     
     UIViewAnimationOptionCurveEaseOut：动画逐渐加速。
     
     UIViewAnimationOptionCurveLinear ：动画匀速执行，默认值。
     
     3.转场类型（仅适用于转场动画设置，可以从中选择一个进行设置，基本动画、关键帧动画不需要设置）
     
     UIViewAnimationOptionTransitionNone：没有转场动画效果。
     
     UIViewAnimationOptionTransitionFlipFromLeft ：从左侧翻转效果。
     
     UIViewAnimationOptionTransitionFlipFromRight：从右侧翻转效果。
     
     UIViewAnimationOptionTransitionCurlUp：向后翻页的动画过渡效果。
     
     UIViewAnimationOptionTransitionCurlDown ：向前翻页的动画过渡效果。
     
     UIViewAnimationOptionTransitionCrossDissolve：旧视图溶解消失显示下一个新视图的效果。
     
     UIViewAnimationOptionTransitionFlipFromTop ：从上方翻转效果。
     
     UIViewAnimationOptionTransitionFlipFromBottom：从底部翻转效果。
     */
}


- (void)startSpringAnimate:(CGPoint)location {
    //创建阻尼动画
    //damping:阻尼,范围0-1，阻尼越接近于0，弹性效果越明显
    //velocity:弹性复位的速度
    [UIView animateWithDuration:1.2 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:1.0 options:UIViewAnimationOptionCurveLinear animations:^{
        _ball.center = location;
    } completion:nil];
    
}


- (void)startBasicAnimate:(CGPoint)location {
    //方法1；block方法
    /*
     开始动画，UIView的动画方法执行完后动画会停留在重点位置，而不需要进行任何特殊处理
     duration：执行时间
     delay：延迟时间
     option:动画设置，列如自动恢复，匀速运动等
     completion:动画完成回调方法
     */
    
    //    [UIView animateWithDuration:1.5 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
    //        _imageView.center = location;
    //    } completion:^(BOOL finished) {
    //        NSLog(@"animate is end");
    //    }];
    
    //方法2:静态方法
    //开始动画
    [UIView beginAnimations:@"ZXBasicAnimation" context:nil];
    [UIView setAnimationDuration:1.5];
    //[UIView setAnimationDelay:1.0];//设置延迟
    //[UIView setAnimationRepeatAutoreverses:NO];//是否回复
    //[UIView setAnimationRepeatCount:10];//重复次数
    //[UIView setAnimationStartDate:(NSDate *)];//设置动画开始运行的时间
    //[UIView setAnimationDelegate:self];//设置代理
    //[UIView setAnimationWillStartSelector:(SEL)];//设置动画开始运动的执行方法
    //[UIView setAnimationDidStopSelector:(SEL)];//设置动画运行结束后的执行方法
    
    _imageView.center = location;
    
    //开始动画
    [UIView commitAnimations];
    
}
@end
