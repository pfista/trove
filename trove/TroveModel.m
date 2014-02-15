//
//  TroveModel.m
//  trove
//
//  Created by Michael Pfister on 2/15/14.
//  Copyright (c) 2014 Michael Pfister. All rights reserved.
//

#import "TroveModel.h"

@interface TroveModel ()

@property (assign, nonatomic, readwrite) NSInteger growRadius;
@property (strong, nonatomic) enum troveState;
@property (strong, nonatomic) NSMutableSet* beaconData;

@end

@implementation TroveModel


 // Keep track of what beacons a person has seen
 // Model should have a callback to view controller like update for stuff on screen (didUpdateAngel of arrow and size of circle)

// Lazy instantiation
- (NSMutableSet *)beaconData {
    if (!_beaconData){
        _beaconData = [[NSMutableSet alloc] init];
    }
    return _beaconData;
}

- (void) updateTroveState {
    
    
}

- (void)updateTroveFromBeacons:(NSArray *)beacons {
    
    // if ([self.beaconData containsObject:<#(id)#>
    
    
    [self updateTroveState];
}

@end
