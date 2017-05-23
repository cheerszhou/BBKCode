//
//  CreateViewController.m
//  QRDemo
//
//  Created by zxx_mbp on 2017/5/22.
//  Copyright © 2017年 zxx_mbp. All rights reserved.
//

#import "CreateViewController.h"
#import "UIViewController+Message.h"
#define kRGBColor(r,g,b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]
#define kRandomColor kRGBColor(arc4random_uniform(256),arc4random_uniform(256),arc4random_uniform(256))

#define qrImageSize CGSizeMake(300,300)
@interface CreateViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation CreateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.imageView.image = [self createQRImageWithString:@"zxx" size:qrImageSize];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITextFiledDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self createButtonDidClick:nil];
    return YES;
}

- (IBAction)createButtonDidClick:(id)sender {;
    [self.textField resignFirstResponder];
    if (self.textField.text.length>0) {
        self.imageView.image = [self createQRImageWithString:self.textField.text size:qrImageSize];
    }else{
        [self showAlertWithTitle:@"提示" message:@"请输入文字" handler:nil];
    }
}
- (IBAction)changeColorDidClick:(id)sender {
    UIImage* image = [self createQRImageWithString:self.textField.text size:qrImageSize];
    self.imageView.image = [self changeColorForQRImage:image backgroundColor:kRandomColor foregroundColor:kRandomColor];
}
- (IBAction)addSmallImageDidClick:(id)sender {
    self.imageView.image = [self addSmallImageForQRImage:self.imageView.image];
}


//生成指定大小的黑白二维码
- (UIImage*)createQRImageWithString:(NSString*)string size:(CGSize)size {
    NSData* stringData = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    CIFilter* qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    [qrFilter setValue:@"M" forKey:@"inputCorrectionLevel"];
    
    CIImage* qrImage = qrFilter.outputImage;
    //放大并绘制二维码（上面生成的二维码很小，需要放大)
    CGImageRef cgImage = [[CIContext contextWithOptions:nil] createCGImage:qrImage fromRect:qrImage.extent];
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(context, kCGInterpolationNone);
    //翻转下一张图片，不然生成的QRCode就是上下颠倒的
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextDrawImage(context, CGContextGetClipBoundingBox(context), cgImage);
    UIImage* codeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CGImageRelease(cgImage);
    
    return codeImage;
}

//为二维码改变颜色
- (UIImage*)changeColorForQRImage:(UIImage*)image backgroundColor:(UIColor*)bgColor foregroundColor:(UIColor*)fgColor {
    CIFilter* colorFilter = [CIFilter filterWithName:@"CIFalseColor" keysAndValues:
                             @"inputImage",[CIImage imageWithCGImage:image.CGImage],
                             @"inputColor0",[CIColor colorWithCGColor:fgColor.CGColor],
                             @"inputColor1",[CIColor colorWithCGColor:bgColor.CGColor],
                             nil];
    return [UIImage imageWithCIImage:colorFilter.outputImage];
}


//在二维码中心加一个小图
- (UIImage*)addSmallImageForQRImage:(UIImage*)qrImage {
    UIGraphicsBeginImageContext(qrImage.size);
    [qrImage drawInRect:CGRectMake(0, 0, qrImage.size.width, qrImage.size.height)];
    UIImage* image = [UIImage imageNamed:@"small"];
    
    CGFloat imageW = 50.f;
    CGFloat imageX = (qrImage.size.width-imageW)/2.0;
    CGFloat imageY = (qrImage.size.height-imageW)/2.0;
    
    [image drawInRect:CGRectMake(imageX, imageY, imageW, imageW)];
    
    UIImage * result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}


@end
