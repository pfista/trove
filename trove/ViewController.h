//
//  ViewController.h
//  trove
//
//  Created by Michael Pfister on 2/14/14.
//  Copyright (c) 2014 Michael Pfister. All rights reserved.
//

#import <UIKit/UIKit.h>
@import CoreLocation;

@interface ViewController : UIViewController <CLLocationManagerDelegate>

@property (strong, nonatomic) CLBeaconRegion *beaconRegion;
@property (strong, nonatomic) CLLocationManager *locationManager;

@end
