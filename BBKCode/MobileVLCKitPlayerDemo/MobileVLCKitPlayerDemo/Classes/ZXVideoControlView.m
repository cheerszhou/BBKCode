//
//  ZXVideoControlView.m
//  MobileVLCKitPlayerDemo
//
//  Created by zxx_mbp on 2017/5/9.
//  Copyright © 2017年 zxx_mbp. All rights reserved.
//

#import "ZXVideoControlView.h"

@interface ZXVideoControlView ()
@property (nonatomic, strong) UIPanGestureRecognizer *pan;
@end

@implementation ZXVideoControlView

#pragma mark - Life Cycle
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.topBar.frame               = CGRectMake(CGRectGetMinX(self.bounds), CGRectGetMinY(self.bounds), CGRectGetWidth(self.bounds), ZXVideoControlBarHeight);
    
    self.closeButton.frame          = CGRectMake(CGRectGetWidth(self.topBar.bounds)-CGRectGetWidth(self.closeButton.bounds), CGRectGetMinX(self.topBar.bounds), CGRectGetWidth(self.closeButton.bounds), CGRectGetWidth(self.closeButton.bounds));
    
    self.bottomBar.frame            = CGRectMake(CGRectGetMinX(self.bounds), CGRectGetHeight(self.bounds)-ZXVideoControlBarHeight, CGRectGetHeight(self.bounds), ZXVideoControlBarHeight);
    
    self.progressSlider.frame       = CGRectMake(0,0, CGRectGetWidth(self.bounds), ZXVideoControlSliderHeight);
    
    self.playButton.frame           = CGRectMake(CGRectGetMinX(self.bottomBar.bounds), CGRectGetHeight(self.bottomBar.bounds)/2-CGRectGetHeight(self.playButton.bounds)/2+CGRectGetHeight(self.progressSlider.frame)*0.6, CGRectGetWidth(self.playButton.bounds), CGRectGetHeight(self.playButton.bounds));
    
    self.pauseButton.frame          = self.playButton.frame;
    
    self.fullScreenButton.frame     = CGRectMake(CGRectGetWidth(self.bottomBar.bounds)-CGRectGetWidth(self.fullScreenButton.bounds)-5, self.playButton.frame.origin.y, CGRectGetWidth(self.fullScreenButton.bounds), CGRectGetHeight(self.fullScreenButton.bounds));
    
    self.shrinkScreenButton.frame   = self.fullScreenButton.frame;
    
    self.indicatorView.center       = CGPointMake(CGRectGetWidth(self.bounds)/2, CGRectGetHeight(self.bounds)/2);
    
    self.timeLabel.frame            = CGRectMake(CGRectGetMaxX(self.playButton.frame), self.playButton.frame.origin.y, CGRectGetWidth(self.bottomBar.bounds), CGRectGetHeight(self.timeLabel.bounds));
    
    self.alertLabel.center          = CGPointMake(CGRectGetWidth(self.bounds)/2, CGRectGetHeight(self.bounds)/2);
    
}

//- (void)didMoveToSuperview {
//    [super didMoveToSuperview];
//}

#pragma mark - Public Method
- (void)animateHide {
    [UIView animateWithDuration:ZXVideoControlAnimationTimeinterval animations:^{
        self.topBar.alpha = 0;
        self.bottomBar.alpha = 0;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)animateShow {
    [UIView animateWithDuration:ZXVideoControlAnimationTimeinterval
                     animations:^{
                         self.topBar.alpha = 1;
                         self.bottomBar.alpha = 1;
                     } completion:^(BOOL finished) {
                         [self autoFadeOutControlBar];
                     }];
}

- (void)autoFadeOutControlBar {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(animateHide) object:nil];
    [self performSelector:@selector(animateHide) withObject:nil afterDelay:ZXVideoControlBarAutoFadeOutTimeInterval];
}

- (void)cancelAutoFadeOutControlBarv{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(animateHide) object:nil];
}

#pragma mark - Private Method
- (void)setupView {
    self.backgroundColor = [UIColor clearColor];
    
    [self.layer addSublayer:self.bgLayer];
    [self addSubview:self.topBar];
    [self addSubview:self.indicatorView];
    [self addSubview:self.bottomBar];
    [self addSubview:self.alertLabel];
    
    
    [self.topBar addSubview:self.closeButton];
    [self.bottomBar addSubview:self.playButton];
    [self.bottomBar addSubview:self.pauseButton];
    [self.bottomBar addSubview:self.fullScreenButton];
    [self.bottomBar addSubview:self.shrinkScreenButton];
    [self.bottomBar addSubview:self.progressSlider];
    [self.bottomBar addSubview:self.timeLabel];
    
    self.pauseButton.hidden = YES;
    self.shrinkScreenButton.hidden = YES;
    
    [self addGestureRecognizer:self.pan];
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)]];
    
}

- (void)responeTapImmediately {
    self.bottomBar.alpha == 0?[self animateShow]:[self animateHide];
}

#pragma mark - Override
#pragma mark - Touch Event
- (void)tapAction:(UITapGestureRecognizer*)tap {
    
}

- (void)pandAction:(UIPanGestureRecognizer*)pan {
    CGPoint localPoint = [pan locationInView:self];
    CGPoint speedDir = [pan velocityInView:self];
    
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
            self.alertLabel.alpha = ZXVideoControlAlertAlpha;
            break;
        case UIGestureRecognizerStateChanged:{
            //判断方向
            if (ABS(speedDir.x)>ABS(speedDir.y)) {
                if ([pan translationInView:self].x > 0) {
                    if ([_delegate respondsToSelector:@selector(controlViewFingerMoveRight)]) {
                        [self.delegate controlViewFingerMoveRight];
                    }
                    [self.alertLabel configureWithTime:[self.timeLabel.text substringFromIndex:5] isLeft:NO];
                }else{
                    if ([_delegate respondsToSelector:@selector(controlViewFingerMoveRight)]) {
                        [self.delegate controlViewFingerMoveLeft];
                    }
                    [self.alertLabel configureWithTime:[self.timeLabel.text substringFromIndex:5] isLeft:YES];
                }
            }else {
                if (localPoint.x > self.bounds.size.width / 2) {
                    //改变音量
                    if ([pan translationInView:self].y>0) {
                        self.volumeSlider.value -= 0.03;
                    }else {
                        self.volumeSlider.value += 0.03;
                    }
                    [self.alertLabel configureWithVolume:self.volumeSlider.value];
                }else{
                    //改变显示亮度
                    if ([pan translationInView:self].y > 0) {
                        [UIScreen mainScreen].brightness -= 0.01;
                    }else{
                        [UIScreen mainScreen].brightness += 0.01;
                    }
                    [self.alertLabel configureWithLight];
                }
            }
        }
            break;
            
        case UIGestureRecognizerStateEnded: {
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIView animateWithDuration:1 animations:^{
                    self.alertLabel.alpha = 0;
                }];
            });

        }
            break;
            
        default:
            break;
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch* touch = [touches anyObject];
    if (touch.tapCount>0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self responeTapImmediately];
        });
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self responeTapImmediately];
}

#pragma mark - Property 
- (ZXVideoHUDView *)indicatorView {
    if (!_indicatorView) {
        _indicatorView = [[ZXVideoHUDView alloc]init];
        _indicatorView.bounds = CGRectMake(0, 0, 100, 100);
    }
    return _indicatorView;
}

- (UIView *)topBar {
    if (!_topBar) {
        _topBar = [UIView new];
        _topBar.backgroundColor = [UIColor clearColor];
    }
    return _topBar;
}

- (UIView *)bottomBar {
    if (!_bottomBar) {
        _bottomBar = [[UIView alloc]init];
        _bottomBar.backgroundColor = ZXRGB(27, 27, 27);
    }
    return _bottomBar;
}

- (UIButton *)playButton {
    if (!_playButton) {
        _playButton = [[UIButton alloc]init];
        [_playButton setImage:[UIImage imageNamed:@"Play Icon"] forState:UIControlStateNormal];
        _playButton.bounds = CGRectMake(0, 0, ZXVideoControlBarHeight, ZXVideoControlBarHeight);
    }
    return _playButton;
}

- (UIButton *)pauseButton {
    if (!_pauseButton) {
        _pauseButton = [[UIButton alloc]init];
        [_playButton setImage:[UIImage imageNamed:@"Pause Icon"] forState:UIControlStateNormal];
        _playButton.bounds = CGRectMake(0, 0, ZXVideoControlBarHeight, ZXVideoControlBarHeight);

    }
    return _pauseButton;
}

- (UIButton *)fullScreenButton {
    if (!_fullScreenButton) {
        _fullScreenButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_shrinkScreenButton setImage:[UIImage imageNamed:@"Full Screen Icon"] forState:UIControlStateNormal];
        _shrinkScreenButton.bounds = CGRectMake(0, 0, ZXVideoControlBarHeight, ZXVideoControlBarHeight);
    }
    return _fullScreenButton;
}

- (UIButton *)shrinkScreenButton {
    if (!_shrinkScreenButton) {
        _shrinkScreenButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_shrinkScreenButton setImage:[UIImage imageNamed:@"Min. Icon"] forState:UIControlStateNormal];
        _shrinkScreenButton.bounds = CGRectMake(0, 0, ZXVideoControlBarHeight, ZXVideoControlBarHeight);
    }
    return _shrinkScreenButton;
}

- (ZXProgressSlider *)progressSlider {
    if (!_progressSlider) {
        _progressSlider = [[ZXProgressSlider alloc]init];
        [_progressSlider  setThumbImage:[UIImage imageNamed:@"Player Control Nob"] forState:UIControlStateNormal];
        [_progressSlider setMinimumTrackTintColor:ZXRGB(239, 71, 94)];
        [_progressSlider setMaximumTrackTintColor:ZXRGB(157, 157, 157)];
        [_progressSlider setBackgroundColor:[UIColor clearColor]];
        _progressSlider.value = 0.f;
        _progressSlider.continuous = YES;
    }
    return _progressSlider;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setImage:[UIImage imageNamed:@"Player close"] forState:UIControlStateNormal];
        _closeButton.bounds = CGRectMake(0, 0, ZXVideoControlBarHeight, ZXVideoControlBarHeight);
    }
    return _closeButton;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [UILabel new];
        _timeLabel.backgroundColor = [UIColor clearColor];
        _timeLabel.font = [UIFont systemFontOfSize:ZXVideoControlTimeLabelFontSize];
        _timeLabel.textColor = [UIColor lightGrayColor];
        _timeLabel.textAlignment = NSTextAlignmentLeft;
        _timeLabel.bounds = CGRectMake(0, 0, ZXVideoControlBarHeight, ZXVideoControlBarHeight);
    }
    return _timeLabel;
}
- (CALayer *)bgLayer {
    if (!_bgLayer) {
        _bgLayer = [CALayer layer];
        _bgLayer.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Video Bg"]].CGColor;
        _bgLayer.bounds = self.frame;
        _bgLayer.position = CGPointMake(CGRectGetWidth(self.bounds)/2, CGRectGetHeight(self.bounds)/2);
    }
    return _bgLayer;
}

- (MPVolumeView *)volumeView {
    if (!_volumeView) {
        _volumeView = [[MPVolumeView alloc]init];
    }
    return _volumeView;
}

- (UISlider *)volumeSlider {
    if (!_volumeSlider) {
        for (UIControl* view in self.volumeView.subviews) {
            if ([view.superclass isSubclassOfClass:[UISlider class]]) {
                _volumeSlider = (UISlider*)view;
            }
        }
    }
    return _volumeSlider;
}

- (UILabel *)alertLabel {
    if (!_alertLabel) {
        _alertLabel = [UILabel new];
        _alertLabel.bounds = CGRectMake(0, 0, 100, 40);
        _alertLabel.textAlignment = NSTextAlignmentCenter;
        _alertLabel.backgroundColor = [UIColor colorWithWhite:0.000 alpha:ZXVideoControlAlertAlpha];
        _alertLabel.textColor = [UIColor whiteColor];
        _alertLabel.layer.cornerRadius = 10;
        _alertLabel.layer.masksToBounds = YES;
        _alertLabel.alpha = 0;
    }
    return _alertLabel;
}

- (UIPanGestureRecognizer *)pan {
    if (!_pan) {
        _pan = [[UIPanGestureRecognizer alloc] initWithTarget:self  action:@selector(pandAction:)];
    }
    return _pan;
}
@end

@implementation ZXProgressSlider

- (CGRect)trackRectForBounds:(CGRect)bounds {
    return CGRectMake(0, self.bounds.size.height*0.8, self.bounds.size.width, ZXProgressWidth);
}

@end

@implementation UILabel (Configureable)

- (void)configureWithTime:(NSString *)time isLeft:(BOOL)left {
    left?[self setText:[NSString stringWithFormat:@"<<%@",time]]:[self setText:[NSString stringWithFormat:@">>%@",time]];
}

- (void)configureWithLight {
    self.text = [NSString stringWithFormat:@"亮度:%d.00",(int)([UIScreen mainScreen].brightness*100)];
}

- (void)configureWithVolume:(float)volume {
    self.text = [NSString stringWithFormat:@"音量：%d%%",(int)(volume*100)];
}

@end
