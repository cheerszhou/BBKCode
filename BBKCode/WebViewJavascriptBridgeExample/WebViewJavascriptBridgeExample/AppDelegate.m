//
//  AppDelegate.m
//  WebViewJavascriptBridgeExample
//
//  Created by zxx_mbp on 2017/4/29.
//  Copyright © 2017年 zxx_mbp. All rights reserved.
//

#import <WebKit/WebKit.h>
#import "AppDelegate.h"
#import "ExampleUIWebViewViewController.h"
#import "ExampleWKWebViewViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //1.create the UIWebView example
    ExampleUIWebViewViewController* UIWebViewVC = [[ExampleUIWebViewViewController alloc]init];
    UIWebViewVC.tabBarItem.title = @"UIWebView";
    
    //2.create the tab footer and add the UIWebViewe example
    UITabBarController *tabBarController = [UITabBarController new];
    [tabBarController addChildViewController:UIWebViewVC];
    
    //3.create the WKWebView example for devices >= ios 8
    if ([WKWebView class]) {
        ExampleWKWebViewViewController *WKWebViewVC = [[ExampleWKWebViewViewController alloc]init];
        WKWebViewVC.tabBarItem.title = @"WKWebView";
        [tabBarController addChildViewController:WKWebViewVC];
    }
    
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = tabBarController;
    [self.window makeKeyAndVisible];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
