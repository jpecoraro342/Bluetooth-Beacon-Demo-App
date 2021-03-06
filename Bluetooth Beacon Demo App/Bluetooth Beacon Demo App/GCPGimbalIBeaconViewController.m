//
//  GCPGimbalIBeaconViewController.m
//  Bluetooth Beacon Demo App
//
//  Created by Joseph Pecoraro on 7/25/14.
//  Copyright (c) 2014 Hatchery Lab, LLC. All rights reserved.
//

#import "GCPGimbalIBeaconViewController.h"
#import "GCPChartViewController.h"
#import "GCPStandardBeaconTableViewCell.h"
#import "GCPBeacon.h"
#import <FYX/FYX.h>
#import <FYX/FYXVisitManager.h>
#import <FYX/FYXiBeacon.h>
#import <FYX/FYXTransmitter.h>

@interface GCPGimbalIBeaconViewController () <FYXServiceDelegate, FYXiBeaconVisitDelegate, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) FYXVisitManager *visitManager;
@property (weak, nonatomic) IBOutlet UILabel *primaryStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondaryStatusLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, assign) NSInteger lastFiredNotification; //0 = no notification/reset 1 = Hot 2 = Cold

@property (nonatomic, strong) NSDate *lastInRangeNotification;
@property (nonatomic, strong) NSDate *lastOutOfRangeNotification;

@property (nonatomic, assign) NSInteger entranceDB;
@property (nonatomic, assign) NSInteger exitDB;

@property (nonatomic, strong) NSMutableArray *dbLevels; //y values
@property (nonatomic, strong) NSMutableArray *occurrenceTime; //x values

@property (nonatomic, strong) NSMutableArray *listOfBeacons;
@property (strong, nonatomic) NSMutableDictionary *beaconDictionary;

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@property (nonatomic, strong) NSDate *lastEntranceNotification;

@end

@implementation GCPGimbalIBeaconViewController

-(instancetype)init {
    self = [super init];
    if (self) {
        self.entranceDB = -50;
        self.exitDB = -80;
        _dbLevels = [[NSMutableArray alloc] init];
        _occurrenceTime = [[NSMutableArray alloc] init];
        _dateFormatter = [[NSDateFormatter alloc] init];
        [self.dateFormatter setDateStyle:NSDateFormatterNoStyle];
        [self.dateFormatter setTimeStyle:NSDateFormatterLongStyle];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadBeacons];
    
    UINib *nib = [UINib nibWithNibName:@"GCPStandardBeaconTableViewCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"iBeaconCell"];
    
    [FYX startService:self];
}

#pragma mark TableView Datasource/Delegate

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

#pragma mark Gimbal FYXServiceDelegate

- (void)serviceStarted {
    // this will be invoked if the service has successfully started
    // bluetooth scanning will be started at this point.
    [self setPrimaryStatusLabelText:@"FYX Service Was Started"];
    
    self.visitManager = [FYXVisitManager new];
    self.visitManager.iBeaconDelegate = self;
    [self.visitManager start];
}

- (void)startServiceFailed:(NSError *)error {
    // this will be called if the service has failed to start
    [self setPrimaryStatusLabelText:@"FYX Service Start Failed: See Log for Details"];
    NSLog(@"%@", error);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSLog(@"viewDidLoad called");
        //wait 3 seconds before exiting
        sleep(2);
        [self setPrimaryStatusLabelText:@"Returning to main view now"];
        sleep(1);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController popViewControllerAnimated:YES];
        });
        
    });
}

#pragma mark Gimbal FYXiBeaconVisitDelegate

-(void)didArriveIBeacon:(FYXiBeaconVisit *)visit {
    NSLog(@"\nVisit IBeacon: \n%@", visit.iBeacon);
    // this will be invoked when an authorized transmitter is sighted for the first time
    [self sendBeaconDiscoveredNotification:[self.beaconDictionary objectForKey:visit.iBeacon.identifier]];
    NSLog(@"Beacon Found\nUUID: %@\nMajor: %@\nMinor: %@", visit.iBeacon.uuid, visit.iBeacon.major, visit.iBeacon.minor);
}

-(void)receivedIBeaconSighting:(FYXiBeaconVisit *)visit updateTime:(NSDate *)updateTime RSSI:(NSNumber *)RSSI {
    [self.secondaryStatusLabel setText:[NSString stringWithFormat:@"Last Updated: %@", [self.dateFormatter stringFromDate:updateTime]]];
    
    [self.dbLevels addObject:RSSI];
    [self.occurrenceTime addObject:updateTime];
    
    GCPBeacon *beacon = [self.beaconDictionary objectForKey:visit.iBeacon.identifier];
    if (!beacon) {
        NSLog(@"An Unknown Beacon Entered Range\nIdentifier:%@", visit.iBeacon.identifier);
        return;
    }
    
    beacon.rssi = [RSSI integerValue];
    beacon.accuracy = [visit.iBeacon.accuracy doubleValue];
    if ([visit.iBeacon.proximity isKindOfClass:[NSString class]]) {
        beacon.distance = visit.iBeacon.proximity;
    }
    else {
        visit.iBeacon.proximity = @"Unknown";
        beacon.distance = @"Unknown";
    }
    [beacon updateProximityReset];
    
    [self.tableView reloadData];
    
    // this will be invoked when an authorized transmitter is sighted during an on-going visit
    NSString *details = [NSString stringWithFormat:@"Received Signal\nUUID: %@\nSignal: %@db\nMajor: %@\nMinor: %@", visit.iBeacon.uuid, RSSI, visit.iBeacon.major, visit.iBeacon.minor];
    
    NSLog(@"%@", details);
    if (beacon.hasBeenReset && ([visit.iBeacon.proximity isEqualToString:@"Near"] || [visit.iBeacon.proximity isEqualToString:@"Immediate"])) {
        [self setPrimaryStatusLabelText:[NSString stringWithFormat:@"%@ In Range", beacon.name]];
        [self sendInRangeNotification:beacon];
    }
}

-(void)didDepartIBeacon:(FYXiBeaconVisit *)visit {
    [self setPrimaryStatusLabelText:@"A Beacon has exited range"];
    NSLog(@"Beacon was in proximity for %.4f seconds", visit.dwellTime);
}

#pragma mark TextField Delegate

- (IBAction)backgroundTapped:(id)sender {
    [self.view endEditing:YES];
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark Private

- (IBAction)viewGraph:(id)sender {
    GCPChartViewController *chart = [[GCPChartViewController alloc] initWithXValues:self.occurrenceTime YValues:self.dbLevels];
    [self.navigationController pushViewController:chart animated:YES];
}

-(void)sendInRangeNotification:(GCPBeacon *)beacon {
    NSDate *now = [NSDate date];
    
    NSTimeInterval timeSinceLastNotification = [now timeIntervalSinceDate:[beacon lastNotificationDate]];
    
    if (timeSinceLastNotification < 60) {
        NSLog(@"Notification Suppressed: %@ is Near", beacon.name);
        return;
    }
    
    beacon.lastNotificationDate = now;
    beacon.hasBeenReset = NO;
    
    [self sendNotificationWithMessage:[NSString stringWithFormat:@"%@ is Near", beacon.name]];
}

-(void)sendBeaconDiscoveredNotification:(GCPBeacon *)beacon {
    NSDate *now = [NSDate date];
    
    if (self.lastEntranceNotification) {
        NSTimeInterval timeSinceEntranceNotification = [now timeIntervalSinceDate:self.lastEntranceNotification];
        
        if (timeSinceEntranceNotification < kMaxNotificationFrequency) {
            [self setPrimaryStatusLabelText:[NSString stringWithFormat:@"%@ Was Discovered", beacon.name]];
            return;
        }
    }
    
    self.lastEntranceNotification = now;
    
    [self sendNotificationWithMessage:[NSString stringWithFormat:@"%@ Was Discovered", beacon.name]];
}

-(void)sendNotificationWithMessage:(NSString*)message {
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:@"Gimbal iBeacon SDK", @"classType", nil];
    notification.userInfo = dict;
    NSDate *now = [NSDate date];
    
    //one second delay gives the change to put the app in background
    NSDate *dateToFire = [now dateByAddingTimeInterval:1];
    
    [notification setFireDate:dateToFire];
    [notification setAlertBody:[NSString stringWithFormat:@"Gimbal iBeacon SDK: %@", message]];
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

-(void)setPrimaryStatusLabelText:(NSString*)status {
    if ([self.primaryStatusLabel.text isEqualToString:status])
        return;
    
    NSLog(@"%@", status);
    [self.primaryStatusLabel setText:status];
}

-(void)loadBeacons {
    _listOfBeacons = [[NSMutableArray alloc] init];
    GCPBeacon *beacon = [[GCPBeacon alloc] init];
    beacon.uuid = [[NSUUID alloc] initWithUUIDString:@"D133D6A0-1295-11E4-9191-0800200C9A66"];
    beacon.major = 1;
    beacon.minor = 1;
    beacon.name = @"Joseph's Gimbal";
    [beacon updateIdentifier];
    
    GCPBeacon *beacon2 = [[GCPBeacon alloc] init];
    beacon2.uuid = [[NSUUID alloc] initWithUUIDString:@"D133D6A0-1295-11E4-9191-0800200C9A66"];
    beacon2.major = 2;
    beacon2.minor = 1;
    beacon2.name = @"Quang's Gimbal";
    [beacon2 updateIdentifier];
    
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
    
    [self.listOfBeacons addObject:beacon];
    [self.listOfBeacons addObject:beacon2];
    [self.listOfBeacons addObject:beacon3];
    [self.listOfBeacons addObject:beacon4];
    [self.listOfBeacons addObject:beacon5];
    
    _beaconDictionary =[[NSMutableDictionary alloc] initWithObjectsAndKeys:beacon, beacon.identifier, beacon2, beacon2.identifier, beacon3, beacon3.identifier, beacon4, beacon4.identifier, beacon5, beacon5.identifier, nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

