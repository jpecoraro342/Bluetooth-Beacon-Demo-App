//
//  GCPBeacon.h
//  Bluetooth Beacon Demo App
//
//  Created by Joseph Pecoraro on 7/28/14.
//  Copyright (c) 2014 Hatchery Lab, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface GCPBeacon : NSObject

@property (nonatomic, copy) NSString *identifier;

@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSUUID *uuid;
@property (nonatomic, assign) NSInteger major;
@property (nonatomic, assign) NSInteger minor;

@property (nonatomic, assign) NSInteger rssi;
@property (nonatomic, copy) NSString *distance;
@property (nonatomic, assign) double accuracy;

@property (nonatomic, assign) BOOL hasBeenReset;
@property (nonatomic, strong) NSDate *lastNotificationDate;

@property (nonatomic, strong) NSMutableArray *timeHistory;
@property (nonatomic, strong) NSMutableArray *rssiHistory;
@property (nonatomic, strong) NSMutableArray *distanceHistory;

@property (nonatomic, strong) NSDateFormatter *timeFormatter;

-(void)updateBeaconWithCLBeacon:(CLBeacon *)beacon;
-(BOOL)isEqualToCLBeacon:(CLBeacon *)beacon;
-(void)updateIdentifier;

@end
