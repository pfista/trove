//
//  TroveModel.h
//  trove
//
//  Created by Michael Pfister on 2/15/14.
//  Copyright (c) 2014 Michael Pfister. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TroveModel : NSObject

@property (assign, nonatomic, readonly) NSInteger growRadius;

enum troveState {
    troveSilent,
    troveNearby,
    troveGrowSmall,
    troveGrowMedium,
    troveFound
};


- (void) updateTroveFromBeacons:(NSArray *)beacons;

@end

