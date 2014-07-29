//
//  GCPBeacon.m
//  Bluetooth Beacon Demo App
//
//  Created by Joseph Pecoraro on 7/28/14.
//  Copyright (c) 2014 Hatchery Lab, LLC. All rights reserved.
//

#import "GCPBeacon.h"

@implementation GCPBeacon

-(void)updateBeaconWithCLBeacon:(CLBeacon *)beacon {
    self.rssi = beacon.rssi;
    self.accuracy = beacon.accuracy;
    self.distance = [self nameForProximity:beacon.proximity];
}

-(void)updateIdentifier {
    self.identifier = [NSString stringWithFormat:@"%@:%zd:%zd", [self.uuid UUIDString], self.major, self.minor];
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
