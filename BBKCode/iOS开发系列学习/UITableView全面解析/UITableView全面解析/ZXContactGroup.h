//
//  ZXContactGroup.h
//  UITableView全面解析
//
//  Created by zxx_mbp on 2017/7/28.
//  Copyright © 2017年 zxx_mbp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZXContact.h"

@interface ZXContactGroup : NSObject

@property (nonatomic, copy) NSString *name;

@property (nonatomic, copy) NSString *detail;

@property (nonatomic, strong) NSMutableArray *contacts;

- (ZXContactGroup*)initWithName:(NSString*)name andDetail:(NSString*)detail andContacts:(NSMutableArray*)contacts;

+ (ZXContactGroup*)initWithName:(NSString*)name andDetail:(NSString*)detail andContacts:(NSMutableArray*)contacts;

@end
