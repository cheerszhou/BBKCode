//
//  CAPauseTestVC.m
//  核心动画CoreAnimation之CALayer
//
//  Created by zxx_mbp on 2017/5/24.
//  Copyright © 2017年 zxx_mbp. All rights reserved.
//

#import "CAPauseTestVC.h"

typedef enum:NSUInteger {
    BtnStatusStart,
    BtnStatusPause,
    BtnStatusContinue,
}BtnStatus;

@interface CAPauseTestVC ()<CAAnimationDelegate>
@property (nonatomic, assign) BtnStatus btnStatus;
@property (nonatomic, assign) CGFloat sliderValue;
@property (nonatomic, assign) CGFloat fromValue;
@property (nonatomic, assign) CGFloat toValue;
@property (nonatomic, strong) CADisplayLink *displayLink;

@property (nonatomic, strong) UIButton *btnControl;
@property (nonatomic, strong) CALayer *testLayer;
@property (nonatomic, strong) CALayer *testLayer2;
@property (nonatomic, strong) UISlider *slider;
@property (nonatomic, strong) CABasicAnimation *testAnimation;
@end

@implementation CAPauseTestVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    //init data
    {
        self.btnControl = 0;
        self.testAnimation = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
        self.testAnimation.duration = 3.0;
        self.testAnimation.toValue = (__bridge id _Nullable)([UIColor yellowColor].CGColor);
        self.testAnimation.fromValue = (__bridge id _Nullable)([UIColor redColor].CGColor);
        self.testAnimation.delegate = self;
        
        self.fromValue = CGColorGetComponents([UIColor redColor].CGColor)[1];
        self.toValue = CGColorGetComponents([UIColor yellowColor].CGColor)[1];
    }
    //set subviews
    {
        self.testLayer = [[CALayer alloc]init];
        self.testLayer.position = CGPointMake(self.view.frame.size.width/2, 200);
        self.testLayer.bounds = CGRectMake(0, 0, 200, 100);
        self.testLayer.backgroundColor = [UIColor redColor].CGColor;
        [self.view.layer addSublayer:self.testLayer];
        
        self.testLayer2 = [[CALayer alloc]init];
        self.testLayer2.position = CGPointMake(self.view.frame.size.width/2, 400);
        self.testLayer2.backgroundColor = [UIColor redColor].CGColor;
        self.testLayer2.bounds = CGRectMake(0, 0, 200, 100);
        [self.view.layer addSublayer:self.testLayer2];
        
        self.slider = [[UISlider alloc]initWithFrame:CGRectMake(self.testLayer.position.x-100, self.testLayer.position.y + 50, 200, 50)];
        [self.slider setBackgroundColor:[UIColor colorWithWhite:0.9 alpha:0.2]];
        [self.slider setContinuous:YES];
        [self.slider addTarget:self action:@selector(onSliderChanged:) forControlEvents:UIControlEventValueChanged];
        [self.view addSubview:self.slider];
        
        self.btnControl = [[UIButton alloc]initWithFrame:CGRectMake(_slider.center.x-50, _testLayer2.position.y+60, 100, 30)];
        [self.btnControl setBackgroundColor:[UIColor grayColor]];
        [self.btnControl setTitle:@"开 始" forState:UIControlStateNormal];
        [self.btnControl addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.btnControl];
        
        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(onDisplayLink:)];
        [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        
        
    }
}


- (void)onDisplayLink:(CADisplayLink*)link {
    if (self.testLayer2.animationKeys.count == 0) {
        self.btnStatus = BtnStatusStart;
        [self.btnControl setTitle:@"开 始" forState:UIControlStateNormal];
        self.slider.value = 0;
    }else if (self.testLayer.speed < 0.0001 && BtnStatusContinue != self.btnStatus) {
        self.btnStatus = BtnStatusContinue;
        [self.btnControl setTitle:@"继 续" forState:UIControlStateNormal];
    }
    
    if (self.btnStatus != BtnStatusStart) {
        CGFloat nowValue = CGColorGetComponents(self.testLayer.presentationLayer.backgroundColor)[1];
        self.slider.value = (nowValue - self.fromValue)/(self.toValue - self.fromValue);
        self.sliderValue = self.slider.value;
    }
}

- (void)onSliderChanged:(UISlider*)slider {
    if (self.testLayer.animationKeys.count == 0) {
        [self btnClick:nil];
        [self btnClick:nil];
    }
    
    if (self.testLayer.speed < 0.0001) {
        self.testLayer.timeOffset += 3*(_slider.value - _sliderValue);
        self.testLayer2.timeOffset += 3*(self.slider.value - self.sliderValue);
    }
    
    self.sliderValue = self.slider.value;
}

- (void)btnClick:(UIButton*)btn {
    if (BtnStatusStart == self.btnStatus) {
        [self.testLayer2 addAnimation:self.testAnimation forKey:@"testAnimation"];
        [self.testLayer addAnimation:self.testAnimation forKey:@"testAnimation"];
        self.btnStatus = BtnStatusPause;
        [_btnControl setTitle:@"占 停" forState:UIControlStateNormal];
        
    }else if (self.btnStatus == BtnStatusPause) {
        self.btnStatus = BtnStatusContinue;
        [self pauseAnimation];
        [self.btnControl setTitle:@"继 续" forState:UIControlStateNormal];
    }else if (self.btnStatus == BtnStatusContinue){
        self.btnStatus = BtnStatusPause;
        [self continueAnimation];
        [self.btnControl setTitle:@"暂 停" forState:UIControlStateNormal];
    }
}


- (void)pauseAnimation {
    self.testLayer.timeOffset = [self.testLayer convertTime:CACurrentMediaTime() fromLayer:nil];
    self.testLayer.speed = 0;
    
    self.testLayer2.timeOffset = [self.testLayer2 convertTime:CACurrentMediaTime() fromLayer:nil];
    self.testLayer2.speed = 0;
    
}

- (void)continueAnimation {
    self.testLayer.beginTime = CACurrentMediaTime() - self.testLayer.timeOffset;
    self.testLayer.speed = 1;
    self.testLayer.timeOffset = 0;
    
    self.testLayer2.beginTime = CACurrentMediaTime() - self.testLayer2.timeOffset;
    self.testLayer2.speed = 1;
    self.testLayer2.timeOffset = 0;
}

@end
