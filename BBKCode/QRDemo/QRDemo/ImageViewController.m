//
//  ImageViewController.m
//  QRDemo
//
//  Created by zxx_mbp on 2017/5/22.
//  Copyright © 2017年 zxx_mbp. All rights reserved.
//

#import "ImageViewController.h"
#import "UIViewController+Message.h"

@interface ImageViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *qrImageView;

@end

@implementation ImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"从相册中选择" style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonItemClick:)];
    
}


#pragma mark - 从相册中选择
- (void)rightBarButtonItemClick:(UIBarButtonItem*) sender{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIImagePickerController *imagePickController = [[UIImagePickerController alloc]init];
        imagePickController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePickController.delegate = self;
        
        [self.navigationController presentViewController:imagePickController animated:YES completion:nil];
    }else{
        [self showAlertWithTitle:@"提示" message:@"设备不支持访问相册" handler:nil];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [picker dismissViewControllerAnimated:YES completion:^{
        self.qrImageView.image = info[UIImagePickerControllerOriginalImage];
        [self findQRCodeFromImage:self.qrImageView.image];
    }];
}
- (IBAction)handleLongPress:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        [self findQRCodeFromImage:self.qrImageView.image];
    }
}


- (void)findQRCodeFromImage:(UIImage*)image {
    CIDetector* detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{
                                                                                                 CIDetectorAccuracy:CIDetectorAccuracyHigh
                                                                                                 }];
    NSArray* features = [detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];
    if (features.count>1) {
        CIQRCodeFeature* feature = [features firstObject];
        [self showAlertWithTitle:@"扫描结构" message:feature.messageString handler:nil];
    }else{
        [self showAlertWithTitle:@"提示" message:@"图片中没有二维码" handler:nil];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
