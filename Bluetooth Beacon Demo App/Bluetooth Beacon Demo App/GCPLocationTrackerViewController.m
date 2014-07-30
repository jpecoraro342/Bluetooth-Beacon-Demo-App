//
//  GCPLocationTrackerViewController.m
//  Bluetooth Beacon Demo App
//
//  Created by Joseph Pecoraro on 7/29/14.
//  Copyright (c) 2014 Hatchery Lab, LLC. All rights reserved.
//

#import "GCPLocationTrackerViewController.h"
#import "GCPStandardBeaconTableViewCell.h"
#import "GCPBeacon.h"
@import CoreLocation;

@interface GCPLocationTrackerViewController () <CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSMutableArray *listOfBeacons;
@property (strong, nonatomic) NSMutableDictionary *beacons;

@end

@implementation GCPLocationTrackerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Location Tracker";
    
    UIBarButtonItem *viewGraph = [[UIBarButtonItem alloc] initWithTitle:@"View Graphs" style:UIBarButtonItemStyleBordered target:self action:@selector(viewGraph)];
    self.navigationItem.rightBarButtonItem = viewGraph;
    
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
    beacon.uuid = [[NSUUID alloc] initWithUUIDString:@"B30071DE-17B6-4B1E-8915-A01B2E1ABA04"];
    beacon.major = 1;
    beacon.minor = 1;
    beacon.name = @"Location Tracker 1-1";
    [beacon updateIdentifier];
    [beacon setWriteAllInfo:YES];
    
    GCPBeacon *beacon2 = [[GCPBeacon alloc] init];
    beacon2.uuid = [[NSUUID alloc] initWithUUIDString:@"B30071DE-17B6-4B1E-8915-A01B2E1ABA04"];
    beacon2.major = 1;
    beacon2.minor = 2;
    beacon2.name = @"Location Tracker 1-2";
    [beacon2 updateIdentifier];
    [beacon2 setWriteAllInfo:YES];
    
    GCPBeacon *beacon3 = [[GCPBeacon alloc] init];
    beacon3.uuid = [[NSUUID alloc] initWithUUIDString:@"B30071DE-17B6-4B1E-8915-A01B2E1ABA04"];
    beacon3.major = 1;
    beacon3.minor = 3;
    beacon3.name = @"Location Tracker 1-3";
    [beacon3 updateIdentifier];
    [beacon3 setWriteAllInfo:YES];
    
    _listOfBeacons = [[NSMutableArray alloc] initWithObjects:beacon, beacon2, beacon3, nil];
    _beacons =[[NSMutableDictionary alloc] init];
    [self.beacons setObject:beacon forKey:beacon.identifier];
    [self.beacons setObject:beacon2 forKey:beacon2.identifier];
    [self.beacons setObject:beacon3 forKey:beacon3.identifier];
}

-(void)viewGraph {
    
}

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end


