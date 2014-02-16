//
//  ViewController.h
//  trove
//
//  Created by Michael Pfister on 2/14/14.
//  Copyright (c) 2014 Michael Pfister. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "TroveModel.h"
#import "ImageViewController.h"

@import CoreLocation;
@import QuartzCore;

@interface MainViewController : UIViewController <CLLocationManagerDelegate,  ImageViewDelegate>

@property (strong, nonatomic) CLBeaconRegion *beaconRegion;
@property (strong, nonatomic) CLLocationManager *locationManager;

@end
