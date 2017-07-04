//
//  ViewController.m
//  核心动画CoreAnimation之CALayer应用
//
//  Created by zxx_mbp on 2017/5/24.
//  Copyright © 2017年 zxx_mbp. All rights reserved.
//

#import "ProgressLayerViewController.h"
#import "ZXProgressView.h"
@interface ProgressLayerViewController ()
@property (weak, nonatomic) IBOutlet UIView *TimeOffsetAndSpeedView;
@property (nonatomic, strong) ZXProgressView *progressView;
@end

@implementation ProgressLayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.progressView = [[ZXProgressView alloc]initWithFrame:CGRectMake(0, 80, CGRectGetWidth(self.view.frame), CGRectGetWidth(self.view.frame))];
    self.progressView.progress = 0.f;
    self.progressView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:self.progressView];
    self.TimeOffsetAndSpeedView.backgroundColor = [UIColor redColor];
    
    CABasicAnimation* changeColor = [CABasicAnimation animation];
    changeColor.keyPath = @"backgroundColor";
    changeColor.toValue = (__bridge id _Nullable)([UIColor orangeColor].CGColor);
    changeColor.fromValue = (__bridge id _Nullable)([UIColor greenColor].CGColor);
    changeColor.duration = 1.0;
    self.TimeOffsetAndSpeedView.layer.speed = 0;
    [self.TimeOffsetAndSpeedView.layer addAnimation:changeColor forKey:@"changecolor"];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)changeProgress:(UISlider*)sender {
    self.progressView.progress = sender.value;
    self.TimeOffsetAndSpeedView.layer.timeOffset = sender.value;
}


@end
