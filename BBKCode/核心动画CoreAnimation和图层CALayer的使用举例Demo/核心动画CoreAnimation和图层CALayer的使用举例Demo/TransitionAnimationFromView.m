//
//  TransitionAnimationFromView.m
//  核心动画CoreAnimation和图层CALayer的使用举例Demo
//
//  Created by zxx_mbp on 2017/6/2.
//  Copyright © 2017年 zxx_mbp. All rights reserved.
//

#import "TransitionAnimationFromView.h"
#define IMAGE_COUNT 8
@interface TransitionAnimationFromView (){
    UIImageView *_imageView;
    int _currentIndex;
}

@end

@implementation TransitionAnimationFromView
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //定义图片控件
    _imageView=[[UIImageView alloc]init];
    _imageView.frame=[UIScreen mainScreen].bounds;
    _imageView.contentMode=UIViewContentModeScaleAspectFit;
    _imageView.image=[UIImage imageNamed:@"01.png"];//默认图片
    [self.view addSubview:_imageView];
    //添加手势
    UISwipeGestureRecognizer *leftSwipeGesture=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(leftSwipe:)];
    leftSwipeGesture.direction=UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:leftSwipeGesture];
    
    UISwipeGestureRecognizer *rightSwipeGesture=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(rightSwipe:)];
    rightSwipeGesture.direction=UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:rightSwipeGesture];
}
#pragma mark 向左滑动浏览下一张图片
-(void)leftSwipe:(UISwipeGestureRecognizer *)gesture{
    [self transitionAnimation:YES];
}

#pragma mark 向右滑动浏览上一张图片
-(void)rightSwipe:(UISwipeGestureRecognizer *)gesture{
    [self transitionAnimation:NO];
}

#pragma mark - 转场动画
- (void)transitionAnimation:(BOOL)flag {
    UIViewAnimationOptions options;
    if (flag) {
        options = UIViewAnimationOptionCurveLinear|UIViewAnimationOptionTransitionFlipFromRight;
    }else {
        options = UIViewAnimationOptionCurveLinear|UIViewAnimationOptionTransitionFlipFromLeft;
    }
    
    [UIView transitionWithView:_imageView duration:1.0 options:options animations:^{
        _imageView.image = [self getImage:flag];
    } completion:nil];
}

#pragma mark 取得当前图片
-(UIImage *)getImage:(BOOL)isNext{
    if (isNext) {
        _currentIndex=(_currentIndex+1)%IMAGE_COUNT;
    }else{
        _currentIndex=(_currentIndex-1+IMAGE_COUNT)%IMAGE_COUNT;
    }
    NSString *imageName=[NSString stringWithFormat:@"0%i.png",_currentIndex];
    return [UIImage imageNamed:imageName];
}
@end
