//
//  dbTriplet.m
//  trove
//
//  Created by Michael Pfister on 2/15/14.
//  Copyright (c) 2014 Michael Pfister. All rights reserved.
//

#import "dbTriplet.h"

@implementation dbTriplet


- (float) distanceToTriplet:(dbTriplet *)other {
    // TODO: this should raelly be something that matches how decibels fall off
    return sqrt( pow(self.x-other.x, 2) + pow(self.y-other.y, 2) + pow(self.z-other.z, 2));
}

@end
