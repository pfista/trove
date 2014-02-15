//
//  TroveModel.m
//  trove
//
//  Created by Michael Pfister on 2/15/14.
//  Copyright (c) 2014 Michael Pfister. All rights reserved.
//

#import "TroveModel.h"

@import CoreLocation;

/* This class contains information about a specific trove, basically a BeaconRegion.  Each trove
 can have several treasures inside of it. */
@interface TroveModel ()

@property (assign, nonatomic, readwrite) NSInteger growRadius;
@property (strong, nonatomic) NSArray* beaconData;

@end

@implementation TroveModel

 // Keep track of what beacons a person has seen
 // Model should have a callback to view controller like update for stuff on screen (didUpdateAngel of arrow and size of circle)

// Lazy instantiation
- (NSArray *)beaconData {
    if (!_beaconData){
        _beaconData = [[NSArray alloc] init];
    }
    return _beaconData;
}

- (void) updateTroveState {
    // Based on the RSSI of each beacon, determine a new dbTriplet, compare with all the existing treasure models
    if (self.beaconData.count) {
        dbTriplet* dbT = [[dbTriplet alloc] init];
        dbT.x = [self.beaconData[0] rssi];
        dbT.y = [self.beaconData[1] rssi];
        dbT.z = [self.beaconData[2] rssi];
        NSLog(@"Just added dbt values");
        NSLog([NSString stringWithFormat:@"%f %f %f", dbT.x, dbT.y, dbT.z]);
        
        dbTriplet* test = [[dbTriplet alloc] init];
        test.x = -60;
        test.y = -77;
        test.z = -80;
        NSLog(@"Distance to triplet -60, -77, -80");
        float distance = [test distanceToTriplet:dbT];
        NSLog([NSString stringWithFormat:@"%f",distance]);
        
        if (distance <= 12){
            self.troveState = TroveFound;
        }
        else if (distance > 12 && distance <= 30){
            self.troveState = TroveGrowMedium;
        }
        else if (distance > 30 && distance <= 65){
            self.troveState = TroveGrowSmall;
        }
        else if (distance > 65 && distance <= 95){
            self.troveState = TroveNearby;
        }
        else if (distance > 95) {
            self.troveState = TroveSilent;
        }
        self.growRadius = distance;
        
    }
}

- (void) updateTroveFromBeacons:(NSArray *)beacons {
    self.beaconData = beacons;
    [self updateTroveState];
}

@end
