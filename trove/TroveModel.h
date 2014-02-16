
//
//  TroveModel.h
//  trove
//
//  Created by Michael Pfister on 2/15/14.
//  Copyright (c) 2014 Michael Pfister. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Parse/Parse.h"
@import CoreLocation;

@interface TroveModel : NSObject

enum TroveState {
    TroveSearching,
    TroveViewing
};
typedef enum TroveState TroveState;

extern NSString *const TROVE_UUID;
extern NSString *const PLATFORM;

@property (assign) CLProximity proximity;
@property (strong, nonatomic) NSMutableArray* treasurePictures;
@property (strong, nonatomic, readonly) NSUUID *uuid;
@property (strong, nonatomic, readonly) NSNumber *major;
@property (strong, nonatomic, readonly) NSNumber *minor;\
@property (assign) TroveState troveState;
@property (assign, nonatomic) BOOL didQueryParse;

- (void) updateTroveFromBeacons:(NSArray *)beacons;

@end