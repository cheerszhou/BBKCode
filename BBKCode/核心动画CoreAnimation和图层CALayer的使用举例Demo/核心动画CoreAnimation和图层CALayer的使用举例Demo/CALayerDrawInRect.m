//
//  CALayerDrawInRect.m
//  核心动画CoreAnimation和图层CALayer的使用举例Demo
//
//  Created by zxx_mbp on 2017/5/31.
//  Copyright © 2017年 zxx_mbp. All rights reserved.
//

#import "CALayerDrawInRect.h"
#import <QuartzCore/QuartzCore.h>
#define PHOTO_HEIGHT 150

@interface CALayerDrawInRect ()<CALayerDelegate>
@property (nonatomic, strong) CALayer *myLayer;
@end

@implementation CALayerDrawInRect

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"CALayer绘图";
    
    [self extension_1];
}


- (void)extension_1 {
    CGPoint position = CGPointMake(160, 200);
    CGRect bounds = CGRectMake(0, 0, PHOTO_HEIGHT, PHOTO_HEIGHT);
    CGFloat cornerRadius = PHOTO_HEIGHT/2;
    CGFloat borderWidth = 2;
    
    //阴影图层
    CALayer* layerShadow = [[CALayer alloc]init];
    layerShadow.bounds = bounds;
    layerShadow.position = position;
    layerShadow.cornerRadius = cornerRadius;
    layerShadow.shadowColor = [UIColor grayColor].CGColor;
    layerShadow.shadowOffset = CGSizeMake(2, 1);
    layerShadow.borderColor = [UIColor grayColor].CGColor;
    layerShadow.shadowOpacity = 1;
    layerShadow.backgroundColor = [UIColor cyanColor].CGColor;
    layerShadow.borderWidth = borderWidth;
    [self.view.layer addSublayer:layerShadow];
    
    //容器图层
    CALayer* layer = [[CALayer alloc]init];
    layer.bounds = bounds;
    layer.position = position;
    layer.backgroundColor = [UIColor redColor].CGColor;
    layer.cornerRadius = cornerRadius;
    layer.masksToBounds = YES;
    layer.borderWidth = borderWidth;
    layer.borderColor = [UIColor whiteColor].CGColor;
    
    //设置图层代理
    layer.delegate = self;
    [self.view.layer addSublayer:layer];
    self.myLayer = layer;
    //调用图层setNeedDisplay，否则代理不会被调用
    [layer setNeedsDisplay];
}

- (void)base {
    //自定义图层
    CALayer *layer = [[CALayer alloc]init];
    layer.bounds = CGRectMake(0, 0, PHOTO_HEIGHT, PHOTO_HEIGHT);
    layer.position = CGPointMake(160, 200);
    layer.cornerRadius = PHOTO_HEIGHT/2.0;
    //注意仅仅设置圆角，对于图形而言可以正常显示，但是对于图层中绘制的图片无法正确显示
    //如果想要正确显示则必须设置masksToBounds=YES，剪切子图层
    layer.masksToBounds = YES;
    //阴影效果无法和masksToBounds同时使用，因为masksToBounds的目的就是剪切外边框，
    //而阴影效果刚好在外边框
    
    //layer.shadowColor=[UIColor grayColor].CGColor;
    //layer.shadowOffset=CGSizeMake(2, 2);
    //layer.shadowOpacity=1;
    
    //设置边框
    layer.borderColor = [UIColor cyanColor].CGColor;
    layer.borderWidth = 2;
    //设置图层代理
    layer.delegate = self;
    //设置图层到根图层
    [self.view.layer addSublayer:layer];
    //调用图层setNeedDisplay,否则代理方法不会被调用
    [layer setNeedsDisplay];
}

- (void)dealloc {
    self.myLayer.delegate = nil;
    NSLog(@"I'm Clearing");
}
#pragma mark - 绘制图形、图像到图层，注意参数中的ctx是图层的图形上下文，其中绘图位置也是相对图层而言的
- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx {
    CGContextSaveGState(ctx);
    //解决图形上文形变，图片倒立的问题
    
    CGContextScaleCTM(ctx, 1, -1);
    CGContextTranslateCTM(ctx, 0, -PHOTO_HEIGHT);
    UIImage* image = [UIImage imageNamed:@"girls.jpg"];
    CGContextDrawImage(ctx, CGRectMake(0, 0, PHOTO_HEIGHT, PHOTO_HEIGHT), image.CGImage);
    CGContextRestoreGState(ctx);
}


@end
