//
//  ViewController.m
//  CoreAnimation专题1-CADisplayLink同步屏幕刷新
//
//  Created by zxx_mbp on 2017/7/4.
//  Copyright © 2017年 zxx_mbp. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, strong) UIView *myView;
@property (nonatomic, assign) NSTimeInterval beginTime;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //构建一个CADisplayLink
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(onDisplayLink:)];
    
    //想runloop中添加displayLink,注意runloop中mode的概念，具体内容看@README
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    //记录动画开始时间
    self.beginTime = CACurrentMediaTime();
    
}

- (void)onDisplayLink:(CADisplayLink*)displayLink {
    //动画经历的时间
    NSTimeInterval currentTime = CACurrentMediaTime() - self.beginTime;
    //起始值,终止值,持续时间
    CGPoint fromPoint = CGPointMake(10, 20);
    CGPoint toPoint = CGPointMake(300, 400);
    NSTimeInterval duartion = 2.78;
    //插值百分比
    CGFloat percent = currentTime/duartion;
    if (percent>1) {
        percent = 1;
        [displayLink invalidate];
    }
    
    //easaIn 效果
    percent = [self easeIn:percent];
    
    //使用插值公式计算视图的x和y
    CGFloat x = [self _interpolateFrom:fromPoint.x to:toPoint.x percent:percent];
    CGFloat y = [self _interpolateFrom:fromPoint.y to:toPoint.y percent:percent];
    //更新视图位置
    self.myView.center = CGPointMake(x, y);
}

//easeIn反冲函数
- (CGFloat)easeIn:(CGFloat)aspeed {
    return aspeed*aspeed;
}

- (UIView *)myView {
    if (!_myView) {
        _myView = [UIView new];
        _myView.frame = CGRectMake(0, 0, 80, 80);
        _myView.backgroundColor = [UIColor yellowColor];
        [self.view addSubview:_myView];
    }
    return _myView;
}

//插值
- (CGFloat)_interpolateFrom:(CGFloat)from to:(CGFloat)to percent:(CGFloat)percent {
    return from + (to - from)*percent;
}


@end
