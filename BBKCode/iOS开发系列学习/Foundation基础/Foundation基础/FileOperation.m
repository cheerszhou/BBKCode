//
//  FileOperation.m
//  Foundation基础
//
//  Created by zxx_mbp on 2017/7/25.
//  Copyright © 2017年 zxx_mbp. All rights reserved.
//

#import "FileOperation.h"

@implementation FileOperation
static void test1() {
    //读取文件内容
    NSString* path = @"";
    NSString* str1 = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    //注意上面也可以使用gb2312 gbk等，列如kCFStringEncodingGB_18030_2000,但是需要用CFStringConvertEncodingToNSStringEncoding转换
    NSLog(@"str1 is %@",str1);
    //结果：str1 is hello world,世界你好！
    
    //上面我们看到了读取文件，但并没有处理错误，当然在ObjC中可以@try @catch @finnally但通常我们并不那么做
    //由于我们的test.txt中有中文，所以使用下面的编码读取会报错，下面的代码演示了错误获取的过程
    NSError *error;
    NSString *str2 = [NSString stringWithContentsOfFile:path encoding:kCFStringEncodingGB_18030_2000 error:&error];//注意这句话中的error变量是**error,就是指针的指针那就是指针的地址，由于error就是一个指针此处也就是error的地址&error,具体原因见下面补充
    if (error) {
        NSLog(@"read error, the error is %@",error);
    }else {
        NSLog(@"read success,the file content is %@",str2);
    }
    //读取文件内容还有一种方式就是利用URl,它除了可以读取本地文件还可以读取网络文件
    //NSURL *url = [NSURL URLWithString:@"file:///Users/kenshicui/Desktop/test.txt"];
    NSURL *url = [NSURL URLWithString:@"http://www.apple.com"];
    NSString *str3 = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    NSLog(@"str3 is %@",str3);
    
    [[[NSArray alloc]init] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
    }];
    [[NSArray new] componentsJoinedByString:@","];
    [[NSArray new] sortedArrayUsingSelector:@selector(compare:)];
    [[NSArray new] sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return NSOrderedAscending;
        
    }];
    NSSortDescriptor * nameDescriptor = [[NSSortDescriptor alloc]initWithKey:@"name" ascending:YES];
    NSArray * sortDescriptors = [NSArray arrayWithObjects:nameDescriptor,nil];
    [[NSArray new] sortedArrayUsingDescriptors:sortDescriptors];
    
    NSEnumerator * dictEnumerator = [[NSDictionary new] objectEnumerator];
    [dictEnumerator nextObject];
}
@end
