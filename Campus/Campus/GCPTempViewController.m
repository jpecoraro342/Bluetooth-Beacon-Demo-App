//
//  GCPTempViewController.m
//  Campus
//
//  Created by Joseph Pecoraro on 7/23/14.
//  Copyright (c) 2014 Hatchery Lab, LLC. All rights reserved.
//

#import "GCPTempViewController.h"
#import <FYX/FYX.h>
#import <FYX/FYXVisitManager.h>
#import <FYX/FYXTransmitter.h>

@interface GCPTempViewController () <FYXServiceDelegate, FYXVisitDelegate>

@property (nonatomic, strong) FYXVisitManager *visitManager;

@end

@implementation GCPTempViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        [FYX startService:self];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)serviceStarted {
    // this will be invoked if the service has successfully started
    // bluetooth scanning will be started at this point.
    NSLog(@"FYX Service Successfully Started");
    
    self.visitManager = [FYXVisitManager new];
    self.visitManager.delegate = self;
    [self.visitManager start];
}

- (void)startServiceFailed:(NSError *)error {
    // this will be called if the service has failed to start
    NSLog(@"%@", error);
}

- (void)didArrive:(FYXVisit *)visit;
{
    // this will be invoked when an authorized transmitter is sighted for the first time
    NSLog(@"Beacon Found\nName: %@\nTemperature: %@\nBattery: %@\n\n", visit.transmitter.name, visit.transmitter.temperature, visit.transmitter.battery);
}
- (void)receivedSighting:(FYXVisit *)visit updateTime:(NSDate *)updateTime RSSI:(NSNumber *)RSSI;
{
    // this will be invoked when an authorized transmitter is sighted during an on-going visit
    NSLog(@"Received Signal\nName: %@\nSignal: %@db\nTemperature: %@\nBattery: %@\n\n", visit.transmitter.name, RSSI, visit.transmitter.temperature, visit.transmitter.battery);
    
}
- (void)didDepart:(FYXVisit *)visit; {
    // this will be invoked when an authorized transmitter has not been sighted for some time
    NSLog(@"I have left the proximity of the beacon: %@\n", visit.transmitter.name);
    NSLog(@"I was around the beacon for %.4f seconds\n\n", visit.dwellTime);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
