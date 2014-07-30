//
//  GCPBeacon.m
//  Bluetooth Beacon Demo App
//
//  Created by Joseph Pecoraro on 7/28/14.
//  Copyright (c) 2014 Hatchery Lab, LLC. All rights reserved.
//

#import "GCPBeacon.h"

@implementation GCPBeacon

-(instancetype)init {
    self = [super init];
    if (self) {
        _timeHistory = [[NSMutableArray alloc] initWithCapacity:100];
        _rssiHistory = [[NSMutableArray alloc] initWithCapacity:100];
        _distanceHistory = [[NSMutableArray alloc] initWithCapacity:100];
        
        _timeFormatter = [[NSDateFormatter alloc] init];
        [self.timeFormatter setDateFormat:@"HH:mm:ss:SSS"];
    }
    return self;
}

-(void)updateBeaconWithCLBeacon:(CLBeacon *)beacon {
    self.rssi = beacon.rssi;
    self.accuracy = beacon.accuracy;
    self.distance = [self nameForProximity:beacon.proximity];
    
    if (self.writeAllInfo) {
        [self updateArrays];
    }
}

-(void)updateArrays {
    [self.rssiHistory addObject:[NSNumber numberWithInteger:self.rssi]];
    [self.distanceHistory addObject:[NSNumber numberWithDouble:self.accuracy]];
    [self.timeHistory addObject:[self.timeFormatter stringFromDate:[NSDate new]]];
    
    if ([self.rssiHistory count] == 100) {
        [self sendDataToServer];
        [self.rssiHistory removeAllObjects];
        [self.distanceHistory removeAllObjects];
        [self.timeHistory removeAllObjects];
    }
}

-(void)updateIdentifier {
    self.identifier = [NSString stringWithFormat:@"%@:%zd:%zd", [self.uuid UUIDString], self.major, self.minor];
}

-(void)updateProximityReset {
    if ([self.distance isEqualToString:@"Unknown"]) {
        self.hasBeenReset = YES;
    }
    else if ([self.distance isEqualToString:@"Far"]) {
        self.hasBeenReset = YES;
    }
}

-(NSString *)nameForProximity:(CLProximity)proximity {
    switch (proximity) {
        case CLProximityUnknown:
            self.hasBeenReset = YES;
            return @"Unknown";
            break;
        case CLProximityImmediate:
            return @"Immediate";
            break;
        case CLProximityNear:
            return @"Near";
            break;
        case CLProximityFar:
            self.hasBeenReset = YES;
            return @"Far";
            break;
    }
}

-(void)sendDataToServer {
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:self.identifier, @"beaconIdentifier", self.timeHistory, @"timeHistory", self.rssiHistory, @"rssiHistory", self.distanceHistory, @"distanceHistory", nil];
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
    [data writeToFile:[kBaseFilePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@:%@.json", self.identifier,[self.timeHistory lastObject]]] atomically:YES];
    NSLog(@"Data Sent To Server:\n%@", self.identifier);
    //send the data to the server
}

- (BOOL)isEqualToCLBeacon:(CLBeacon *)beacon {
    if ([[beacon.proximityUUID UUIDString] isEqualToString:[self.uuid UUIDString]] && [beacon.major isEqual: @(self.major)] && [beacon.minor isEqual: @(self.minor)]) {
        return YES;
    } else {
        return NO;
    }
}

-(NSString*)description {
    return [NSString stringWithFormat:@"Name: %@\nUUID:%@\nSignal: %zd\nMajor: %zd\nMinor: %zd\nDistance: %@\nAccuracy: +/- %.2fm", self.name, [self.uuid UUIDString], self.rssi, self.major, self.minor, self.distance, self.accuracy];
}

@end
