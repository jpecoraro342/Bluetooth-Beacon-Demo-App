//
//  GCPTempViewController.m
//  Campus
//
//  Created by Joseph Pecoraro on 7/23/14.
//  Copyright (c) 2014 Hatchery Lab, LLC. All rights reserved.
//

#import "GCPGimbalTempViewController.h"
#import <FYX/FYX.h>
#import <FYX/FYXVisitManager.h>
#import <FYX/FYXTransmitter.h>

@interface GCPGimbalTempViewController () <FYXServiceDelegate, FYXVisitDelegate>

@property (nonatomic, strong) FYXVisitManager *visitManager;
@property (weak, nonatomic) IBOutlet UILabel *gimbalStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *singleBeaconLabel;
@property (nonatomic, assign) NSInteger lastFiredNotification; //0 = no notification/reset 1 = Hot 2 = Cold

@end

@implementation GCPGimbalTempViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [FYX startService:self];
}

#pragma mark Gimbal FYXServiceDelegate

- (void)serviceStarted {
    // this will be invoked if the service has successfully started
    // bluetooth scanning will be started at this point.
    [self setStatusLabel:@"FYX Service Was Started"];
    
    self.visitManager = [FYXVisitManager new];
    self.visitManager.delegate = self;
    [self.visitManager start];
}

- (void)startServiceFailed:(NSError *)error {
    // this will be called if the service has failed to start
    [self setStatusLabel:@"FYX Service Start Failed: See Log for Details"];
    NSLog(@"%@", error);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSLog(@"viewDidLoad called");
        //wait 3 seconds before exiting
        sleep(2);
        [self setStatusLabel:@"Returning to main view now"];
        sleep(1);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController popViewControllerAnimated:YES];
        });
        
    });
}

#pragma mark Gimbal FYXVisitDelegate

- (void)didArrive:(FYXVisit *)visit; {
    // this will be invoked when an authorized transmitter is sighted for the first time
    [self setStatusLabel:@"A beacon has been discovered"];
    NSLog(@"\nBeacon Found\nName: %@\nTemperature: %@\nBattery: %@\n\n", visit.transmitter.name, visit.transmitter.temperature, visit.transmitter.battery);
}
- (void)receivedSighting:(FYXVisit *)visit updateTime:(NSDate *)updateTime RSSI:(NSNumber *)RSSI; {

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterNoStyle];
    [dateFormatter setTimeStyle:NSDateFormatterLongStyle];
    [self.gimbalStatusLabel setText:[NSString stringWithFormat:@"Last Updated: %@", [dateFormatter stringFromDate:updateTime]]];
    
    if (![visit.transmitter.identifier isEqualToString:@"9as6-mrnmg"]) {
        NSLog(@"Ignoring Beacon\nID: %@\n\n", visit.transmitter.identifier);
        return;
    }
    // this will be invoked when an authorized transmitter is sighted during an on-going visit
    NSString *details = [NSString stringWithFormat:@"Received Signal\nName: %@\nSignal: %@db\nTemperature: %@f\nBattery: %@", visit.transmitter.name, RSSI, visit.transmitter.temperature, visit.transmitter.battery];
    [self.singleBeaconLabel setText:details];
    [self.singleBeaconLabel sizeToFit];
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
        if (self.lastFiredNotification == 0)
            return;
        
        NSLog(@"Beacon Signal Notification Reset\n\n");
        self.lastFiredNotification = 0;
    }
}

- (void)didDepart:(FYXVisit *)visit; {
    // this will be invoked when an authorized transmitter has not been sighted for some time
    NSLog(@"Beacon: %@ has exited range\n", visit.transmitter.name);
    NSLog(@"Beacon was in proximity for %.4f seconds\n\n", visit.dwellTime);
}

#pragma mark Private

-(void)setStatusLabel:(NSString*)status {
    NSLog(@"\n%@\n\n", status);
    [self.gimbalStatusLabel setText:status];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
