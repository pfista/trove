//
//  TroveModel.h
//  trove
//
//  Created by Michael Pfister on 2/15/14.
//  Copyright (c) 2014 Michael Pfister. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "dbTriplet.h"

@interface TroveModel : NSObject

enum TroveState {
    TroveSilent,
    TroveNearby,
    TroveGrowSmall,
    TroveGrowMedium,
    TroveFound
};
typedef enum TroveState TroveState;

@property (assign, nonatomic, readonly) NSInteger growRadius;
@property (assign, nonatomic) TroveState troveState;


typedef enum TroveState TroveState;

- (void) updateTroveFromBeacons:(NSArray *)beacons;

@end