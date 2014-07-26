//
//  GCPAppDelegate.m
//  Campus
//
//  Created by Joseph Pecoraro on 7/22/14.
//  Copyright (c) 2014 Hatchery Lab, LLC. All rights reserved.
//

#import "GCPAppDelegate.h"
#import "GCPTempViewController.h"
#import <FYX/FYX.h>

@implementation GCPAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    if (!launchOptions) {
        [FYX setAppId:kGimbalAppID
            appSecret:kGimbalAppSecret
          callbackUrl:kGimbalURL];
        
        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:[[GCPTempViewController alloc] init]];
        
        self.window.rootViewController = navController;
        [self.window makeKeyAndVisible];
    }
    else {
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        NSDate *now = [NSDate date];
        
        //one second delay gives the change to put the app in background
        NSDate *dateToFire = [now dateByAddingTimeInterval:1];
        
        [notification setFireDate:dateToFire];
        [notification setAlertBody:@"App Was Restarted In Background"];
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    NSLog(@"\nApplication Entered Background\n\n");
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
