//
//  GCPCoreBluetoothViewController.m
//  Bluetooth Beacon Demo App
//
//  Created by Joseph Pecoraro on 7/28/14.
//  Copyright (c) 2014 Hatchery Lab, LLC. All rights reserved.
//

#import "GCPCoreBluetoothViewController.h"
#import "GCPStandardBeaconTableViewCell.h"
#import "GCPBeacon.h"
@import CoreLocation;

@interface GCPCoreBluetoothViewController () <CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSMutableArray *listOfBeacons;
@property (strong, nonatomic) NSMutableDictionary *beacons;

@end

@implementation GCPCoreBluetoothViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Core Bluetooth";
    
    _locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self loadBeacons];
    [self startMonitoringAllItems];
    
    UINib *nib = [UINib nibWithNibName:@"GCPStandardBeaconTableViewCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"iBeaconCell"];
}

#pragma mark TableView Delegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.listOfBeacons count];
}

-(GCPStandardBeaconTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GCPStandardBeaconTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"iBeaconCell" forIndexPath:indexPath];
    
    if (indexPath.row < [self.listOfBeacons count]) {
        GCPBeacon *beacon = [self.listOfBeacons objectAtIndex:indexPath.row];
        cell.nameLabel.text = beacon.name;
        cell.uuidLabel.text = [beacon.uuid UUIDString];
        cell.majorLabel.text = [NSString stringWithFormat:@"%zd", beacon.major];
        cell.minorLabel.text = [NSString stringWithFormat:@"%zd", beacon.minor];
        cell.distanceLabel.text = beacon.distance;
        cell.accuracyLabel.text = [NSString stringWithFormat:@"+/- %.2fm", beacon.accuracy];
        cell.rssiLabel.text = [NSString stringWithFormat:@"%zddb", beacon.rssi];
    }
    return cell;
}

#pragma mark Location Manager Delegate

-(void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    for (CLBeacon *beacon in beacons) {
        NSLog(@"Received Beacon Signal\nUUID:%@\nSignal: %zd\nMajor: %zd\nMinor: %zd", [beacon.proximityUUID UUIDString], beacon.rssi, [beacon.major integerValue], [beacon.minor integerValue]);
        NSString *identifier = [NSString stringWithFormat:@"%@:%zd:%zd", [beacon.proximityUUID UUIDString], [beacon.major integerValue], [beacon.minor integerValue]];
        GCPBeacon *updateBeacon = [self.beacons objectForKey:identifier];
        [updateBeacon updateBeaconWithCLBeacon:beacon];
        if (beacon.proximity == CLProximityNear && updateBeacon.hasBeenReset) {
            [self fireInRangeUpdate:updateBeacon];
        }
    }
    [self.tableView reloadData];
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
    NSLog(@"Failed monitoring region: %@\nError: %@", region, error);
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"Location manager failed: %@", error);
}

#pragma mark Private

-(void)startMonitoringAllItems {
    for (int i = 0; i < [self.listOfBeacons count]; i++) {
        CLBeaconRegion *beaconRegion = [self beaconRegionWithItem:[self.listOfBeacons objectAtIndex:i]];
        [self.locationManager startMonitoringForRegion:beaconRegion];
        [self.locationManager startRangingBeaconsInRegion:beaconRegion];
        NSLog(@"%@", self.locationManager.monitoredRegions);
    }
}

-(void)stopMonitoringAllItems {
    for (int i = 0; i < [self.listOfBeacons count]; i++) {
        CLBeaconRegion *beaconRegion = [self beaconRegionWithItem:[self.listOfBeacons objectAtIndex:i]];
        [self.locationManager stopMonitoringForRegion:beaconRegion];
        [self.locationManager stopRangingBeaconsInRegion:beaconRegion];
    }
}

- (CLBeaconRegion *)beaconRegionWithItem:(GCPBeacon *)item {
    CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:item.uuid
                                                                           //major:item.major
                                                                           //minor:item.minor
                                                                      identifier:item.name];
    beaconRegion.notifyEntryStateOnDisplay = YES;
    return beaconRegion;
}

-(void)loadBeacons {
    GCPBeacon *beacon = [[GCPBeacon alloc] init];
    beacon.uuid = [[NSUUID alloc] initWithUUIDString:@"D133D6A0-1295-11E4-9191-0800200C9A66"];
    beacon.major = 1;
    beacon.minor = 1;
    beacon.name = @"Joseph's Gimbal";
    [beacon updateIdentifier];
    
    GCPBeacon *estimote = [[GCPBeacon alloc] init];
    estimote.uuid = [[NSUUID alloc] initWithUUIDString:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D"];
    estimote.major = 41509;
    estimote.minor = 33422;
    estimote.name = @"Nipun's Estimote";
    [estimote updateIdentifier];
    
    GCPBeacon *estimote2 = [[GCPBeacon alloc] init];
    estimote2.uuid = [[NSUUID alloc] initWithUUIDString:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D"];
    estimote2.major = 61323;
    estimote2.minor = 46449;
    estimote2.name = @"Nikhillesh's Estimote";
    [estimote2 updateIdentifier];
    
    GCPBeacon *beacon3 = [[GCPBeacon alloc] init];
    beacon3.uuid = [[NSUUID alloc] initWithUUIDString:@"B30071DE-17B6-4B1E-8915-A01B2E1ABA04"];
    beacon3.major = 1;
    beacon3.minor = 1;
    beacon3.name = @"Location Tracker 1-1";
    [beacon3 updateIdentifier];
    
    GCPBeacon *beacon4 = [[GCPBeacon alloc] init];
    beacon4.uuid = [[NSUUID alloc] initWithUUIDString:@"B30071DE-17B6-4B1E-8915-A01B2E1ABA04"];
    beacon4.major = 1;
    beacon4.minor = 2;
    beacon4.name = @"Location Tracker 1-2";
    [beacon4 updateIdentifier];
    
    GCPBeacon *beacon5 = [[GCPBeacon alloc] init];
    beacon5.uuid = [[NSUUID alloc] initWithUUIDString:@"B30071DE-17B6-4B1E-8915-A01B2E1ABA04"];
    beacon5.major = 1;
    beacon5.minor = 3;
    beacon5.name = @"Location Tracker 1-3";
    [beacon5 updateIdentifier];
    
    _listOfBeacons = [[NSMutableArray alloc] initWithObjects:beacon, estimote, estimote2, beacon3, beacon4, beacon5, nil];
    _beacons =[[NSMutableDictionary alloc] init];
    [self.beacons setObject:beacon forKey:beacon.identifier];
    [self.beacons setObject:estimote forKey:estimote.identifier];
    [self.beacons setObject:estimote2 forKey:estimote2.identifier];
    [self.beacons setObject:beacon3 forKey:beacon3.identifier];
    [self.beacons setObject:beacon4 forKey:beacon4.identifier];
    [self.beacons setObject:beacon5 forKey:beacon5.identifier];
}

-(void)fireInRangeUpdate:(GCPBeacon *)beacon {
    NSDate *now = [NSDate date];
    
    NSTimeInterval timeSinceLastNotification = [now timeIntervalSinceDate:[beacon lastNotificationDate]];
    
    if (timeSinceLastNotification < 60) {
        NSLog(@"In range notification suppressed");
        return;
    }
    
    beacon.lastNotificationDate = now;
    beacon.hasBeenReset = NO;
    
    [self sendNotificationWithMessage:[NSString stringWithFormat:@"%@ Is Near", beacon.name]];
}

-(void)sendNotificationWithMessage:(NSString*)message {
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:@"Core Bluetooth", @"classType", nil];
    notification.userInfo = dict;
    NSDate *now = [NSDate date];
    
    //one second delay gives the change to put the app in background
    NSDate *dateToFire = [now dateByAddingTimeInterval:1];
    
    [notification setFireDate:dateToFire];
    [notification setAlertBody:[NSString stringWithFormat:@"Core Bluetooth: %@", message]];
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
