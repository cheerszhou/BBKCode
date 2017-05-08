//
//  VCFirst.m
//  导航控制器动画
//
//  Created by zxx_mbp on 2017/5/7.
//  Copyright © 2017年 zxx_mbp. All rights reserved.
//

#import "VCFirst.h"
#import "VCSecond.h"

@interface VCFirst ()

@end

@implementation VCFirst

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"控制器一";
    self.view.backgroundColor = [UIColor redColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    //定义一个动画变换对象，层动画对象
    //类方法获取对象
    CATransition* amni = [CATransition animation];
    //设置动画的时间长度
    amni.duration = 1;
    //设置动画的类型，决定动画的效果形式
    amni.type = @"rippleEffect";
    //设置动画的子类型、列如动画的放向
    amni.subtype = kCATransitionFromTop;
    amni.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    [self.navigationController.view.layer addAnimation:amni forKey:nil];
    //创建控制器二
    VCSecond* vcSecond = [VCSecond new];
    [self.navigationController pushViewController:vcSecond animated:YES];
    
                          
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
