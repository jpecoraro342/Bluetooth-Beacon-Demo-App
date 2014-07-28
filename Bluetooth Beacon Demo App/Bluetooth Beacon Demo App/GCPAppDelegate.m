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
        
        NSLog(@"\nApp Restarted In Background\n\n");
        
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        NSLog(@"\nLocation Manager Reinitialized, not sure what to do now...\n\n");
    }

    return YES;
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    UIApplicationState state = [application applicationState];
    if (state == UIApplicationStateActive) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Beacon In Range"
                                                        message:notification.alertBody
                                                       delegate:self cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    
    // Request to reload table view data
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadData" object:self];
    
    // Set icon badge number to zero
    application.applicationIconBadgeNumber = 0;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    NSLog(@"\nApplication Will Resign Active\n");
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    NSLog(@"\nApplication Entered Background\n\n");
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    NSLog(@"\nApplication Will Enter Foreground\n\n");
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    NSLog(@"\nApplication Did Become Active\n\n");
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    NSLog(@"\nApplication Will Terminate\n\n");
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark CLLocation Delegate

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region {
    if(state == CLRegionStateInside) {
        NSLog(@"\nYou Are Inside The Region\n\n");
    }
    else if(state == CLRegionStateOutside) {
        NSLog(@"\nYou Are Outside The Region\n\n");
    }
    else {
        NSLog(@"\nYou are neither inside nore outside the region.\n\n");
        return;
    }
}

-(void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    for (CLBeacon *beacon in beacons) {
        NSLog(@"Received Beacon Signal\nUUID:%@\nSignal: %zd\nMajor: %zd\nMinor: %zd", [beacon.proximityUUID UUIDString], beacon.rssi, [beacon.major integerValue], [beacon.minor integerValue]);
    }
}

@end
