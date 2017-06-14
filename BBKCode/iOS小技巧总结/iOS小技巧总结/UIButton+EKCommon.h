//
//  UIButton+EKCommon.h
//  ChildGuard
//
//  Created by kingo on 15/3/31.
//  Copyright (c) 2015年 xtc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,EKButtonStyle) {
    EKButtonStyleDefault            = 0,
    EKButtonStyleLogin              = 1, //登录界面：橘色背景，6pt圆角
    EKButtonStyleLoginFixedWidth    = 2, //登录界面：固定宽度
};

//导航栏按钮显示模式
typedef NS_ENUM(NSInteger,NavigationBarItemStyle) {
    NavigationBarItemStyleDefault        = 0,// 默认，视导航栏而定
    NavigationBarItemStyleWhite          = 1,// 白色导航栏黑色文字
    NavigationBarItemStyleWhiteCustom    = 2,// 白色导航栏橘色文字
    NavigationBarItemStyleOrange         = 3,// 黄色导航栏白色文字
};


@interface UIButton (EKCommon)

//iOS6下扁平化按钮
- (void)setFlatForiOS6;

//设置按钮颜色
- (void)setColor:(UIColor *)color;

/*!
 *  @author kingo, 16-07-23 15:07:18
 *
 *  @brief 扁平化风格设置背景色
 *
 *  @param color
 *  @param textColor
 */
- (void)setColor:(UIColor *)color withTextColor:(UIColor *)textColor;

/*!
 *  @author kingo, 16-08-24 15:08:35
 *
 *  @brief 设置按钮颜色
 *
 *  @param bColor 背景色
 *  @param tColor 文本色
 *  @param oColor 边框色
 */
- (void)setColor:(UIColor *)bColor withTextColor:(UIColor *)tColor borderColor:(UIColor *)oColor;
- (void)setBorderColor:(UIColor *)bColor borderWidth:(CGFloat)width;

- (void)setText:(NSString *)text withFontSize:(CGFloat)fontSize;

- (void)setFontLarge;

/*!
 *  @author kingo, 15-09-09 17:09:38
 *
 *  @brief  按钮统一风格显示
 */
- (void)setDefaultValue;

- (void)setStyle:(EKButtonStyle)style;

/**
 注册登录重新更换风格
 */
- (void)setLoginStyle;

- (void)setLoginEnabled:(BOOL)enabled;

/*!
 *  @author kingo, 15-11-24 08:11:35
 *
 *  @brief  扁平化风格显示
 */
- (void)setFlatStyleNormal;
- (void)setFlatStyleHot;

- (void)setFlatStyleWithTextColor:(UIColor *)color;

//文本+图片重新排版
//默认是左图片，右文本
//上下排版
- (void)setImageTopWithTitleBottom:(UIImage *)image withTitle:(NSString *)title  withFont:(UIFont *)font forState:(UIControlState)stateType;
//左右排版
- (void)setImageRightWithTitleLeft:(UIImage *)image withTitle:(NSString *)title  withFont:(UIFont *)font forState:(UIControlState)stateType;

//设置字体下划线
- (void)setImageRightWithTitleLeft:(UIImage *)image withAttributeTitle:(NSString *)title  withFont:(UIFont *)font forState:(UIControlState)stateType;


//** 按钮开启状态，红色
- (void)setStatusOpened;
//** 按钮关闭状态，蓝色
- (void)setStatusClosed;
//** 按钮保存状态，黄色
- (void)setStatusSaved;
//** 按钮不可用状态，按钮透明度为50%
- (void)setStatusDisabled;
//** 按钮可用状态
- (void)setStatusEnabled;


/*!
 *  @author kingo, 16-01-06 17:01:21
 *
 *  @brief 按钮灰显
 */
- (void)setStatusGrey:(BOOL)enable;

- (void)setEnabled:(BOOL)enabled withColor:(UIColor *)color;

/*!
 *  @author kingo, 16-01-06 15:01:46
 *
 *  @brief 按Google风格悬浮添加按钮
 *
 *  @return 
 */
+ (instancetype)initGoolgleFloatingStyleWithDefaultValue;

// 显示导航栏按钮风格
- (void)showBarButtonStyle:(NavigationBarItemStyle)style;

+(instancetype)buttonWithTitle:(NSString *)title
                         target:(id)target
                         action:(SEL)action;

//纯文字（正常） 默认字体无高亮
+(instancetype)buttonWithTitle:(NSString *)title
                         titleColor:(UIColor *)titleColor
                         target:(id)target
                         action:(SEL)action
                         onView:(UIView *)view;
//纯文字（正常）可以设置文字高亮
+(instancetype)buttonWithTitle:(NSString *)title
                titleHighlight:(BOOL)highlighted
                    titleColor:(UIColor *)titleColor
                        target:(id)target
                        action:(SEL)action
                        onView:(UIView *)view;

//纯文字（正常）可以设置背景高亮
+(instancetype)buttonWithTitle:(NSString *)title
           backgroundHighlight:(BOOL)highlighted
                    titleColor:(UIColor *)titleColor
                        target:(id)target
                        action:(SEL)action
                        onView:(UIView *)view;

//纯文字（正常和选中）
+(instancetype)buttonWithTitles:(NSArray<NSString *>*)titles
                         titleColors:(NSArray<UIColor *>*)titleColors
                         target:(id)target
                         action:(SEL)action
                         onView:(UIView *)view;

// 纯图片(正常)
+(instancetype)buttonWithImageNormal:(UIImage *)image
                         target:(id)target
                         action:(SEL)action
                         onView:(UIView *)view;
// 纯图片（正常和选中）
+(instancetype)buttonWithImageNormal:(UIImage *)normalImage
                              select:(UIImage *)selectImage
                              target:(id)target
                              action:(SEL)action
                              onView:(UIView *)view;

// 纯图片（正常和不可点击图片）
+(instancetype)buttonWithImageNormal:(UIImage *)normalImage
                             disable:(UIImage *)disableImage
                              target:(id)target
                              action:(SEL)action
                              onView:(UIView *)view;

//在右上角显示一个小红点
- (void)showRedPointWithRadius:(CGFloat)radius Color:(UIColor *)bgColor Position:(CGPoint)position;


//让小红点消失
- (void)dismissRedPoint;
@end
