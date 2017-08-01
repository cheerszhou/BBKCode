//
//  CustomClassBoxing.m
//  Foundation基础
//
//  Created by zxx_mbp on 2017/7/26.
//  Copyright © 2017年 zxx_mbp. All rights reserved.
//

#import "CustomClassBoxing.h"
typedef struct {
    int year;
    int month;
    int day;
}Date;

@implementation CustomClassBoxing

//NSNumber 是NSValue 的子类，NSValue可以包装任何类型，包括结构体
static void test1() {
    //如果我们自己定义的结构体包装
    Date date = {2017, 2, 28};
    char * type = @encode(Date);
    NSValue * value3 = [NSValue value:&date withObjCType:type];
    NSArray * array = [NSArray arrayWithObjects:value3,nil];
    NSLog(@"%@",array);
    
    Date date2 ;
    [value3 getValue:&date2];//取出对应的结构体，注意没有返回值
}


//反射
static void test2() {
    NSString *className = @"Person";
    Class myClass = NSClassFromString(className);
    
    NSString* methodName = @"showMessage:";
    SEL mySelector = NSSelectorFromString(methodName);
}
@end
