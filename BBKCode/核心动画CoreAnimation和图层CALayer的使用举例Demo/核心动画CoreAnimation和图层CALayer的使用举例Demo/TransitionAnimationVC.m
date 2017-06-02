//
//  TransitionAnimationVC.m
//  核心动画CoreAnimation和图层CALayer的使用举例Demo
//
//  Created by zxx_mbp on 2017/6/1.
//  Copyright © 2017年 zxx_mbp. All rights reserved.
//

#import "TransitionAnimationVC.h"

#define kImageCount 8
@interface TransitionAnimationVC ()
@property (nonatomic, strong) UIImageView *myImageView;
@property (nonatomic, assign) NSInteger currentIndex;
@end

@implementation TransitionAnimationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.myImageView = [[UIImageView alloc]initWithFrame:self.view.bounds];
    self.myImageView.image = [UIImage imageNamed:@"01.png"];
    self.myImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:_myImageView];
    //添加手势
    UISwipeGestureRecognizer* leftSwipeGesture = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(leftSwipe:)];
    leftSwipeGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:leftSwipeGesture];
    
    UISwipeGestureRecognizer* rightSwipeGesture = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(rightSwipe:)];
    rightSwipeGesture.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:rightSwipeGesture];
}


#pragma mark - 向左滑动浏览下张图片 
- (void)leftSwipe:(UISwipeGestureRecognizer*)gesture {
    [self transitionAnimtion:YES];
}

#pragma mark - 向右滑动浏览上张图片
- (void)rightSwipe:(UISwipeGestureRecognizer*)gesture {
    [self transitionAnimtion:NO];
}

#pragma mark - 添加转场动画 

- (void)transitionAnimtion:(BOOL)flag {
    //1.创建转场动画对象
    CATransition* transition = [[CATransition alloc]init];
    
    //2.设置动画类型，注意对于苹果官方没有公开的动画类型只能使用字符串，并没有对应的常亮使用
    transition.type = @"cube";
    //设置子类型
    if (flag) {
        transition.subtype = kCATransitionFromRight;
    }else {
        transition.subtype = kCATransitionFromLeft;
    }
    
    //设置动画时长
    transition.duration = 1.0f;
    
    //3.设置转场动画后,给新视图添加转场动画
    self.myImageView.image = [self getImage:flag];
    [self.myImageView.layer addAnimation:transition forKey:@"abc"];
}

- (UIImage*)getImage:(BOOL)flag {
    if (flag) {
        self.currentIndex = (self.currentIndex + 1)%kImageCount + 1;
        
    }else {
        self.currentIndex = (self.currentIndex - 1 + kImageCount)%kImageCount + 1;
    }
    return [UIImage imageNamed:[NSString stringWithFormat:@"0%ld.png",self.currentIndex]];
    
}

@end
