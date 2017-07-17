//
//  ViewController.m
//  CALayer_anchorPoint-锚点的妙用
//
//  Created by zxx_mbp on 2017/7/13.
//  Copyright © 2017年 zxx_mbp. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *hour_hand;
@property (weak, nonatomic) IBOutlet UIImageView *minute_hand;
@property (weak, nonatomic) IBOutlet UIImageView *second_hand;
@property (nonatomic, strong) NSTimer *timer;
@property (weak, nonatomic) IBOutlet UIView *foreground;
@property (weak, nonatomic) IBOutlet UIView *background;
@property (nonatomic, strong) IBOutletCollection(UIView) NSArray *digitalViews;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.f target:self selector:@selector(tick) userInfo:nil repeats:YES];
    [self tick];
    
    //zPosition最实用的功能就是改变图层的显示顺序
    self.foreground.layer.zPosition = 1.0f;
    
    //图片的拉伸过滤
    [self LCDClock];
    
}

- (void)LCDClock {
    UIImage * digitsImage = [UIImage imageNamed:@"digit_numbers"];
    
    //set up digit views
    for (UIView* view in self.digitalViews) {
        //set contents
        view.layer.contents = (__bridge id _Nullable)(digitsImage.CGImage);
        view.layer.contentsRect = CGRectMake(0, 0, 0.1, 1.0);
        view.layer.contentsGravity = kCAGravityResizeAspect;
        //设置图片拉伸效果
        view.layer.magnificationFilter = kCAFilterNearest;
    }
}


- (void)tick {
    //将时间转换成小时/分钟/秒
    NSCalendar *calender = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierChinese];
    NSUInteger units = NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond;
    NSDateComponents * components = [calender components:units fromDate:[NSDate date]];
    
    //计算每秒中时针，分针，秒针转的角度
    CGFloat hoursAngle = (components.hour/12.0)*M_PI*2;
    CGFloat minsAngle = (components.minute/60.0)*M_PI*2;
    CGFloat secsAngle = (components.second/60.0)*M_PI*2;
    
    self.hour_hand.layer.anchorPoint = CGPointMake(0.5, 0.8);
    self.minute_hand.layer.anchorPoint = CGPointMake(0.5, 0.8);
    self.second_hand.layer.anchorPoint = CGPointMake(0.5, 0.85);
    
    //转动时针、分针、秒针
    self.hour_hand.transform = CGAffineTransformMakeRotation(hoursAngle);
    self.minute_hand.transform = CGAffineTransformMakeRotation(minsAngle);
    self.second_hand.transform = CGAffineTransformMakeRotation(secsAngle);
    
    //计算LED时钟的显示
    [self setDigit:components.hour/10 forView:self.digitalViews[0]];
    [self setDigit:components.hour%10 forView:self.digitalViews[1]];
    
    [self setDigit:components.minute/10 forView:self.digitalViews[2]];
    [self setDigit:components.minute%10 forView:self.digitalViews[3]];
    
    [self setDigit:components.second/10 forView:self.digitalViews[4]];
    [self setDigit:components.second%10 forView:self.digitalViews[5]];
}


- (void)setDigit:(NSUInteger)digit forView:(UIView*)view {
    // adjust contentsRect to select correct digit
    view.layer.contentsRect = CGRectMake(digit*0.1, 0, 0.1, 1.0);
    
}




@end
