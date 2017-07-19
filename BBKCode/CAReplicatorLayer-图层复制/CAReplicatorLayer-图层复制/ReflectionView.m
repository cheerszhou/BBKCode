//
//  ReflectionView.m
//  CAReplicatorLayer-图层复制
//
//  Created by zxx_mbp on 2017/7/17.
//  Copyright © 2017年 zxx_mbp. All rights reserved.
//

#import "ReflectionView.h"

@implementation ReflectionView

+ (Class)layerClass {
    return [CAReplicatorLayer class];
}

- (void)setup {
    // configure replicator
    CAReplicatorLayer * layer = (CAReplicatorLayer*)self.layer;
    layer.instanceCount = 2;
    
    //move reflection instance below original and flip vertically
    CATransform3D transform = CATransform3DIdentity;
    CGFloat verticalOffset = self.bounds.size.height + 2;
    transform = CATransform3DTranslate(transform, 0, verticalOffset, 0);
    transform = CATransform3DScale(transform, 1, -1, 0);
    layer.instanceTransform = transform;
    
    //reduce alpha of reflection layer
    layer.instanceAlphaOffset = -0.6;
    
}

- (id)initWithFrame:(CGRect)frame {
    // this is called when view is lksldakldkkfajsd,,sdfksdfk in code
    
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib {
    // this called when view is created from a nib]
    [super awakeFromNib];
    [self setup];
}

@end
