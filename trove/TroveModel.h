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

enum TroveState {
    TroveSilent,
    TroveNearby,
    TroveGrowSmall,
    TroveGrowMedium,
    TroveFound
};
typedef enum TroveState TroveState;


- (void) updateTroveFromBeacons:(NSArray *)beacons;

@end

