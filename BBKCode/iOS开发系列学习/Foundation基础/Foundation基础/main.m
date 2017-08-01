//
//  main.m
//  Foundation基础
//
//  Created by zxx_mbp on 2017/7/25.
//  Copyright © 2017年 zxx_mbp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FileManager.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        FileManager* fileManager = [FileManager new];
        [fileManager executeTestMethods];
    }
    return 0;
}
