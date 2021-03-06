//
//  GCPTempViewController.m
//  Campus
//
//  Created by Joseph Pecoraro on 7/24/14.
//  Copyright (c) 2014 Hatchery Lab, LLC. All rights reserved.
//

#import "GCPTempViewController.h"
#import "GCPLocationTrackerViewController.h"
#import "GCPGimbalTempViewController.h"
#import "GCPEstimoteTempViewController.h"
#import "GCPGimbalIBeaconViewController.h"
#import "GCPCoreBluetoothViewController.h"
#import <FYX/FYX.h>

@interface GCPTempViewController ()

@end

@implementation GCPTempViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Bluetooth Beacon Test App";
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self stopAllBroadcastingServices];
}

- (IBAction)openGimbalTest:(id)sender {
    GCPGimbalTempViewController *gimbal = [[GCPGimbalTempViewController alloc] init];
    [self.navigationController pushViewController:gimbal animated:YES];
}

- (IBAction)openGimbalIBeaconTest:(id)sender {
    GCPGimbalIBeaconViewController *gimablIB = [[GCPGimbalIBeaconViewController alloc] init];
    [self.navigationController pushViewController:gimablIB animated:YES];
}

- (IBAction)openEstimoteTest:(id)sender {
    GCPEstimoteTempViewController *estimote = [[GCPEstimoteTempViewController alloc] init];
    [self.navigationController pushViewController:estimote animated:YES];
}

- (IBAction)openBuiltInBluetoothTest:(id)sender {
    GCPCoreBluetoothViewController *corebluetooth = [[GCPCoreBluetoothViewController alloc] init];
    [self.navigationController pushViewController:corebluetooth animated:YES];
}

- (IBAction)openLocationTracker:(id)sender {
    GCPLocationTrackerViewController *locationTracker = [[GCPLocationTrackerViewController alloc] init];
    [self.navigationController pushViewController:locationTracker animated:YES];
}

-(void)stopAllBroadcastingServices {
    [FYX stopService];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
