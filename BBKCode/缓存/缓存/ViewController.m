//
//  ViewController.m
//  缓存
//
//  Created by zxx_mbp on 2017/5/8.
//  Copyright © 2017年 zxx_mbp. All rights reserved.
//

#import "ViewController.h"

typedef void (^GetDataCompletion)(NSData *data);

typedef NS_ENUM(NSInteger,ZXUserCachePolicyType) {
    ZXUserCachePolicyTypeEtagConnection,
    ZXUserCachePolicyTypeEtagSession,
    ZXUserCachePolicyTypeLastModifiedConnection,
    ZXUserCachePolicyTypeLastModifiedSession,
};
static NSString *const kETagImageURL = @"http://files.vivo.com.cn/static/www/vivo/xplay6/picture/xplay6-index-s1-figure3-small.png";
static NSString *const kLastModifiedImageURL = @"http://files.vivo.com.cn/static/www/vivo/high/x9hll/vm-h-x9hll-figure2-small.png";

@interface ViewController ()
//响应的 etag
@property (nonatomic, copy) NSString *etag;
@property (weak, nonatomic) IBOutlet UIImageView *myImageView;
@property (nonatomic, assign) ZXUserCachePolicyType userCachePolicyType;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.userCachePolicyType = ZXUserCachePolicyTypeEtagConnection;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self getData:^(NSData *data) {
        self.myImageView.image = [UIImage imageWithData:data];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [self getData:^(NSData *data) {
        self.myImageView.image = [UIImage imageWithData:data];
    }];
}


/**
 @brief 如果本地缓存资源为最新，则使用本地缓存，如果服务器已经更新或本地无缓存则从服务器请求资源
 
 @details
 步骤：
 1.请求是可变的，缓存策略要每次都从服务器加载
 2.每次得到响应后，需要记录住etag
 3.下次发送请求的同时，将etag一起发送给服务器（由服务器比较内容是否发生变化）
 

 @param completion 返回图片资源
 */
- (void)getData:(GetDataCompletion)completion {
    NSURL* url = [NSURL URLWithString:kETagImageURL];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:15.0f];
    
    //发送etag
    if(self.etag.length>0){
        [request setValue:self.etag forHTTPHeaderField:@"If-None-Match"];
    }
    
    //文件缓存—Etag—NSURLConnection
    switch (self.userCachePolicyType) {
        case ZXUserCachePolicyTypeEtagConnection:
            [self sendRequestByURLConnection:request completion:completion];
            break;
        case ZXUserCachePolicyTypeEtagSession:
            [self sendRequestByURLSessoin:request completion:completion];
            break;
        case ZXUserCachePolicyTypeLastModifiedConnection:
            
            break;
        case ZXUserCachePolicyTypeLastModifiedSession:
            
            break;
            
        default:
            break;
    }
    
}

- (void)sendRequestByURLConnection:(NSURLRequest*)request completion:(GetDataCompletion)completion{
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        //类型转换（如果将分类设置给子类，需要强制转换）
        NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
        NSLog(@"statusCode == %@",@(httpResponse.statusCode));
        //判断响应的状态码是否是 304 Not Modified
        if (httpResponse.statusCode == 304) {
            NSLog(@"加载本地缓存图片");
            //如果是，使用本地缓存，根据请求获得到‘被缓存的响应’
            NSCachedURLResponse* cacheResponse = [[NSURLCache sharedURLCache] cachedResponseForRequest:request];
            //拿到缓存数据
            data = cacheResponse.data;
        }
        //获取并且记录etag、区分大小写
        self.etag = httpResponse.allHeaderFields[@"Etag"];
        
        NSLog(@"etag值%@",self.etag);
        completion? completion(data) :nil;
    }];

}

- (void)sendRequestByURLSessoin:(NSURLRequest*)request completion:(GetDataCompletion)completion {
    NSURLSessionDataTask * dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        //类型转换（如果将分类设置给子类，需要强制转换）
        NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
        NSLog(@"statusCode == %@",@(httpResponse.statusCode));
        //判断响应的状态码是否是 304 Not Modified
        if (httpResponse.statusCode == 304) {
            NSLog(@"加载本地缓存图片");
            //如果是，使用本地缓存，根据请求获得到‘被缓存的响应’
            NSCachedURLResponse* cacheResponse = [[NSURLCache sharedURLCache] cachedResponseForRequest:request];
            //拿到缓存数据
            data = cacheResponse.data;
        }
        //获取并且记录etag、区分大小写
        self.etag = httpResponse.allHeaderFields[@"Etag"];
        
        NSLog(@"etag值%@",self.etag);
        completion? completion(data) :nil;
    }];
    
    [dataTask resume];
}



@end
