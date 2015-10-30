//
//  AppDelegate.m
//  dotc-imagemanager-demo
//
//  Created by Yang G on 15/10/10.
//  Copyright © 2015年 .C . All rights reserved.
//

#import "AppDelegate.h"
#import "DotCImageManager.h"
#import "DotCImageManagerAdapter.h"
#import "DotCImageView.h"
#import "ViewController.h"

@interface AppDelegate ()
{
    UIWindow*           _window;
}

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // Setup integrate adapter
    [DotCImageManager setIntegrateAdapter:[DotCImageManagerAdapter instance]];
    
    // Initialize DotCImageManager, DotCImageManager is singleton instance
    DOTC_IMAGE_MANAGER;
    
    _window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    
    UIViewController* mainController = [[[ViewController alloc] init] autorelease];
    
    _window.rootViewController = [[[UINavigationController alloc]  initWithRootViewController:mainController] autorelease];
    
    [_window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
