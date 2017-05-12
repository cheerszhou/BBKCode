//
//  RemoteViewController.m
//  MobileVLCKitPlayerDemo
//
//  Created by zxx_mbp on 2017/5/9.
//  Copyright © 2017年 zxx_mbp. All rights reserved.
//

#import "RemoteViewController.h"
#import "ZXVLCPlayer.h"

@interface RemoteViewController ()
@property (weak, nonatomic) IBOutlet UIButton *remotePlayerBtn;

@end

@implementation RemoteViewController

- (void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        
        [self prefersStatusBarHidden];
        
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
        
    }
}

- (IBAction)remotePlay:(id)sender {
    
    ZXVLCPlayer *player = [[ZXVLCPlayer alloc] init];
    
    player.bounds = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.width / 16 * 9);
    player.center = self.view.center;
    player.mediaURL = [NSURL URLWithString:@"http://202.198.176.113/video002/2015/mlrs.rmvb"];
    
    [player showInView:self.view.window];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}


@end
