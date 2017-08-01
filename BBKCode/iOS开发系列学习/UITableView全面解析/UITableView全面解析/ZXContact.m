//
//  ZXContact.m
//  UITableView全面解析
//
//  Created by zxx_mbp on 2017/7/28.
//  Copyright © 2017年 zxx_mbp. All rights reserved.
//

#import "ZXContact.h"

@implementation ZXContact

- (instancetype)initWithFirstName:(NSString *)firstName andLastName:(NSString *)lastName andPhoneNumber:(NSString *)phoneNumber {
    if (self=[super init]) {
        self.firstName = firstName;
        self.lastName = lastName;
        self.phoneNumber = phoneNumber;
    }
    return self;
}

- (NSString*)getName {
    return [NSString stringWithFormat:@"%@ %@", _lastName, _firstName];
}

+ (ZXContact *)initWithFirstName:(NSString *)firstName andLastName:(NSString *)lastName andPhoneNumber:(NSString *)phoneNumber {
    ZXContact *contact = [[ZXContact alloc]initWithFirstName:firstName andLastName:lastName andPhoneNumber:phoneNumber];
    return contact;
}

@end
