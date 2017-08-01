//
//  ZXContact.h
//  UITableView全面解析
//
//  Created by zxx_mbp on 2017/7/28.
//  Copyright © 2017年 zxx_mbp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZXContact : NSObject

@property (nonatomic, copy) NSString *firstName;

@property (nonatomic, copy) NSString *lastName;

@property (nonatomic, copy) NSString *phoneNumber;

- (instancetype)initWithFirstName:(NSString*)firstName andLastName:(NSString*)lastName andPhoneNumber:(NSString*)phoneNumber;

- (NSString*)getName;

+ (ZXContact*)initWithFirstName:(NSString*)firstName andLastName:(NSString*)lastName andPhoneNumber:(NSString*)phoneNumber;

@end
