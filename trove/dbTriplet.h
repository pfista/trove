//
//  dbTriplet.h
//  trove
//
//  Created by Michael Pfister on 2/15/14.
//  Copyright (c) 2014 Michael Pfister. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface dbTriplet : NSObject

@property (assign, nonatomic) float x;
@property (assign, nonatomic) float y;
@property (assign, nonatomic) float z;

- (float) distanceToTriplet:(dbTriplet *)other;


@end
