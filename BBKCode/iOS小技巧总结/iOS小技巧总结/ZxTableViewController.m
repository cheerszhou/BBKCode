//
//  ““ZxTableViewController.m
//  iOS小技巧总结
//  Created by zxx_mbp on 2017/5/13.
//  Copyright © 2017年 zxx_mbp. All rights reserved.
//

#import "ZxTableViewController.h"
#import "UIButton+EKCommon.h"

@interface ZxTableViewController ()

@end

@implementation ZxTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"reuseIdentifier"];
    
    //1.UITableView的Group样式下顶部空白处理
    //分组列表头部空白处理
    {
        UIView*view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 10)];
        self.tableView.tableHeaderView = view;
    }
    //self.tableView.tableFooterView = view;
    enumerateFonts();
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier" forIndexPath:indexPath];
    
    cell.textLabel.text = @"I'm a cell";
    // Configure the cell...
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}

//2.获取某个view所在的控制器
- (UIViewController*)viewController {
    UIViewController * viewcontroller = nil;
    UIResponder* next = self.view.nextResponder;
    while (next) {
        if ([next isKindOfClass:[UIViewController class]]) {
            viewcontroller = (UIViewController*)next;
            break;
        }
        next = next.nextResponder;
    }
    return viewcontroller;
}

//3.两种方法删除NSUserDefaults所有记录
- (void)removeUserDefaults {
    //方法一
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
}

- (void)resetDefaults {
    NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];
    NSDictionary* dicts = [defs dictionaryRepresentation];
    for (id key in dicts) {
        [defs removeObjectForKey:key];
    }
    [defs synchronize];
}


//4.打印系统所有已注册的字体名字
void enumerateFonts() {
    for (NSString *familyName in [UIFont familyNames]) {
        NSLog(@"%@",familyName);
        NSArray *fontNames = [UIFont fontNamesForFamilyName:familyName];
        for (NSString* fontName in fontNames) {
            NSLog(@"\t|- %@",fontName);
        }
    }
}


@end
