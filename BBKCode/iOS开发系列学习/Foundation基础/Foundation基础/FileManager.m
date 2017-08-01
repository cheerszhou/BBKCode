//
//  FileManager.m
//  Foundation基础
//
//  Created by zxx_mbp on 2017/7/26.
//  Copyright © 2017年 zxx_mbp. All rights reserved.
//

#import "FileManager.h"

@implementation FileManager

/**
 目录操作
 */
void test1() {
    //文件管理类是用来管理文件的类
    NSFileManager * fileManager = [NSFileManager defaultManager];
    //获得当前程序所在的目录，可以改变
    NSString* currentPath = [fileManager currentDirectoryPath];
    NSLog(@"current path is :%@",currentPath);
    
    //创建目录
    NSString * myPath = @"/Users/zxx_mbp/Desktop/myDocument/";
    BOOL createDirResult = [fileManager createDirectoryAtPath:myPath withIntermediateDirectories:YES attributes:nil error:nil];
    if (!createDirResult) {
        NSLog(@"couldn't create directory!");
    }
    
    //目录重命名，如果需要删除目录只要调用removeItemAtPath:error:
    NSError *error;
    NSString * newpath = @"/Users/zxx_mbp/Desktop/myNewDocument";
    if ([fileManager moveItemAtPath:myPath toPath:newpath error:&error] == NO) {
        NSLog(@"rename directory failed! Error information is%@",error);
    }
    
    //改变当前目录
    if ([fileManager changeCurrentDirectoryPath:newpath] == NO) {
        NSLog(@"Change current directory failed!");
    }
    NSLog(@"current path is %@",[fileManager currentDirectoryPath]);
    //遍历整个目录
    NSString* path;
    NSDirectoryEnumerator* diretoryEnumerator = [fileManager enumeratorAtPath:newpath];
    while (path = [diretoryEnumerator nextObject]) {
        NSLog(@"%@",path);
    }

    NSHomeDirectory();
    NSTemporaryDirectory();
    NSString* secretPath = @"/Users/zxx_mbp/Desktop/myNewDocument/mySecret.arc";
    [NSArchiver archiveRootObject:@"my secret-sdfasdf" toFile:secretPath];
    
    NSLog(@"unarchiver contents is :%@",[NSUnarchiver unarchiveObjectWithFile:secretPath]);
}

- (void)executeTestMethods {
    
    test1();
    
}
@end
