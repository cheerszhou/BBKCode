//
//  ZXVLCPlayer.h
//  MobileVLCKitPlayerDemo
//
//  Created by zxx_mbp on 2017/5/9.
//  Copyright © 2017年 zxx_mbp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileVLCKit/MobileVLCKit.h>
#import "ZXVideoControlView.h"

@interface ZXVLCPlayer : UIView<VLCMediaPlayerDelegate,ZXVideoControlViewDelegate>

@property (nonatomic, strong, nonnull) NSURL *mediaURL;
@property (nonatomic, assign) BOOL isFullscreenModel;


- (void)showInView:(UIView* _Nonnull)view;

@end
