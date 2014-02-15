//
//  TroveModel.m
//  trove
//
//  Created by Michael Pfister on 2/15/14.
//  Copyright (c) 2014 Michael Pfister. All rights reserved.
//

#import "TroveModel.h"

/* This class contains information about a specific trove, basically a BeaconRegion. */
@interface TroveModel ()

@property (assign, nonatomic, readwrite) NSInteger growDiameter;
@property (strong, nonatomic, readwrite) NSUUID *uuid;
@property (strong, nonatomic, readwrite) NSNumber *major;
@property (strong, nonatomic, readwrite) NSNumber *minor;

@end

@implementation TroveModel


- (void) updateTroveState:(CLBeacon*) closest {
    // Based on the RSSI of each beacon, determine a new dbTriplet, compare with all the existing treasure models
    self.growDiameter = [self normalizeRSSI:closest.rssi];
    self.uuid = closest.proximityUUID;
    self.major = closest.major;
    self.minor = closest.minor;
    self.proximity = closest.proximity;
    

    
    // Look up info on parse and update treasure pictures arraw

    if (self.proximity == CLProximityImmediate){
        NSLog(@"Looking up parse");
    }

}


/* Take the closest of the three beacons and set state information based on that beacon */
- (void) updateTroveFromBeacons:(NSArray *)beacons {
    
    CLBeacon* closest = [beacons firstObject];

    for (int i = 1; i < beacons.count; i++){
        if ([self proximity:[beacons[i] proximity] closerThan:[closest proximity]]){
            closest = beacons[i];
        }
    }
    
    [self updateTroveState:closest];
}

// Map rssi from -50 (closest) to -90 (farthest) to 50-280.
- (float)normalizeRSSI:(float) rssi {
    NSLog([NSString stringWithFormat:@"RSSI: %f", rssi]);
    rssi = abs(rssi);
    rssi *= 1.5;
   // NSLog([NSString stringWithFormat:@"RSSInom: %f", rssi]);
    return rssi > 280 ? 280 : rssi;
}

- (BOOL)proximity:(CLProximity) prox1 closerThan:(CLProximity) prox2 {
    switch (prox1) {
        case CLProximityFar:
            switch (prox2) {
                case CLProximityFar:
                    return YES;
                case CLProximityUnknown:
                    return YES;
                case CLProximityImmediate:
                    return NO;
                case CLProximityNear:
                    return NO;
            }
        case CLProximityUnknown:
            switch (prox2) {
                case CLProximityFar:
                    return NO;
                case CLProximityUnknown:
                    return YES;
                case CLProximityImmediate:
                    return NO;
                case CLProximityNear:
                    return NO;
            }
        case CLProximityImmediate:
            switch (prox2) {
                case CLProximityFar:
                    return YES;
                case CLProximityUnknown:
                    return YES;
                case CLProximityImmediate:
                    return YES;
                case CLProximityNear:
                    return YES;
            }
        case CLProximityNear:
            switch (prox2) {
                case CLProximityFar:
                    return YES;
                case CLProximityUnknown:
                    return YES;
                case CLProximityImmediate:
                    return NO;
                case CLProximityNear:
                    return YES;
            }
    }
}

@end
