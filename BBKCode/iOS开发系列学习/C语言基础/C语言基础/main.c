//
//  main.c
//  C语言基础
//
//  Created by zxx_mbp on 2017/7/21.
//  Copyright © 2017年 zxx_mbp. All rights reserved.
//

#include <stdio.h>


void showMessage() {
    printf("Hello, world!\n");
}

void showPrintf() {
    int a=16;
    float b=79.3f;
    printf("[a=%4d]\n",a);
    printf("[a=%-4d]\n",a);
    printf("[b=%10f]\n",b);
    printf("[b=%.2f]\n",b);
    printf("[b=%4.2f]\n",b);
}

int main(int argc, const char * argv[]) {
    // insert code here...
    //showMessage();
    showPrintf();
    return 0;
}
