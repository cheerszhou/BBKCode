//
//  LayerTransformViewController.m
//  核心动画CoreAnimation之CALayer
//
//  Created by zxx_mbp on 2017/7/1.
//  Copyright © 2017年 zxx_mbp. All rights reserved.
//

#import "LayerTransformViewController.h"

@interface LayerTransformViewController ()

@end

@implementation LayerTransformViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self 图层内容和内容模式_01];
}

#pragma mark - 仿射变换

- (void)仿射变换_07 {
    
    
    
    CALayer* layer = [CALayer layer];
    layer.frame = CGRectMake(60, 60, 200, 300);
    layer.backgroundColor = [UIColor redColor].CGColor;
    [self.view.layer addSublayer:layer];
    //设置层内容
    layer.contents = (__bridge id _Nullable)([UIImage imageNamed:@"logo"].CGImage);
    //X轴旋转45°
    //layer.transform = CATransform3DMakeRotation(45*(M_PI)/180.0, 1, 0, 0);
    //旋转45° 度数 x y z
    //layer.transform = CATransform3DMakeRotation(90*(M_PI)/180.0, 1, 0, 0);
    
    //CATransform3DMakeRotation(<#CGFloat angle#>, <#CGFloat x#>, <#CGFloat y#>, <#CGFloat z#>);3D旋转
    //CATransform3DTranslate(<#CATransform3D t#>, <#CGFloat tx#>, <#CGFloat ty#>, <#CGFloat tz#>);3D位移
    //CATransform3DMakeScale(<#CGFloat sx#>, <#CGFloat sy#>, <#CGFloat sz#>);3D缩放
    //CATransform3DMakeTranslation(<#CGFloat tx#>, <#CGFloat ty#>, <#CGFloat tz#>)
    
    //仿射变换
    layer.affineTransform = CGAffineTransformMakeRotation(45*(M_PI)/180);
}

#pragma mark - 剪切图片的一部分
- (void)剪切图片的一部分_06
{
    int width = 80;
    int height = 100;
    int sapce = 3;
    for(int i = 0; i < 9; i++)
    {
        UIView *view = [[UIView alloc] init];
        view.frame = CGRectMake(60 + (width + sapce) * (i%3), 80 + (height + sapce) * (i/3), width, height);
        view.backgroundColor = [UIColor redColor];
        //设置层的内容
        view.layer.contents = (__bridge id _Nullable)([UIImage imageNamed:@"logo"].CGImage);
        //设置图片剪切的范围  [0,1]  contentsRect 图层显示内容的大小和位置
        view.layer.contentsRect = CGRectMake(1.0/3.0 * (i%3), 1.0/3.0 * (i/3), 1.0/3.0, 1.0/3.0);
        [self.view addSubview:view];
        /*
         1：（0，0，1/3,1/3）
         2: (1/3,0，1/3,1/3)
         3: (2/3,0，1/3,1/3)
         */
    }
}

#pragma mark - 图层添加边框和圆角
- (void)图层添加边框和圆角_05
{
    CALayer *layer = [CALayer layer];
    layer.frame = CGRectMake(60, 60, 100, 100);
    layer.backgroundColor = [UIColor redColor].CGColor;
    [self.view.layer addSublayer:layer];
    //边框颜色
    layer.borderColor = [UIColor greenColor].CGColor;
    //边框宽度
    layer.borderWidth = 3;
    //圆角
    layer.cornerRadius = 10;
}

#pragma mark - 剪切超过父图层的部分
- (void)剪切超过父图层的部分_04
{
    CALayer *layer = [CALayer layer];
    layer.frame = CGRectMake(60, 60, 100, 100);
    layer.backgroundColor = [UIColor redColor].CGColor;
    [self.view.layer addSublayer:layer];
    CALayer *layer2 = [CALayer layer];
    layer2.frame = CGRectMake(30, 30, 100, 100);
    layer2.backgroundColor = [UIColor blueColor].CGColor;
    [layer addSublayer:layer2];
    //剪切超过父图层的部分
    layer.masksToBounds = YES;
}

#pragma mark - 阴影路径
- (void)阴影路径_03 {
    CALayer *layer = [CALayer layer];
    layer.frame = CGRectMake(60, 60, 100, 100);
    layer.backgroundColor = [UIColor redColor].CGColor;
    [self.view.layer addSublayer:layer];
    //1表明不透明，注意：设置阴影当前值不能为0，默认是0
    layer.shadowOpacity = 1.0;
    //阴影颜色
    layer.shadowColor = [UIColor yellowColor].CGColor;
    //创建路径
    CGMutablePathRef path = CGPathCreateMutable();
    //椭圆
    CGPathAddEllipseInRect(path, NULL, CGRectMake(0, 0, 200, 200));
    layer.shadowPath = path;
    CGPathRelease(path);
}

#pragma mark - 添加阴影_02
- (void)层的阴影_02 {
    CALayer *layer = [CALayer layer];
    layer.frame = CGRectMake(60, 60, 100, 100);
    layer.backgroundColor = [UIColor redColor].CGColor;
    [self.view.layer addSublayer:layer];
    layer.shadowOpacity = 0.9;
    layer.shadowColor = [UIColor yellowColor].CGColor;
    //阴影偏移 ->x正 ->-x负 ，y同理
    layer.shadowOffset = CGSizeMake(10, -10);
    //阴影的圆角半径
    layer.shadowRadius = 10;
}

#pragma mark - 图层内容和内容模式_01
- (void)图层内容和内容模式_01 {
    CALayer *layer = [CALayer layer];
    layer.frame = CGRectMake(20, 20, 100, 100);
    layer.backgroundColor = [UIColor redColor].CGColor;
    [self.view.layer addSublayer:layer];
    //设置层内容
    layer.contents = (__bridge id _Nullable)([UIImage imageNamed:@"logo"].CGImage);
    //内容模式，类似于UIImageView的contentMode。默认是填充整个区域 kCAGravityResize
    //kCAGravityResizeAspectFill 这个会向左边靠 贴到view的边边上
    //kCAGravityResizeAspect 这个好像就是按比例了 反正是长方形
    layer.contentsGravity = kCAGravityResizeAspect;
    //设置控制器视图的背景图片 性能很高。 /
    self.view.layer.contents = (__bridge id _Nullable)([UIImage imageNamed:@"logo"].CGImage);
}
@end
