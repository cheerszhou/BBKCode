//
//  ViewController.m
//  高级动画
//
//  Created by zxx_mbp on 2017/5/7.
//  Copyright © 2017年 zxx_mbp. All rights reserved.
//

#import "ViewController.h"
//管理类动画头文件
#import "HMGLTransitionManager.h"
//开门3D动画类型
#import "DoorsTransition.h"
//模拟布匹动画类型
#import "ClothTransition.h"
//3D变化动画
#import "Switch3DTransition.h"

@interface ViewController ()
@property (nonatomic, strong) UIView *parentView;//动画切换的容器父视图
@property (nonatomic, strong) UIImageView *imageView1;
@property (nonatomic, strong) UIImageView *imageView2;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)drawCircleAndLine:(id)sender {
}
- (UIView *)parentView {
    if (!_parentView) {
        _parentView = [[UIView alloc]initWithFrame:CGRectMake(40, 80, 260, 380)];
        [self.view addSubview:_parentView];
        _parentView.backgroundColor = [UIColor orangeColor];
    }
    return _parentView;
}

- (UIImageView *)imageView1 {
    if (!_imageView1) {
        _imageView1 = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 260, 380)];
        _imageView1.backgroundColor= [UIColor blueColor];
        [self.parentView addSubview:_imageView1];
    }
    return _imageView1;
}

- (UIImageView *)imageView2 {
    if (!_imageView2) {
        _imageView2 = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 260, 380)];
        [self.parentView addSubview:_imageView2];
        _imageView2.backgroundColor = [UIColor greenColor];
    }
    return _imageView2;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self animove];
}

- (void)animove{
//    HMGLTransitionManager* manager = [HMGLTransitionManager sharedTransitionManager];
}
@end
