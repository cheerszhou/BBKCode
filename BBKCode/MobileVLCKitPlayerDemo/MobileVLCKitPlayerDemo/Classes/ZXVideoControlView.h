//
//  ZXVideoControlView.h
//  MobileVLCKitPlayerDemo
//
//  Created by zxx_mbp on 2017/5/9.
//  Copyright © 2017年 zxx_mbp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZXVideoHUDView.h"
#import <MediaPlayer/MediaPlayer.h>
#import "ZXVideoConst.h"

@class ZXProgressSlider;

@protocol ZXVideoControlViewDelegate <NSObject>

@optional
- (void)controlViewFingerMoveUp;
- (void)controlViewFingerMoveDown;
- (void)controlViewFingerMoveLeft;
- (void)controlViewFingerMoveRight;


@end

@interface ZXVideoControlView : UIView

@property (nonatomic, weak) id<ZXVideoControlViewDelegate> delegate;

@property (nonatomic, strong) UIView *topBar;
@property (nonatomic, strong) UIView *bottomBar;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UIButton *pauseButton;
@property (nonatomic, strong) UIButton *fullScreenButton;
@property (nonatomic, strong) UIButton *shrinkScreenButton;
@property (nonatomic, strong) ZXProgressSlider *progressSlider;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) ZXVideoHUDView *indicatorView;
@property (nonatomic, strong) CALayer *bgLayer;
@property (nonatomic, strong) UISlider *volumeSlider;
@property (nonatomic, strong) MPVolumeView *volumeView;
@property (nonatomic, strong) UILabel *alertLabel;


- (void)animateHide;
- (void)animateShow;
- (void)autoFadeOutControlBar;
- (void)cancelAutoFadeOutControlBar;

@end


@interface ZXProgressSlider : UISlider

@end

@interface UILabel (Configureable)

- (void)configureWithTime:(NSString*)time isLeft:(BOOL)left;
- (void)configureWithLight;
- (void)configureWithVolume:(float)volume;

@end
