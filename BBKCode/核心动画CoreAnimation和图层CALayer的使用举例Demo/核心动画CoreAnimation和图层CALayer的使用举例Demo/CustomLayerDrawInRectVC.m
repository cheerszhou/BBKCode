//
//  CustomLayerDrawInRectVC.m
//  核心动画CoreAnimation和图层CALayer的使用举例Demo
//
//  Created by zxx_mbp on 2017/6/1.
//  Copyright © 2017年 zxx_mbp. All rights reserved.
//

#import "CustomLayerDrawInRectVC.h"
#import "ZXView.h"
@interface CustomLayerDrawInRectVC ()

@end

@implementation CustomLayerDrawInRectVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    ZXView* view = [[ZXView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    view.backgroundColor = [UIColor colorWithRed:249.0/255.0 green:249.0/255.0 blue:249/255.0 alpha:1];
    [self.view addSubview:view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
