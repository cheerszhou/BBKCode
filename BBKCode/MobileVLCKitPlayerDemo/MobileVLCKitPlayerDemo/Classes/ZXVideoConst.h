//
//  ZXVideoConst.h
//  MobileVLCKitPlayerDemo
//
//  Created by zxx_mbp on 2017/5/9.
//  Copyright © 2017年 zxx_mbp. All rights reserved.
//

#ifndef ZXVideoConst_h
#define ZXVideoConst_h


#define kMediaLength        self.player.media.length
#define kHUDCenter          CGPointMake(CGRectGetWidth(self.bounds)/2,CGRectGetHeight(self.bounds)/2)
#define ZXRGB(r,g,b)        [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]
#define kZXSCREEN_BOUNDS    [[UIScreen mainScreen] bounds]

static const NSTimeInterval kHUDCycleTimeInterval = 0.8f;
static const CGFloat        KHUDCycleLineWidth = 3.0f;

static const CGFloat        ZXProgressWidth = 3.0f;
static const CGFloat        ZXVideoControlBarHeight = 40.0f;
static const CGFloat        ZXVideoControlSliderHeight = 10.0f;
static const CGFloat        ZXVideoControlAnimationTimeinterval = 0.3f;
static const CGFloat        ZXVideoControlTimeLabelFontSize = 10.0f;
static const CGFloat        ZXVideoControlBarAutoFadeOutTimeInterval = 4.0f;
static const CGFloat        ZXVideoControlCorrectValue = 3.f;
static const CGFloat        ZXVideoControlAlertAlpha = 0.75f;


#endif /* ZXVideoConst_h */
