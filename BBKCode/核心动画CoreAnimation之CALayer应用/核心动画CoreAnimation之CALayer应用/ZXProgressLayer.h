//
//  ZXProgressLayer.h
//  核心动画CoreAnimation之CALayer应用
//
//  Created by zxx_mbp on 2017/5/25.
//  Copyright © 2017年 zxx_mbp. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
typedef void(^ZXProgressReport)(NSUInteger progress,CGRect textRect, CGColorRef textColor) ;
@interface ZXProgressLayer : CALayer
@property (nonatomic, assign) float strokeEnd;
@property (nonatomic, assign) float progress;
@property (nonatomic, assign) CGColorRef strokeColor;
@property (nonatomic, assign) CGColorRef fillColor;
@property (nonatomic, copy) ZXProgressReport report;
@end

