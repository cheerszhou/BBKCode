//
//  ViewController.m
//  核心动画CoreAnimation之CALayer
//
//  Created by zxx_mbp on 2017/5/23.
//  Copyright © 2017年 zxx_mbp. All rights reserved.
//

#import "ViewController.h"
#import "SimpleAnimeVC.h"
#import "UIViewAnimationTestVC.h"
#import "CAPauseTestVC.h"
#import "PMLayerTestVC.h"
#import "TimeFuncTestVC.h"
#import "MaskLayerTestVC.h"
#import "EmitterLayerTestVC.h"
#import "LayerTransformViewController.h"

NSString * cellIdentifier = @"cell_identifier";

@interface ViewController ()
@property (nonatomic, strong) NSArray<NSString*> *sources;
@property (nonatomic, strong) CAEmitterLayer *emitterLayer;
@property (nonatomic, strong) UIImageView *backImg;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.sources = @[@"简单动画",@"UIView动画",@"动画的暂停和继续",@"modelLayer与presentationLayer",@"模拟时间函数插值",@"蒙版实现刮刮卡效果",@"粒子效果",@"LayerAndTransform"];
    self.title = @"CoreAnimationDemo";
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifier];
    self.tableView.rowHeight = 50;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    [self makeBlurBack];
    [self initEmitter];
    [self makeSnow];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.sources.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    if (indexPath.row>=0&&indexPath.row<_sources.count) {
        cell.textLabel.text = _sources[indexPath.row];
        cell.backgroundColor = [UIColor colorWithWhite:1 alpha:0.4];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIViewController* vc = nil;
    
    if (indexPath.row == 0) {
        vc = [[SimpleAnimeVC alloc]init];
    }else if(indexPath.row == 1) {
        vc = [UIViewAnimationTestVC new];
    }else if (indexPath.row == 2) {
        vc = [CAPauseTestVC new];
    }else if (indexPath.row == 3) {
        vc = [PMLayerTestVC new];
    }else if (indexPath.row == 4) {
        vc = [TimeFuncTestVC new];
    }else if (indexPath.row == 5) {
        vc = [MaskLayerTestVC new];
    }else if(indexPath.row == 6) {
        vc = [EmitterLayerTestVC new];
    }else if (indexPath.row == 7) {
        vc = [LayerTransformViewController new];
    }
    
    if (vc) {
        vc.title = _sources[indexPath.row];
        [self.navigationController pushViewController:vc animated:YES];
    }
}


#pragma mark - decorate view
- (void)makeBlurBack {
    self.backImg = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"bg1"]];
    self.tableView.backgroundColor = [UIColor cyanColor];
    self.tableView.backgroundView = self.backImg;
    
    UIBlurEffect * blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView* blurView = [[UIVisualEffectView alloc]initWithEffect:blurEffect];
    blurView.alpha = 0.93;
    blurView.frame = self.tableView.frame;
    [self.backImg addSubview:blurView];
    
}



- (void)makeSnow
{
    CAEmitterCell *snowCell = [CAEmitterCell emitterCell];
    snowCell.contents = (__bridge id _Nullable)([UIImage imageNamed:@"snow"].CGImage);
    snowCell.birthRate = 5;
    snowCell.lifetime = 20;
    snowCell.velocity = 100;
    snowCell.velocityRange = 50;
    snowCell.emissionLongitude = M_PI_2;
    snowCell.emissionRange = M_PI_2;
    snowCell.scaleRange = 0.5;
    
    _emitterLayer.emitterCells = @[snowCell];
}

- (void)initEmitter
{
    _emitterLayer = [CAEmitterLayer layer];
    _emitterLayer.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    _emitterLayer.renderMode = kCAEmitterLayerAdditive;
    _emitterLayer.emitterPosition = CGPointMake(self.view.frame.size.width/2, -35);
    _emitterLayer.emitterSize = CGSizeMake(self.view.frame.size.width, 20);
    [self.view.layer addSublayer:_emitterLayer];
}

@end
