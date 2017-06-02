//
//  BaseAnimeVC.m
//  核心动画CoreAnimation和图层CALayer的使用举例Demo
//
//  Created by zxx_mbp on 2017/6/1.
//  Copyright © 2017年 zxx_mbp. All rights reserved.
//

#import "BaseAnimeVC.h"

@interface BaseAnimeVC ()<CAAnimationDelegate>
@property (nonatomic, strong) CALayer *layer;
@end

@implementation BaseAnimeVC

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
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch* touch = [touches anyObject];
    CGPoint position = [touch locationInView:self.view];
    CAAnimation *animation = [self.layer animationForKey:@"ZXBasicAnimation_rotation"];
    //创建并开始动画
    if (animation) {
        if (self.layer.speed == 0) {
            [self animationResume];
        }else{
            [self animationPause];
        }
    }else{
        
        [self translationAnimation:position];
        [self rotationAnimation];
    }
}

- (void)animationPause {
    //取得指定图层动画的媒体时间，后面参数用于指定子图层，这里不需要
    CFTimeInterval interval = [self.layer convertTime:CACurrentMediaTime() fromLayer:nil];
    //设置时间偏移量，保证暂停时停留在旋转的位置
    self.layer.timeOffset = interval;
    //速度设置为零，暂停动画
    self.layer.speed = 0;
}

- (void)animationResume {
    //获取暂停的时间
    CFTimeInterval beginTime = CACurrentMediaTime() - self.layer.timeOffset;
    //设置偏移量
    self.layer.timeOffset = 0;
    //设置开始时间
    self.layer.beginTime = beginTime;
    //设置动画速度，开始运动
    self.layer.speed = 1.0;
    
}


#pragma mark - 移动动画
- (void)translationAnimation:(CGPoint)location {
    //1.创建动画并指定动画属性
    CABasicAnimation *basicAnim = [CABasicAnimation animationWithKeyPath:@"position"];
    //2.设置动画属性初始值和结束值
    //basicAnim.fromValue = [NSValue valueWithCGPoint:self.layer.position];
    basicAnim.toValue = [NSValue valueWithCGPoint:location];
    basicAnim.duration = 1.0;
    basicAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    basicAnim.removedOnCompletion = NO;
    
    
    //设置代理
    basicAnim.delegate = self;
    //self.layer.position = location;
    //存储当前位置工动画结束后使用
    [basicAnim setValue:[NSValue valueWithCGPoint:location] forKey:@"ZXBasicAnimationEndValue"];
    //3.添加动画到图层，注意key相当于给动画进行命名，以后获得改动画时可以使用此名称获取
    [self.layer addAnimation:basicAnim forKey:@"ZXBasicAnimation_Translation"];
}

#pragma mark - 旋转动画
- (void)rotationAnimation {
    //创建动画并指定动画属性
    CABasicAnimation *basicAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.y"];
    
    //设置动画初始值和结束值
    basicAnimation.toValue = [NSNumber numberWithFloat:M_PI];
    
    //设置其动画属性
    basicAnimation.duration = 1.0;
    basicAnimation.autoreverses = true;
    basicAnimation.repeatCount = HUGE_VAL;
    basicAnimation.removedOnCompletion = NO;
    
    
    [self.layer addAnimation:basicAnimation forKey:@"ZXBasicAnimation_rotation"];
}

#pragma mark - CAAnimationDelegate 
//动画开始
- (void)animationDidStart:(CAAnimation *)anim {
    NSLog(@"animation(%@) start.\r_layer.frame=%@",anim,NSStringFromCGRect(_layer.frame));
    NSLog(@"%@",[_layer animationForKey:@"ZXBasicAnimation_Translation"]);//通过前面的设置的key获得动画
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    NSLog(@"animation(%@) stop.\r_layer.frame=%@",anim,NSStringFromCGRect(_layer.frame));
    //_layer.position=[[anim valueForKey:@"ZXBasicAnimationEndValue"] CGPointValue];
    //代码运行到此处会发现另一问题：<#动画运行完成后会重新从起始点运动到终点#>
    /*
     问题产生的原因是：
     对于非根图层，设置图层的可动画属性（在动画结束后重新设置了position，而position是可动画属性）会产生动画效果。
     解决这个问题有两种办法：
     关闭图层隐式动画、设置动画图层为根图层。显然这里不能采取后者，因为根图层当前已经作为动画的背景。
     */
    
    //要关闭隐式动画需要用到动画事务CATransaction，在事务内讲隐式动画关闭，列如上面的代码可以改为：
    //开启事务
    [CATransaction begin];
    //禁用隐式动画
    [CATransaction setDisableActions:YES];
    
    self.layer.position = [[anim valueForKey:@"ZXBasicAnimationEndValue"] CGPointValue];
    
    //提交事务
    [CATransaction commit];
    
    //暂停旋转动画
    [self animationPause];
}



@end
