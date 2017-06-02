//
//  ZXView.m
//  核心动画CoreAnimation和图层CALayer的使用举例Demo
//
//  Created by zxx_mbp on 2017/6/1.
//  Copyright © 2017年 zxx_mbp. All rights reserved.
//

#import "ZXView.h"
#import "ZXCALayer.h"

@implementation ZXView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self=[super initWithFrame:frame]) {
        ZXCALayer* layer = [[ZXCALayer alloc]init];
        layer.bounds = CGRectMake(0, 0, 185, 185);
        layer.position = CGPointMake(160, 284);
        layer.backgroundColor = [UIColor colorWithRed:0 green:146/255.0 blue:1.0 alpha:1.0].CGColor;
        
        //显示图层
        [layer setNeedsDisplay];
        [self.layer addSublayer:layer];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx {
    [super drawLayer:layer inContext:ctx];
}

@end
