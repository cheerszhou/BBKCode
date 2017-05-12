//
//  ViewController.m
//  动态改变app icon(一)
//
//  Created by zxx_mbp on 2017/5/12.
//  Copyright © 2017年 zxx_mbp. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIButton *btn;

@property (nonatomic, copy) NSArray<NSString*> *weathers;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.btn addTarget:self action:@selector(btnAction) forControlEvents:UIControlEventTouchUpInside];
    self.weathers = @[@"晴",@"多云",@"小雨",@"大雨",@"雪",@""];
}


- (void)btnAction {
    NSString* weahter = self.weathers[arc4random() % self.weathers.count];
    [self setAppIconWithName:weahter];
}

- (void)setAppIconWithName:(NSString*)iconName {
    if (![[UIApplication sharedApplication] supportsAlternateIcons]) {
        return;
    }
    
    if ([iconName isEqualToString:@""]) {
        iconName = nil;
    }
    
    [[UIApplication sharedApplication] setAlternateIconName:iconName completionHandler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"更换app图标发生错误了：%@",error);
        }
    }];
}

@end
