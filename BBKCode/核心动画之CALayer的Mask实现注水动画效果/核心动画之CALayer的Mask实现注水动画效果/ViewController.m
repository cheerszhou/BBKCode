//
//  ViewController.m
//  核心动画之CALayer的Mask实现注水动画效果
//
//  Created by zxx_mbp on 2017/5/27.
//  Copyright © 2017年 zxx_mbp. All rights reserved.
//

#import "ViewController.h"
#import "ZXActivityIndicator.h"

static  const CFTimeInterval duration = 3.0;

@interface ViewController ()
@property (nonatomic, weak) IBOutlet ZXActivityIndicator *loadingIndicator;
@property (nonatomic, weak) IBOutlet UIImageView *grayHead;
@property (nonatomic, weak) IBOutlet UIImageView *greenHead;
@property (nonatomic, strong) CAShapeLayer *maskLayerUp;
@property (nonatomic, strong) CAShapeLayer *maskLayerDown;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.greenHead.layer.mask = [self greenHeadMaskLayer];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.loadingIndicator startAnimation];
    [self startGreenHeadAnimation];
}

- (CALayer*)greenHeadMaskLayer {
    CALayer* mask = [CALayer layer];
    mask.frame = self.greenHead.bounds;
    
    self.maskLayerUp = [CAShapeLayer layer];
    self.maskLayerUp.bounds = CGRectMake(0, 0, 60.0f, 60.f);
    self.maskLayerUp.fillColor = [UIColor greenColor].CGColor;
    self.maskLayerUp.path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(30.0, 30.0) radius:30.0f startAngle:0 endAngle:2*M_PI clockwise:YES].CGPath;
    
    self.maskLayerUp.opacity = 0.8f;
    self.maskLayerUp.position = CGPointMake(-5.0f, -5.0f);
    [mask addSublayer:self.maskLayerUp];
    
    self.maskLayerDown = [CAShapeLayer layer];
    self.maskLayerDown.bounds = CGRectMake(0, 0, 60.f,60.f);
    self.maskLayerDown.fillColor = [UIColor greenColor].CGColor;
    self.maskLayerDown.path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(30.0, 30.0) radius:30.0 startAngle:0 endAngle:2*M_PI clockwise:YES].CGPath;
    self.maskLayerDown.position = CGPointMake(65.f, 65.f);
    [mask addSublayer:self.maskLayerDown];
    
    return mask;
}

- (void)startGreenHeadAnimation {
    CABasicAnimation* animationDown = [CABasicAnimation animationWithKeyPath:@"position"];
    animationDown.fromValue = [NSValue valueWithCGPoint:CGPointMake(-5.0f, -5.0f)];
    animationDown.toValue = [NSValue valueWithCGPoint:CGPointMake(25.0f, 25.0f)];
    animationDown.duration = duration;
    animationDown.repeatCount = MAXFLOAT;
    [self.maskLayerUp addAnimation:animationDown forKey:@"downAnimation"];
    
    CABasicAnimation* animationUp = [CABasicAnimation animationWithKeyPath:@"position"];
    animationUp.fromValue = [NSValue valueWithCGPoint:CGPointMake(65.f, 65.f)];
    animationUp.toValue = [NSValue valueWithCGPoint:CGPointMake(35.f, 35.f)];
    animationUp.duration = duration;
    animationUp.repeatCount = MAXFLOAT;
    [self.maskLayerDown addAnimation:animationUp forKey:@"upAnimation"];
}

@end
