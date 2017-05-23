//
//  ViewController.m
//  iOS小技巧总结
//
//  Created by zxx_mbp on 2017/5/13.
//  Copyright © 2017年 zxx_mbp. All rights reserved.
//

#import "ViewController.h"
#import "UIImage+ColorAtPixel.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UIView *colorView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSString* myString = @"myString";
    NSString* reverseString = [self reverseWordsInString:myString];
    NSLog(@"reverseString:%@",reverseString);
    
    //7.禁止锁屏
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    //8.字符串按多个符号分割
    {
        NSString *str = @"abc,ver.yyuu";
        NSCharacterSet * set = [NSCharacterSet characterSetWithCharactersInString:@",."];
        NSLog(@"字符串按多个符号分割:%@",[str componentsSeparatedByCharactersInSet:set]);
    }
    //9.iOS跳转到App Store下载应用评分
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=APPID"]];
    
    [self transform:@"iOS获取汉子拼音"];
    
    
    [self setStatusBarBackgroundColor:[UIColor blueColor]];
    
    //12.判断当前ViewController是push还是present得方式显示的
    {
        NSArray *viewControllers = self.navigationController.viewControllers;
        if (viewControllers.count>1) {
            if ([viewControllers objectAtIndex:viewControllers.count - 1]==self) {
                //push方式
                [self.navigationController popViewControllerAnimated:YES];
            }
        }else{
            //present
            [self dismissViewControllerAnimated:YES completion:nil];
        }
       
    }
    
    NSLog(@"Launch ImageName:%@",[self getLaunchImageName]);
    
}




//15.判断view是不是指定视图的子视图
- (BOOL)isChildOfView:(UIView*)view {
    BOOL isView = [self.view isDescendantOfView:view];
    return isView;
}


//13.获取实际使用的LaunchImage
- (NSString*)getLaunchImageName {
    CGSize viewSize = self.view.window.bounds.size;
    //横屏
    NSString* viewOrientation = @"Portrait";
    NSString* launchImageName = nil;
    NSArray* imagesDict = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"UILaunchImages"];
    for (NSDictionary* dict  in imagesDict) {
        CGSize imageSize = CGSizeFromString(dict[@"UILaunchImageSize"]);
        if (CGSizeEqualToSize(imageSize, viewSize)&&[viewOrientation isEqualToString:dict[@"UILaunchImageOrientation"]]) {
            launchImageName = dict[@"UILaunchImageName"];
        }
    }
    return launchImageName;
}

//11.手动改变iOS状态栏的颜色
- (void)setStatusBarBackgroundColor:(UIColor*)color {
    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
    if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
        statusBar.backgroundColor = color;
    }
}
//10.iOS获取汉子拼音
- (NSString*)transform:(NSString*)chinese {
    //将NSString装换成NSMutableString
    NSMutableString *pinyin = [chinese mutableCopy];
    //将汉字转换为拼音（带音标）
    CFStringTransform((__bridge CFMutableStringRef)pinyin, NULL, kCFStringTransformMandarinLatin, NO);
    NSLog(@"%@的拼音（带音标）：%@",chinese,pinyin);
    //去掉拼音的音标
    CFStringTransform((__bridge CFMutableStringRef)pinyin, NULL, kCFStringTransformStripCombiningMarks, NO);
    NSLog(@"%@的拼音（带音标）：%@",chinese,pinyin);
    return pinyin;
}

//6.字符串反转
//第一种
- (NSString*)reverseWordsInString:(NSString*)str {
    NSMutableString* newString = [[NSMutableString alloc]initWithCapacity:str.length];
    for (NSInteger i = str.length - 1; i>=0; i--) {
        unichar ch = [str characterAtIndex:i];
        [newString appendFormat:@"%c",ch];
    }
    return newString;
}

//第二种
- (NSString*)reverseWordsInString2:(NSString*)str {
    NSMutableString* reverseString = [NSMutableString stringWithCapacity:str.length];
    [str enumerateSubstringsInRange:NSMakeRange(0, str.length) options:NSStringEnumerationReverse|NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
        [reverseString appendString:substring];
    }];
    return reverseString;
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint currentPoint = [[touches anyObject] locationInView:self.image];
    UIColor *color = [self.image.image colorAtPixel:currentPoint];
    NSLog(@"此处的color：%@",color);
    self.colorView.backgroundColor = color;
}



@end
