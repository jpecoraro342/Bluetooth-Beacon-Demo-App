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
@property (weak, nonatomic) IBOutlet UILabel *singleBeaconLabel;
@property (nonatomic, assign) NSInteger lastFiredNotification; //0 = no notification/reset 1 = Hot 2 = Cold

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
    NSLog(@"\nBeacon Found\nName: %@\nTemperature: %@\nBattery: %@\n\n", visit.transmitter.name, visit.transmitter.temperature, visit.transmitter.battery);
}
- (void)receivedSighting:(FYXVisit *)visit updateTime:(NSDate *)updateTime RSSI:(NSNumber *)RSSI;
{
    if (![visit.transmitter.identifier isEqualToString:@"9as6-mrnmg"]) {
        NSLog(@"Ignoring Beacon\nID: %@\n\n", visit.transmitter.identifier);
        return;
    }
    // this will be invoked when an authorized transmitter is sighted during an on-going visit
    NSString *details = [NSString stringWithFormat:@"Received Signal\nName: %@\nSignal: %@db\nTemperature: %@f\nBattery: %@", visit.transmitter.name, RSSI, visit.transmitter.temperature, visit.transmitter.battery];
    [self.singleBeaconLabel setText:details];
    NSLog(@"\n%@\n\n", details);
    if ([RSSI integerValue] > -60) {
        if (self.lastFiredNotification == 1)
            return;
        
        self.lastFiredNotification = 1;
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        NSDate *now = [NSDate date];
        NSDate *dateToFire = [now dateByAddingTimeInterval:1];
        
        [notification setFireDate:dateToFire];
        [notification setAlertBody:@"Beacon Has a Strong Signal"];
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
    else if ([RSSI integerValue] < -80) {
        if (self.lastFiredNotification == 2)
            return;
        
        self.lastFiredNotification = 2;
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        NSDate *now = [NSDate date];
        NSDate *dateToFire = [now dateByAddingTimeInterval:1];
        
        [notification setFireDate:dateToFire];
        [notification setAlertBody:@"Beacon's Signal is Weakening"];
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
    else {
        NSLog(@"Beacon Signal Notification Reset\n\n");
        self.lastFiredNotification = 0;
    }
}
- (void)didDepart:(FYXVisit *)visit; {
    // this will be invoked when an authorized transmitter has not been sighted for some time
    NSLog(@"Beacon: %@ has exited range\n", visit.transmitter.name);
    NSLog(@"Beacon was in proximity for %.4f seconds\n\n", visit.dwellTime);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
