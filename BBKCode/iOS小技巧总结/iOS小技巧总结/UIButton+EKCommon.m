//
//  UIButton+EKCommon.m
//  ChildGuard
//
//  Created by kingo on 15/3/31.
//  Copyright (c) 2015年 xtc. All rights reserved.
//

#import "UIButton+EKCommon.h"

@implementation UIButton (EKCommon)

#define IOS10 ([[[UIDevice currentDevice]systemVersion] floatValue] >= 10.0)

static inline UIColor * HexRGB(int rgbValue,float alv){
    
    if (IOS10) {
        return [UIColor colorWithDisplayP3Red:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:alv/1.0];
    }else{
        return [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:alv/1.0];
    }
}

- (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size {
    if (!color || size.width <= 0 || size.height <= 0) return nil;
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)setColor:(UIColor *)color withTextColor:(UIColor *)textColor{
    
    //默认边框色与背景色相同
    [self setColor:color withTextColor:textColor borderColor:color];
}

- (void)setColor:(UIColor *)bColor withTextColor:(UIColor *)tColor borderColor:(UIColor *)oColor{
    [self setColor:bColor];
    [self setTitleColor:tColor forState:UIControlStateNormal];
    
    //self.layer.borderWidth = 1.f;
    self.layer.borderColor = oColor.CGColor;
    //self.clipsToBounds = YES;
}

- (void)setBorderColor:(UIColor *)bColor borderWidth:(CGFloat)width{
    self.layer.borderWidth = width;
    self.layer.borderColor = bColor.CGColor;
}

- (void)setText:(NSString *)text withFontSize:(CGFloat)fontSize{
    [self.titleLabel setFont:[UIFont systemFontOfSize:fontSize]];
    [self setTitle:text forState:UIControlStateNormal];
}



- (void)setDefaultValue{
#if 1
    [self setFlatStyleHot];
#else
    [self setColor:kDefaultButtonColor];
    [self setTitleColor:kDefaultButtonTextColor forState:UIControlStateNormal];
    
    self.layer.cornerRadius = 4;
    self.layer.borderWidth = 0.5;
    self.layer.borderColor = kDefaultButtonColor.CGColor;
    self.clipsToBounds = YES;
#endif
    [self setFontLarge];
}

- (void)setStyle:(EKButtonStyle)style{
    switch (style) {
        case EKButtonStyleLogin:
            [self setLoginStyle];
            break;
        case EKButtonStyleLoginFixedWidth:
            [self setLoginStyle];
            //使用圆角
            
            break;
            
        default:
            [self setDefaultValue];
            break;
    }
}

- (void)setLoginStyle{

    //需要设置高度
    self.layer.cornerRadius = 6.f;//kLoginButtonHeight/2;
    self.clipsToBounds = YES;
}

- (void)setLoginEnabled:(BOOL)enabled{
    if ([self isEnabled] != enabled) {
        [self setEnabled:enabled];
    
    }
}

- (void)setFlatStyle{
    [self setFlatForiOS6];
    
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 6;
    self.layer.borderWidth = 0.5;
    self.layer.borderColor = [UIColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:1.0].CGColor;
}

- (void)setFlatStyleNormal{
    
    [self setFlatStyle];
    
    [self setTitleColor:[UIColor colorWithRed:136/255.0 green:136/255.0 blue:136/255.0 alpha:1.0] forState:UIControlStateNormal];

}

- (void)setFlatStyleHot{
    [self setFlatStyle];
    
    [self setTitleColor:[UIColor colorWithRed:255/255.0 green:96/255.0 blue:0/255.0 alpha:1.0] forState:UIControlStateNormal];

}

- (void)setButtonSettingSytle {
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.titleLabel.font = [UIFont systemFontOfSize:17 ];
    self.layer.cornerRadius = 6;
    self.clipsToBounds = YES;
}

//** 按钮开启状态，红色
- (void)setStatusOpened{
    [self setBackgroundImage:[self imageWithColor:HexRGB(0xff4444, 1.0) size:CGSizeMake(1.0, 1.0)] forState:UIControlStateNormal];
    [self setBackgroundImage:[self imageWithColor:HexRGB(0xd03737, 1.0) size:CGSizeMake(1.0, 1.0)] forState:UIControlStateHighlighted];
    [self setButtonSettingSytle];
    
}
//** 按钮保存状态，黄色
- (void)setStatusSaved {
    [self setBackgroundImage:[self imageWithColor:HexRGB(0xffaa22, 1.0) size:CGSizeMake(1.0, 1.0)] forState:UIControlStateNormal];
    [self setBackgroundImage:[self imageWithColor:HexRGB(0xffaa22, 0.5) size:CGSizeMake(1.0, 1.0)] forState:UIControlStateDisabled];
    [self setBackgroundImage:[self imageWithColor:HexRGB(0xd68800, 1.0) size:CGSizeMake(1.0, 1.0)] forState:UIControlStateHighlighted];
    [self setButtonSettingSytle];
}

//** 按钮关闭状态，蓝色
- (void)setStatusClosed{
    [self setBackgroundImage:[self imageWithColor:HexRGB(0x29a9ff, 1.0) size:CGSizeMake(1.0, 1.0)] forState:UIControlStateNormal];
    [self setBackgroundImage:[self imageWithColor:HexRGB(0x1888dd, 1.0) size:CGSizeMake(1.0, 1.0)] forState:UIControlStateHighlighted];
    [self setButtonSettingSytle];
}

//** 按钮不可用状态，背景色透明度50%
- (void)setStatusDisabled {
    self.enabled = NO;
}
//** 按钮可用状态
- (void)setStatusEnabled {
    self.enabled = YES;
}

- (void)setStatusGrey:(BOOL)enable{
    [self setEnabled:enable];
    if (enable) {
        [self setFlatStyleHot];
    }
    else {
        [self setFlatStyleNormal];
    }
}

- (void)setEnabled:(BOOL)enabled withColor:(UIColor *)color{
    [self setEnabled:enabled];
    [self setColor:color];
}

- (void)setFlatStyleWithTextColor:(UIColor *)color{
    [self setFlatStyle];
    
    [self setTitleColor:color forState:UIControlStateNormal];
}

+ (instancetype)initGoolgleFloatingStyleWithDefaultValue{
    UIButton *btn = [[UIButton alloc] init];
    
    [btn setImage:[UIImage imageNamed:@"bt_add_default"] forState:UIControlStateNormal];
    //[btn setImage:[UIImage imageNamed:@"bt_add_pressed"] forState:UIControlStateHighlighted];

    
    return btn;
}

- (void)showBarButtonStyle:(NavigationBarItemStyle)style{
    switch (style) {
        case NavigationBarItemStyleWhiteCustom:
            [self setStatusBarWhiteCustom];
            break;
        case NavigationBarItemStyleOrange:
            [self setStatusBarOrange];
            break;
        case NavigationBarItemStyleWhite:
        default:
            [self setStatusBarWhite];
            break;
    }
}

// 白色导航栏默认颜色
- (void)setStatusBarWhite{
    [self setTitleColor:HexRGB(0x888888, 1.0f) forState:UIControlStateNormal];
    [self setTitleColor:HexRGB(0x888888, 0.6f) forState:UIControlStateHighlighted];
    [self setTitleColor:HexRGB(0x888888, 0.3f) forState:UIControlStateDisabled];
}

// 白色导航栏黄色文字
- (void)setStatusBarWhiteCustom{
    [self setTitleColor:HexRGB(0xffaa22, 1.0f) forState:UIControlStateNormal];
    [self setTitleColor:HexRGB(0xffaa22, 0.6f) forState:UIControlStateHighlighted];
    [self setTitleColor:HexRGB(0xffaa22, 0.5f) forState:UIControlStateDisabled];
}

// 黄色导航栏默认颜色
- (void)setStatusBarOrange{
    [self setTitleColor:HexRGB(0xffffff, 1.0f) forState:UIControlStateNormal];
    [self setTitleColor:HexRGB(0xffffff, 0.6f) forState:UIControlStateHighlighted];
    [self setTitleColor:HexRGB(0xffffff, 0.5f) forState:UIControlStateDisabled];
}

+(instancetype)buttonWithTitle:(NSString *)title
                         target:(id)target
                         action:(SEL)action{
    return [self buttonWithTitle:title titleColor:HexRGB(0x888888, 1.0f) target:target action:action onView:nil];
}

+(instancetype)buttonWithTarget:(id)target
                        action:(SEL)action
                        onView:(UIView *)view
{
    UIButton *button = [self buttonWithType:UIButtonTypeCustom];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    if (view) {
        [view addSubview:button];
    }
    return button;
}


@end
