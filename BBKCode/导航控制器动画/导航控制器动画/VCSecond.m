//
//  VCSecond.m
//  导航控制器动画
//
//  Created by zxx_mbp on 2017/5/7.
//  Copyright © 2017年 zxx_mbp. All rights reserved.
//

#import "VCSecond.h"

@interface VCSecond ()
@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation VCSecond

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"控制器二";
    self.view.backgroundColor=[UIColor greenColor];
    
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CATransition* ami = [CATransition animation];
    ami.duration = 1;
    ami.type = @"rippleEffect";
    ami.subtype = kCATransitionFromRight;
    [self.navigationController.view.layer addAnimation:ami forKey:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIImageView *)imageView {
    if (_imageView) {
        _imageView = [[UIImageView alloc]init];
        [self.view addSubview:_imageView];
    }
    return _imageView;
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
