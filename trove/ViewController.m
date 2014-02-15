//
//  ViewController.m
//  trove
//
//  Created by Michael Pfister on 2/14/14.
//  Copyright (c) 2014 Michael Pfister. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *troverImage;
@property (strong, nonatomic) UIImage *sadTrover;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@property (assign, nonatomic) CGPoint middle;
@property (assign, nonatomic) CGPoint troverImagePosition;
@property (strong, nonatomic) TroveModel *troveModel;
@property (weak, nonatomic) IBOutlet UILabel *instructionLabel;
@property (strong, nonatomic) IBOutlet UIImageView *circleImage;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self initRegion];
    
    self.sadTrover = [UIImage imageNamed:@"trover_sad"];
    self.troverImage.image = self.sadTrover;
    
    // Manually call this for testing purposes TODO
    [self locationManager:self.locationManager didStartMonitoringForRegion:self.beaconRegion];
    
    // Set idempotent positions for UI transitions
    self.troverImagePosition = CGPointMake(self.troverImage.center.x, self.troverImage.center.y);
    self.middle = CGPointMake(self.troverImage.center.x, self.troverImage.center.y+40);
    
    self.statusLabel.center = self.middle;
    
    // Set up our model
    self.troveModel = [[TroveModel alloc] init];
    
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
}

- (void)initRegion {
    // Register with Estimote beacons
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:TROVE_UUID];
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:@"io.pfista.trove"];
    [self.locationManager startMonitoringForRegion:self.beaconRegion];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.alertBody = @"You are near a trove! Hold your phone against it.";
    notification.alertAction = @"Explore";
    [[UIApplication sharedApplication] scheduleLocalNotification: notification];
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    [self.locationManager stopRangingBeaconsInRegion:self.beaconRegion];
}

// This should send updated information to the model and let the model handle state information etc
- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {

    
    [self.troveModel updateTroveFromBeacons:beacons];
    
    if (self.troveModel)
    
    else if (self.troveModel.proximity == CLProximityUnknown){
        [UIView animateWithDuration:0.5 animations: ^ {
            // Show sad trover
            self.troverImage.center = self.troverImagePosition;
            self.troverImage.image = self.sadTrover;
            self.troverImage.alpha = 1.0;
            
            // Let user know they aren't near a tove
            self.statusLabel.center = self.middle;
            self.statusLabel.text = @"no trove nearby";
            
            // Don't show the circle image
            self.circleImage.alpha = 0;
           
        }];
        
    }
    else if (self.troveModel.proximity == CLProximityFar){
        [UIView animateWithDuration:0.5 animations: ^ {
            // Move trover image up, visible,
            self.troverImage.alpha = 0.0;
            
            // Move the status label to the center
            self.statusLabel.center = self.middle;
            self.statusLabel.text = @"closer...";

            // Show a smaller, transparent circle
            self.circleImage.alpha = 0.7;
            self.circleImage.bounds = CGRectMake(self.circleImage.center.x, self.circleImage.center.y, 120, 120);
        }];

    }
    else if (self.troveModel.proximity == CLProximityNear){
        [UIView animateWithDuration:1.0 animations: ^ {
            
            // Don't the trover
            self.troverImage.alpha = 0.0;

            self.statusLabel.text = @"Hot!";
            self.statusLabel.center = self.middle;
            
            // Show a big, opaque circle
            self.circleImage.alpha = 1.0;
            self.circleImage.bounds = CGRectMake(self.circleImage.center.x, self.circleImage.center.y, 280, 280);
        }];
        
    }
    else if (self.troveModel.proximity == CLProximityImmediate){
        [UIView animateWithDuration:0.3 animations: ^ {
            self.troverImage.alpha = 0;
            
            self.statusLabel.center = self.middle;
            self.statusLabel.text = @"show parse stuff";
            
            self.circleImage.alpha = 0;
            
             // TODO: show a new view for the info from parse here.

        }];
        
    }

    self.instructionLabel.text = [NSString stringWithFormat:@"M: %@ m:%@", self.troveModel.major, self.troveModel.minor];

}

@end
