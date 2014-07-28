//
//  GCPGimbalIBeaconViewController.m
//  Bluetooth Beacon Demo App
//
//  Created by Joseph Pecoraro on 7/25/14.
//  Copyright (c) 2014 Hatchery Lab, LLC. All rights reserved.
//

#import "GCPGimbalIBeaconViewController.h"
#import "GCPChartViewController.h"
#import <FYX/FYX.h>
#import <FYX/FYXVisitManager.h>
#import <FYX/FYXTransmitter.h>

@interface GCPGimbalIBeaconViewController () <FYXServiceDelegate, FYXiBeaconVisitDelegate, UITextFieldDelegate>

@property (nonatomic, strong) FYXVisitManager *visitManager;
@property (weak, nonatomic) IBOutlet UILabel *primaryStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondaryStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *singleBeaconLabel;
@property (nonatomic, assign) NSInteger lastFiredNotification; //0 = no notification/reset 1 = Hot 2 = Cold

@property (nonatomic, strong) NSDate *lastInRangeNotification;
@property (nonatomic, strong) NSDate *lastOutOfRangeNotification;

@property (nonatomic, assign) NSInteger entranceDB;
@property (nonatomic, assign) NSInteger exitDB;

@property (nonatomic, strong) NSMutableArray *dbLevels; //y values
@property (nonatomic, strong) NSMutableArray *occurrenceTime; //x values

@end

@implementation GCPGimbalIBeaconViewController

-(instancetype)init {
    self = [super init];
    if (self) {
        self.entranceDB = -65;
        self.exitDB = -80;
        _dbLevels = [[NSMutableArray alloc] init];
        _occurrenceTime = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [FYX startService:self];
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
    NSLog(@"\n\nVisit IBeacon: \n%@\n\n", visit.iBeacon);
    // this will be invoked when an authorized transmitter is sighted for the first time
    [self setPrimaryStatusLabelText:@"A beacon has been discovered"];
    [self sendNotificationWithMessage:@"A Beacon Has Been Discovered"];
    NSLog(@"\nBeacon Found\nName: %@\nTemperature: %@\nBattery: %@\n\n", visit.iBeacon.identifier, visit.iBeacon.major, visit.iBeacon.minor);
}

-(void)receivedIBeaconSighting:(FYXiBeaconVisit *)visit updateTime:(NSDate *)updateTime RSSI:(NSNumber *)RSSI {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterNoStyle];
    [dateFormatter setTimeStyle:NSDateFormatterLongStyle];
    [self.secondaryStatusLabel setText:[NSString stringWithFormat:@"Last Updated: %@", [dateFormatter stringFromDate:updateTime]]];
    
    [self.dbLevels addObject:RSSI];
    [self.occurrenceTime addObject:updateTime];
    
    // this will be invoked when an authorized transmitter is sighted during an on-going visit
    NSString *details = [NSString stringWithFormat:@"Received Signal\nUUID: %@\nSignal: %@db\nMajor: %@f\nMinor: %@", visit.iBeacon.identifier, RSSI, visit.iBeacon.major, visit.iBeacon.minor];
    [self.singleBeaconLabel setText:details];
    [self.singleBeaconLabel sizeToFit];
    
    NSLog(@"\n%@\n\n", details);
    if ([RSSI integerValue] > self.entranceDB) {
        [self setPrimaryStatusLabelText:@"Beacon In Range"];
        
        if (self.lastFiredNotification == 1)
            return;
        
        self.lastFiredNotification = 1;
        [self sendInRangeNotification];
    }
    else if ([RSSI integerValue] < self.exitDB) {
        [self setPrimaryStatusLabelText:@"Beacon Out of Range"];
        
        if (self.lastFiredNotification == 2)
            return;
        
        self.lastFiredNotification = 2;
        
        [self sendOutOfRangeNotification];
    }
    else {
        if (self.lastFiredNotification == 0)
            return;
        
        NSLog(@"Beacon Signal Notification Reset\n\n");
        self.lastFiredNotification = 0;
    }
}

-(void)didDepartIBeacon:(FYXiBeaconVisit *)visit {
    [self setPrimaryStatusLabelText:[NSString stringWithFormat:@"Beacon: %@ has exited range\n", visit.iBeacon.identifier]];
    NSLog(@"Beacon was in proximity for %.4f seconds\n\n", visit.dwellTime);
}

#pragma mark TextField Delegate

- (IBAction)backgroundTapped:(id)sender {
    [self.view endEditing:YES];
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark Keyboard Adjustment

//register keyboard notification
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

//remove keyboard notification observer
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

//show/hide the keyboard
- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    CGSize kbSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:0.3 animations:^{
        CGRect f = self.view.frame;
        f.origin.y -= kbSize.height/2 + 10;
        self.view.frame = f;
    }];
}

-(void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    CGSize kbSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:0.3 animations:^{
        CGRect f = self.view.frame;
        f.origin.y += kbSize.height/2 + 10;
        self.view.frame = f;
    }];
}

#pragma mark Private

- (IBAction)viewGraph:(id)sender {
    GCPChartViewController *chart = [[GCPChartViewController alloc] initWithXValues:self.occurrenceTime YValues:self.dbLevels];
    [self.navigationController pushViewController:chart animated:YES];
}

-(void)sendInRangeNotification {
    NSDate *now = [NSDate date];
    
    if (self.lastInRangeNotification) {
        NSTimeInterval timeSinceLastInRangeNotification = [now timeIntervalSinceDate:self.lastInRangeNotification];
        
        if (timeSinceLastInRangeNotification < 60) {
            NSLog(@"\nIn range notification suppressed\n\n");
            return;
        }
    }
    
    self.lastInRangeNotification = now;
    
    [self sendNotificationWithMessage:@"Beacon In Range"];
}

-(void)sendOutOfRangeNotification {
    NSDate *now = [NSDate date];
    
    if (self.lastOutOfRangeNotification) {
        NSTimeInterval timeSinceLastOutOfRangeNotification = [now timeIntervalSinceDate:self.lastOutOfRangeNotification];
        
        if (timeSinceLastOutOfRangeNotification < 60) {
            NSLog(@"\nOut of range notification suppressed\n\n");
            return;
        }
    }
    
    self.lastOutOfRangeNotification = now;
    
    [self sendNotificationWithMessage:@"Beacon Out of Range"];
}

-(void)sendNotificationWithMessage:(NSString*)message {
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    NSDate *now = [NSDate date];
    
    //one second delay gives the change to put the app in background
    NSDate *dateToFire = [now dateByAddingTimeInterval:1];
    
    [notification setFireDate:dateToFire];
    [notification setAlertBody:message];
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

-(void)setPrimaryStatusLabelText:(NSString*)status {
    if ([self.primaryStatusLabel.text isEqualToString:status])
        return;
    
    NSLog(@"\n%@\n\n", status);
    [self.primaryStatusLabel setText:status];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

