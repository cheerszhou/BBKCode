//
//  ZXContactGroup.m
//  UITableView全面解析
//
//  Created by zxx_mbp on 2017/7/28.
//  Copyright © 2017年 zxx_mbp. All rights reserved.
//

#import "ZXContactGroup.h"

@implementation ZXContactGroup

- (ZXContactGroup *)initWithName:(NSString *)name andDetail:(NSString *)detail andContacts:(NSMutableArray *)contacts {
    if (self = [super init]) {
        self.name = name;
        self.detail = detail;
        self.contacts = contacts;
    }
    return self;
}

+ (ZXContactGroup *)initWithName:(NSString *)name andDetail:(NSString *)detail andContacts:(NSMutableArray *)contacts {
    ZXContactGroup * group = [[ZXContactGroup alloc]initWithName:name andDetail:detail andContacts:contacts];
    return group;
}
@end
