//
//  ViewController.m
//  UITableView全面解析
//
//  Created by zxx_mbp on 2017/7/28.
//  Copyright © 2017年 zxx_mbp. All rights reserved.
//

#import "ViewController.h"
#import "ZXContact.h"
#import "ZXContactGroup.h"


@interface ViewController ()<UITableViewDataSource,UITableViewDelegate> {
    UITableView *_tableView;
    NSMutableArray *_contacts;//联系人模型
    NSIndexPath *_selectedIndexPath;//当前选中的组合行
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //初始化数据
    [self initData];
    
    //创建一个分组样式的UITableView
    _tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    
    //设置数据源，注意必须实现对应的UITableViewDataSource协议
    _tableView.dataSource = self;
    _tableView.delegate = self;
    
    [self.view addSubview:_tableView];
}

- (void)initData {
    _contacts = [[NSMutableArray alloc]init];
    ZXContact *contact1 = [ZXContact initWithFirstName:@"Cui" andLastName:@"Kenshin" andPhoneNumber:@"18500131234"];
    ZXContact *contact2 = [ZXContact initWithFirstName:@"Cui" andLastName:@"Tom" andPhoneNumber:@"18500131237"];
    ZXContactGroup *group1 = [ZXContactGroup initWithName:@"C" andDetail:@"With names beginning with C" andContacts:[NSMutableArray arrayWithObjects:contact1, contact2,nil]];
    [_contacts addObject:group1];
    
    ZXContact *contact3=[ZXContact initWithFirstName:@"Lee" andLastName:@"Terry" andPhoneNumber:@"18500131238"];
    ZXContact *contact4=[ZXContact initWithFirstName:@"Lee" andLastName:@"Jack" andPhoneNumber:@"18500131239"];
    ZXContact *contact5=[ZXContact initWithFirstName:@"Lee" andLastName:@"Rose" andPhoneNumber:@"18500131240"];
    ZXContactGroup *group2=[ZXContactGroup initWithName:@"L" andDetail:@"With names beginning with L" andContacts:[NSMutableArray arrayWithObjects:contact3,contact4,contact5, nil]];
    [_contacts addObject:group2];
    
    
    
    ZXContact *contact6=[ZXContact initWithFirstName:@"Sun" andLastName:@"Kaoru" andPhoneNumber:@"18500131235"];
    ZXContact *contact7=[ZXContact initWithFirstName:@"Sun" andLastName:@"Rosa" andPhoneNumber:@"18500131236"];
    
    ZXContactGroup *group3=[ZXContactGroup initWithName:@"S" andDetail:@"With names beginning with S" andContacts:[NSMutableArray arrayWithObjects:contact6,contact7, nil]];
    [_contacts addObject:group3];
    
    
    ZXContact *contact8=[ZXContact initWithFirstName:@"Wang" andLastName:@"Stephone" andPhoneNumber:@"18500131241"];
    ZXContact *contact9=[ZXContact initWithFirstName:@"Wang" andLastName:@"Lucy" andPhoneNumber:@"18500131242"];
    ZXContact *contact10=[ZXContact initWithFirstName:@"Wang" andLastName:@"Lily" andPhoneNumber:@"18500131243"];
    ZXContact *contact11=[ZXContact initWithFirstName:@"Wang" andLastName:@"Emily" andPhoneNumber:@"18500131244"];
    ZXContact *contact12=[ZXContact initWithFirstName:@"Wang" andLastName:@"Andy" andPhoneNumber:@"18500131245"];
    ZXContactGroup *group4=[ZXContactGroup initWithName:@"W" andDetail:@"With names beginning with W" andContacts:[NSMutableArray arrayWithObjects:contact8,contact9,contact10,contact11,contact12, nil]];
    [_contacts addObject:group4];
    
    
    ZXContact *contact13=[ZXContact initWithFirstName:@"Zhang" andLastName:@"Joy" andPhoneNumber:@"18500131246"];
    ZXContact *contact14=[ZXContact initWithFirstName:@"Zhang" andLastName:@"Vivan" andPhoneNumber:@"18500131247"];
    ZXContact *contact15=[ZXContact initWithFirstName:@"Zhang" andLastName:@"Joyse" andPhoneNumber:@"18500131248"];
    ZXContactGroup *group5=[ZXContactGroup initWithName:@"Z" andDetail:@"With names beginning with Z" andContacts:[NSMutableArray arrayWithObjects:contact13,contact14,contact15, nil]];
    [_contacts addObject:group5];

}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _contacts.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    ZXContactGroup *group = _contacts[section];
    return group.contacts.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 50;
    }
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //NSIndexPath是一个结构体，记录了组和行信息
    ZXContactGroup *group = _contacts[indexPath.section];
    ZXContact *contact = group.contacts[indexPath.row];
    //由于此方法调用十分频繁、cell的标示声明成静态变量有利于性能优化
    static NSString *cellIdentifier = @"UITableViewCellIdentifierKey1";
    static NSString *cellIdentifierForFirstRow = @"UITableViewCellIdentifierKeyWithSwitch";
    
    //首先根据标识去缓存池取
    UITableViewCell *cell;
    //如果缓存池没有到则重新创建并放到缓存池中
    if (indexPath.row == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifierForFirstRow];
    }else {
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    }
    
    //如果缓存池没有取到则重新创建并放到缓存池中
    if (!cell) {
        if (indexPath.row == 0) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifierForFirstRow];
            UISwitch *sw = [[UISwitch alloc]init];
            [sw addTarget:self action:@selector(switchValueChange:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = sw;
        }else {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
            cell.accessoryType = UITableViewCellAccessoryDetailButton;
        }
    }
    
    if (indexPath.row == 0) {
        ((UISwitch*)cell.accessoryView).tag = indexPath.section;
    }
    cell.textLabel.text = [contact getName];
    cell.detailTextLabel.text = contact.phoneNumber;
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    ZXContactGroup *group = _contacts[section];
    return group.detail;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    ZXContactGroup *group = _contacts[section];
    return group.name;
}

- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    NSMutableArray *indexs = [[NSMutableArray alloc]init];
    for (ZXContactGroup *group in _contacts) {
        [indexs addObject:group.name];
    }
    return indexs;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    _selectedIndexPath = indexPath;
    ZXContactGroup *group = _contacts[indexPath.section];
    ZXContact *contact = group.contacts[indexPath.row];
    //创建弹出窗口
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"System Info" message:[contact getName] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;//设置窗口内容样式
    UITextField *textField = [alert textFieldAtIndex:0];//取得文本框
    textField.text = contact.phoneNumber;//设置文本框内容
    [alert show];//显示窗口
}

- (void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    //当点击了第二按钮（OK）
    if (buttonIndex == 1) {
        UITextField *textField = [alertView textFieldAtIndex:0];
        //修改模型数据
        ZXContactGroup *group = _contacts[_selectedIndexPath.section];
        ZXContact *contact = group.contacts[_selectedIndexPath.row];
        contact.phoneNumber = textField.text;
        //刷新表格
        [_tableView reloadData];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}
@end
