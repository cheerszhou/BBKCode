//
//  ViewController.m
//  CAReplicatorLayer-图层复制
//
//  Created by zxx_mbp on 2017/7/17.
//  Copyright © 2017年 zxx_mbp. All rights reserved.
//

#import "ViewController.h"
#import "ReflectionView.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet ReflectionView *reflectionView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor grayColor];
    // create a replicator layer and add it to our view
    CAReplicatorLayer * replicator = [CAReplicatorLayer layer];
    replicator.frame = self.view.bounds;
    [self.view.layer addSublayer:replicator];
    
    //configure the replicator
    replicator.instanceCount = 10;
    
    //apply a transform for each instance
    CATransform3D transform = CATransform3DIdentity;
    transform = CATransform3DTranslate(transform, 100, 0, 0);
    transform = CATransform3DRotate(transform, M_PI/5, 0, 0, 1);
    replicator.instanceTransform = transform;
    
    //apply a color shift for each instance
    replicator.instanceBlueOffset = -0.1;
    replicator.instanceGreenOffset = -0.1;
    
    //create a sublayer and place it inside the replicator
    CALayer *layer = [CALayer layer];
    layer.frame = CGRectMake(100.f, 100.f, 100.f, 100.f);
    layer.backgroundColor = [UIColor whiteColor].CGColor;
    
    [replicator addSublayer:layer];
    
    self.reflectionView.layer.contents = (__bridge id _Nullable)([UIImage imageNamed:@"clock_dial"].CGImage);
}


@end
