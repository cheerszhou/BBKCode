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
@property (nonatomic, strong) ZXProgressView *progressView;
@end

@implementation ProgressLayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.progressView = [[ZXProgressView alloc]initWithFrame:CGRectMake(0, 80, CGRectGetWidth(self.view.frame), CGRectGetWidth(self.view.frame))];
    self.progressView.progress = 0.f;
    self.progressView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:self.progressView];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)changeProgress:(UISlider*)sender {
    self.progressView.progress = sender.value;
}


@end
