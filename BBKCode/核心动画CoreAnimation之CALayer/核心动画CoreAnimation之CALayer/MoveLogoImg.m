//
//  MoveLogoImg.m
//  核心动画CoreAnimation之CALayer
//
//  Created by zxx_mbp on 2017/5/24.
//  Copyright © 2017年 zxx_mbp. All rights reserved.
//

#import "MoveLogoImg.h"

@implementation MoveLogoImg

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.image = [UIImage imageNamed:@"logo"];
        self.layer.cornerRadius = 20;
        self.layer.shadowRadius = 20;
        self.layer.shadowColor = [[UIColor blackColor]CGColor];
    }
    return self;
}

- (void)showAnimation {
    
}



@end
