//
//  TreasureModel.h
//  trove
//
//  Created by Michael Pfister on 2/15/14.
//  Copyright (c) 2014 Michael Pfister. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "dbTriplet.h"

@interface TreasureModel : NSObject

    // RSSI drop point
    // Image asset, text, video, audio, or money etc

@property (strong, nonatomic) dbTriplet *position;
@property (strong, nonatomic) UIImage *treasureImage;

@end
