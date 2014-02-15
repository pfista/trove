//
//  TroveModel.m
//  trove
//
//  Created by Michael Pfister on 2/15/14.
//  Copyright (c) 2014 Michael Pfister. All rights reserved.
//

#import "TroveModel.h"
@import CoreLocation;

@interface TroveModel ()

@property (assign, nonatomic, readwrite) NSInteger growRadius;
@property (assign, nonatomic) TroveState troveState;
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
    
}

- (void)updateTroveFromBeacons:(NSArray *)beacons {
    self.beaconData = beacons;
    [self updateTroveState];
}

@end
