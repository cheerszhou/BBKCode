//
//  LocalViewController.m
//  MobileVLCKitPlayerDemo
//
//  Created by zxx_mbp on 2017/5/9.
//  Copyright © 2017年 zxx_mbp. All rights reserved.
//

#import "LocalViewController.h"
#import "ZXVLCPlayer.h"

@interface LocalViewController()
@property (weak, nonatomic) IBOutlet UIButton *localPlayerBtn;

@end

@implementation LocalViewController
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        [self prefersStatusBarHidden];
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    }
}
- (IBAction)playLocalVideo:(id)sender {
    ZXVLCPlayer* player = [[ZXVLCPlayer alloc]init];
    player.bounds = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.width/16 * 9);
    player.center = self.view.center;
//    player.mediaURL = [[NSBundle mainBundle] URLForResource:@"02" withExtension:@"mov"];
    player.mediaURL = [NSURL fileURLWithPath:@"/Users/zxx_mbp/Downloads/niverse.mkv"];
    [player showInView:self.view.window];
    
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}


@end
