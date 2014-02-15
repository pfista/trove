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
@property (assign, nonatomic) BOOL didQueryParse;


@end

@implementation TroveModel


NSString* const TROVE_UUID = @"B9407F30-F5F8-466E-AFF9-25556B57FE6D";
NSString* const PLATFORM = @"iOS";


- (void) updateTroveState:(CLBeacon*) closest {
    self.uuid = closest.proximityUUID;
    self.major = closest.major;
    self.minor = closest.minor;
    self.proximity = closest.proximity;
    
    NSLog([NSString stringWithFormat:@"%@, %@", self.major, self.minor]);
    
    // Look up info on parse and update treasure pictures arraw

    if (!self.didQueryParse && self.proximity == CLProximityNear){
        self.troveState = TroveViewing;
        PFQuery *query = [PFQuery queryWithClassName:@"cache"];
        query.cachePolicy = kPFCachePolicyNetworkElseCache;
        [query whereKey:@"UUID" equalTo:TROVE_UUID];
        [query whereKey:@"major" equalTo:self.major];
        [query whereKey:@"minor" equalTo:self.minor];
        [query whereKey:@"platform" equalTo:PLATFORM];
         query.limit = 9;
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                // The find succeeded.
                NSLog(@"Successfully retrieved %lu entries in trove (%@, %@).", (unsigned long)objects.count, self.major, self.minor);
                
                // Do something with the found objects
                for (PFObject *object in objects) {
                    NSLog(@"%@", object.objectId);
                }
            } else {
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
        
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

- (BOOL)proximity:(CLProximity) prox1 closerThan:(CLProximity) prox2 {
    switch (prox1) {
        case CLProximityFar:
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
        case CLProximityUnknown:
            switch (prox2) {
                case CLProximityFar:
                    return NO;
                case CLProximityUnknown:
                    return NO;
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
                    return NO;
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
                    return NO;
            }
    }
}

@end
