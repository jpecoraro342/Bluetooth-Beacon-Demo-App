//
//  GCPAppDelegate.m
//  Campus
//
//  Created by Joseph Pecoraro on 7/22/14.
//  Copyright (c) 2014 Hatchery Lab, LLC. All rights reserved.
//

#import "GCPAppDelegate.h"
#import "GCPTempViewController.h"
#import "GCPBeacon.h"
#import <FYX/FYX.h>

@import CoreLocation;

@interface GCPAppDelegate () <CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;

@end

@implementation GCPAppDelegate

#pragma mark Application Delegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [FYX setAppId:kGimbalAppID
        appSecret:kGimbalAppSecret
      callbackUrl:kGimbalURL];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:[[GCPTempViewController alloc] init]];
    
    self.window.rootViewController = navController;
    [self.window makeKeyAndVisible];
    
    if (launchOptions) {
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        NSDate *now = [NSDate date];
        
        NSDate *dateToFire = [now dateByAddingTimeInterval:1];
        
        [notification setFireDate:dateToFire];
        [notification setAlertBody:@"App Was Restarted In Background"];
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
        
        NSLog(@"App Restarted In Background");
        
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        NSLog(@"Location Manager Reinitialized, not sure what to do now...");
    }

    return YES;
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    UIApplicationState state = [application applicationState];
    if (state == UIApplicationStateActive) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[notification.userInfo objectForKey:@"classType"]
                                                        message:notification.alertBody
                                                       delegate:self cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    
    // Set icon badge number to zero
    application.applicationIconBadgeNumber = 0;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    NSLog(@"Application Will Resign Active\n");
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    NSLog(@"Application Entered Background");
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    NSLog(@"Application Will Enter Foreground");
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    NSLog(@"Application Did Become Active");
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    NSLog(@"Application Will Terminate");
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark CLLocation Delegate

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region {
    if(state == CLRegionStateInside) {
        NSLog(@"You Are Inside The Region: %@", region);
        [self createLocalNotificationWithMessge:[NSString stringWithFormat:@"You Are Inside The Region: %@", region.identifier]];
    }
    else if(state == CLRegionStateOutside) {
        NSLog(@"You Are Outside The Region: %@", region);
        [self createLocalNotificationWithMessge:[NSString stringWithFormat:@"You Are Outside The Region: %@", region.identifier]];
    }
    else {
        NSLog(@"You are neither inside nore outside the region: %@", region);
        return;
    }
}

-(void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    for (CLBeacon *beacon in beacons) {
        NSLog(@"Received Beacon Signal\nUUID:%@\nSignal: %zd\nMajor: %zd\nMinor: %zd", [beacon.proximityUUID UUIDString], beacon.rssi, [beacon.major integerValue], [beacon.minor integerValue]);
    }
}

-(void)createLocalNotificationWithMessge:(NSString *)message {
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:@"App Delegate", @"classType", nil];
    notification.userInfo = dict;
    NSDate *now = [NSDate date];
    
    //one second delay gives the change to put the app in background
    NSDate *dateToFire = [now dateByAddingTimeInterval:1];
    
    [notification setFireDate:dateToFire];
    [notification setAlertBody:[NSString stringWithFormat:@"%@", message]];
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

@end
