//
//  ZXMainViewController.m
//  无限循环的图片浏览器
//
//  Created by zxx_mbp on 2017/7/26.
//  Copyright © 2017年 zxx_mbp. All rights reserved.
//

#import "ZXMainViewController.h"
#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)
#define IMAGEVIEW_COUNT 3

@interface ZXMainViewController () <UIScrollViewDelegate>{
    UIScrollView * _scrollView;
    UIImageView * _leftImageView;
    UIImageView * _centerImageView;
    UIImageView * _rightImageView;
    UIPageControl * _pageControl;
    UILabel * _label;
    NSMutableDictionary * _imageData;//图片数据
    int _currentImageIndex;//当前图片索引
    int _imageCount;//图片总数
}

@end

@implementation ZXMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //加载数据
    [self loadImageData];
    //添加滚动控件
    [self addScrollView];
    //添加图片控件
    [self addImageViews];
    //添加分页控件
    [self addPageControl];
    //添加图片信息描述控件
    [self addLabel];
    //加载默认图片
    [self setDefaultImage];
}

#pragma mark 加载图片数据
- (void)loadImageData {
    //读取程序包路径中的资源文件
    NSString *path = [[NSBundle mainBundle] pathForResource:@"imageInfo.plist" ofType:nil];
    _imageData = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    _imageCount = (int)_imageData.count;
}

- (void)addScrollView {
    _scrollView = [[UIScrollView alloc]initWithFrame:[self.view bounds]];
    [self.view addSubview:_scrollView];
    
    //设置代理
    _scrollView.delegate = self;
    //设置contentSize
    _scrollView.contentSize = CGSizeMake(IMAGEVIEW_COUNT*SCREEN_WIDTH, SCREEN_HEIGHT);
    //设置当前显示的位置中间图片
    _scrollView.contentOffset = CGPointMake(SCREEN_WIDTH, 0);
    //设置分页
    _scrollView.pagingEnabled = YES;
    //去掉滚动条
    _scrollView.showsHorizontalScrollIndicator = NO;
    
}

- (void)addImageViews {
    _leftImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    _leftImageView.contentMode = UIViewContentModeScaleAspectFit;
    [_scrollView addSubview:_leftImageView];
    
    _centerImageView = [[UIImageView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    _centerImageView.contentMode = UIViewContentModeScaleAspectFit;
    [_scrollView addSubview:_centerImageView];
    
    _rightImageView = [[UIImageView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH * 2, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    _rightImageView.contentMode = UIViewContentModeScaleAspectFit;
    [_scrollView addSubview:_rightImageView];
    
    
}

- (void)addPageControl {
    _pageControl = [[UIPageControl alloc]init];
    //注意此方法可以根据页面数返回UIPageControl合适的大小
    CGSize size = [_pageControl sizeForNumberOfPages:_imageCount];
    _pageControl.bounds = CGRectMake(0, 0, size.width, size.height);
    _pageControl.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT - 100);
    //设置颜色
    _pageControl.pageIndicatorTintColor = [UIColor colorWithRed:193/255.0 green:249/255.0 blue:219/255.0 alpha:1.0];
    _pageControl.currentPageIndicatorTintColor = [UIColor colorWithRed:0 green:150/255.0 blue:1 alpha:1.0];
    //设置总页数
    _pageControl.numberOfPages = _imageCount;
    [self.view addSubview:_pageControl];
}

- (void)addLabel {
    _label = [[UILabel alloc]initWithFrame:CGRectMake(0, 10, SCREEN_WIDTH, 30)];
    _label.textAlignment = NSTextAlignmentCenter;
    _label.textColor = [UIColor colorWithRed:0 green:150/255.0 blue:1 alpha:1];
    [self.view addSubview:_label];
}

- (void)setDefaultImage {
    //加载默认图片
    _leftImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%i",_imageCount - 1 + 664]];
    _centerImageView.image = [UIImage imageNamed:@"664"];
    _rightImageView.image = [UIImage imageNamed:@"665"];
    _currentImageIndex = 0;
    //设置当前页
    _pageControl.currentPage = _currentImageIndex;
    NSString *imageName = [NSString stringWithFormat:@"%i",_currentImageIndex];
    _label.text = _imageData[imageName];
}


#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    //重新加载图片
    [self reloadImage];
    //移动到中间
    [scrollView setContentOffset:CGPointMake(SCREEN_WIDTH, 0) animated:NO];
    //设置分页
    _pageControl.currentPage = _currentImageIndex%_imageCount;
    //设置描述
    NSString *imageNmae = [NSString stringWithFormat:@"%i",_currentImageIndex];
    _label.text = _imageData[imageNmae];
    
}

- (void)reloadImage {
    int leftImageIndex = 0 , rightImageIndex = 0;
    CGPoint offset = [_scrollView contentOffset];
    if (offset.x > SCREEN_WIDTH) {
        _currentImageIndex = 664 + (_currentImageIndex + 1)%_imageCount;
    }else if(offset.x < SCREEN_WIDTH) {
        _currentImageIndex = 664 + (_currentImageIndex + _imageCount - 1)%_imageCount;
    }
    _centerImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%i",_currentImageIndex]];
    
    //重新设置左右图片
    leftImageIndex = 664 + (_currentImageIndex + _imageCount - 1 )%_imageCount;
    rightImageIndex = 664 + (_currentImageIndex + 1)%_imageCount;
    _leftImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%i",leftImageIndex]];
    _rightImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%i",rightImageIndex]];
    leftImageIndex = 655 + (_currentImageIndex - _imageCount + 3)%_imageCount;
}
@end
