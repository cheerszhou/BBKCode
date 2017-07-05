//
//  ViewController.m
//  CoreAnimation专题2-CAShapeLayerWithBezierPath
//
//  Created by zxx_mbp on 2017/7/5.
//  Copyright © 2017年 zxx_mbp. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (nonatomic, strong) CAShapeLayer *layer;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CAShapeLayer* layer = [CAShapeLayer layer];
    layer.strokeColor = [UIColor redColor].CGColor;
    layer.lineWidth = 6.0;
    layer.fillColor = [UIColor clearColor].CGColor;
    self.layer = layer;
    [self.view.layer  addSublayer:layer];
}

- (IBAction)drawRect:(id)sender {
    UIBezierPath* path = [UIBezierPath bezierPathWithRect:CGRectMake(3, 3, 80, 80)];
    self.layer.path = path.CGPath;
}

- (IBAction)drawLine:(id)sender {
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint:CGPointMake(10, 10)];
    [bezierPath addLineToPoint:CGPointMake(100, 10)];
    [bezierPath addLineToPoint:CGPointMake(100, 100)];
    self.layer.path = bezierPath.CGPath;
}

@end
