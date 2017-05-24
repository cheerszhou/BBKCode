//
//  SimpleAnimeVC.m
//  核心动画CoreAnimation之CALayer
//
//  Created by zxx_mbp on 2017/5/24.
//  Copyright © 2017年 zxx_mbp. All rights reserved.
//

#import "SimpleAnimeVC.h"
#import "MoveLogoImg.h"

@interface SimpleAnimeVC (){
    dispatch_queue_t dispatchQueue;
}
@property (nonatomic, strong) CALayer *testLayer;
@property (nonatomic, strong) MoveLogoImg *img;
@end

@implementation SimpleAnimeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    //设置界面
    {
        UIButton* btn = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width/4 - 60, 100, 120, 30)];
        [btn setBackgroundColor:[UIColor grayColor]];
        [btn setTitle:@"基础动画" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
        btn.tag = 101;
        
        
        UIButton* btn2 = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width/4*3 - 60, 100, 120, 30)];
        [btn2 setBackgroundColor:[UIColor grayColor]];
        [btn2 setTitle:@"关键帧动画" forState:UIControlStateNormal];
        [btn2 addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn2];
        btn2.tag = 102;
        
        UIView *blackView = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height-10, self.view.frame.size.width, 5)];
        [blackView setBackgroundColor:[UIColor blackColor]];
        [self.view addSubview:blackView];
        
    }

    //设置图层layer
    {
        self.testLayer  = [CALayer layer];
        self.testLayer.position = CGPointMake(self.view.frame.size.width/2, 180);
        self.testLayer.bounds = CGRectMake(0, 0, 50, 50);
        self.testLayer.backgroundColor = [UIColor redColor].CGColor;
        self.testLayer.cornerRadius = 25;
        [self.view.layer addSublayer:_testLayer];
    }
    
    dispatchQueue = dispatch_queue_create("saqueue", NULL);
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)btnClick:(UIButton*)sender {
    if (sender.tag == 101) {
        //基础动画
        [self createSimpleLayerAnim];
    }else if (sender.tag == 102) {
        //关键帧动画
        [self createKeyFrameLayerAnim];
    }
}

- (void)createSimpleLayerAnim {
    self.testLayer.position = CGPointMake(self.view.center.x, self.view.frame.size.height - 35);
    
    CABasicAnimation * basicAnim = [CABasicAnimation animationWithKeyPath:@"position"];
    basicAnim.fromValue = [NSValue valueWithCGPoint:CGPointMake(self.view.frame.size.width/2, 180)];
    basicAnim.toValue = [NSValue valueWithCGPoint:CGPointMake(self.view.center.x, self.view.frame.size.height - 35)];
    //basicAnim.byValue = [NSValue valueWithCGPoint:CGPointMake(200, 200)];
    basicAnim.duration = 1.3;
    basicAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    [self.testLayer addAnimation:basicAnim forKey:@"mybasicAnimation"];
}

- (void)createKeyFrameLayerAnim {
    self.testLayer.position = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height - 35);
    
    CAKeyframeAnimation* keyAnim = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    CGFloat pathL = self.view.frame.size.height - 35 - 180;
    keyAnim.values = @[
                       [NSValue valueWithCGPoint:CGPointMake(self.view.frame.size.width/2, 180)],
                       [NSValue valueWithCGPoint:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height - 35)],
                       [NSValue valueWithCGPoint:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height - 35 - pathL/2)],
                       [NSValue valueWithCGPoint:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height - 35)],
                       [NSValue valueWithCGPoint:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height - 35 - pathL/4)],
                       [NSValue valueWithCGPoint:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height - 35)],
                       [NSValue valueWithCGPoint:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height - 35 - pathL/8)],
                       [NSValue valueWithCGPoint:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height - 35)],
                       [NSValue valueWithCGPoint:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height - 35 - pathL/16)],
                       [NSValue valueWithCGPoint:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height - 35)],
                       [NSValue valueWithCGPoint:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height - 35 - pathL/32)],
                       [NSValue valueWithCGPoint:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height - 35)],
                       [NSValue valueWithCGPoint:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height - 35 - pathL/64)],
                       [NSValue valueWithCGPoint:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height - 35)],
                       [NSValue valueWithCGPoint:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height - 35 - pathL/128)],
                       [NSValue valueWithCGPoint:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height - 35)]
                       ];
    
    keyAnim.keyTimes = [[self getKeyTimes] subarrayWithRange:NSMakeRange(0, 15)];
    keyAnim.duration = [(NSNumber*)[self getKeyTimes].lastObject doubleValue];
    keyAnim.timingFunctions = [self getTimingFuncs];
    [self.testLayer addAnimation:keyAnim forKey:@"hah"];
}


- (NSArray*)getKeyTimes {
    CGFloat time = 1.3;
    CGFloat totalTime = time;
    NSMutableArray*times = [NSMutableArray array];
    [times addObject:[NSNumber numberWithFloat:0]];
    for (int i = 0; i < 14; i++) {
        time /= 1.414;
        totalTime += time;
    }
    
    time = 1.3;
    CGFloat timeRate = time/totalTime;
    [times addObject:[NSNumber numberWithFloat:timeRate]];
    for (int i = 0; i < 14; i++) {
        time /= 1.414;
        timeRate += time/totalTime;
        [times addObject:[NSNumber numberWithFloat:timeRate]];
    }
    
    [times addObject:[NSNumber numberWithFloat:totalTime]];
    return times;
    
}

- (NSArray*)getTimingFuncs {
    NSMutableArray *timingFuncs = [NSMutableArray array];
    BOOL flag = YES;
    for (int i = 0; i < 15; i++) {
        if (flag) {
            [timingFuncs addObject:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
        }else{
            [timingFuncs addObject:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
        }
        flag = !flag;
    }
    return timingFuncs;
}

@end
