//
//  ViewController.m
//  trove
//
//  Created by Michael Pfister on 2/14/14.
//  Copyright (c) 2014 Michael Pfister. All rights reserved.
//

#import "ViewController.h"


@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) UIImage *sadTrover;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@property (assign, nonatomic) CGPoint middle;
@property (assign, nonatomic) CGPoint searching;
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
    self.imageView.image = self.sadTrover;
    
    // Manually call this for testing purposes TODO
    [self locationManager:self.locationManager didStartMonitoringForRegion:self.beaconRegion];
    
    // Set idempotent positions for UI transitions
    self.searching = CGPointMake(self.imageView.center.x, self.imageView.center.y);
    self.middle = CGPointMake(self.imageView.center.x, self.imageView.center.y+20);
    
    // Set up our model
    self.troveModel = [[TroveModel alloc] init];
    
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
}

- (void)initRegion {
    // Register with Estimote beacons
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D"];
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
    if (self.troveModel.proximity == CLProximityUnknown){
        [UIView animateWithDuration:0.3 animations: ^ {
            self.imageView.center = self.searching;
            self.imageView.image = self.sadTrover;
            self.circleImage.alpha = 0;
            self.imageView.alpha = 1.0;
            self.statusLabel.center = CGPointMake(self.searching.x, self.searching.y+40);
            self.statusLabel.text = @"no trove nearby";
        }];
        
    }
    else if (self.troveModel.proximity == CLProximityFar){
        
        [UIView animateWithDuration:0.5 animations: ^ {
            self.imageView.center = CGPointMake(self.middle.x, self.middle.y-70);
            self.imageView.alpha = 1.0;
            self.circleImage.alpha = 1.0;
            self.statusLabel.center = self.middle;
            
            self.imageView.image = [UIImage imageNamed:@"trover_happy"];
            self.statusLabel.text = @"closer";
            self.imageView.alpha = 0.0;
            self.circleImage.alpha = 1.0;
            self.circleImage.bounds = CGRectMake(self.circleImage.center.x, self.circleImage.center.y, self.troveModel.growDiameter, self.troveModel.growDiameter);
        }];
           
            [UIView animateWithDuration:0.3 animations: ^ {
                self.imageView.center = self.searching;
                self.imageView.center = CGPointMake(self.searching.x, self.searching.y+40);
                self.statusLabel.text = @"prox far";
            }];
            [UIView animateWithDuration:0.18 animations: ^ {
                self.imageView.center = CGPointMake(self.searching.x, self.searching.y-10);
            }];
            [UIView animateWithDuration:0.18 animations: ^ {
                self.imageView.center = self.searching;
            }];
            


    }
    else if (self.troveModel.proximity == CLProximityNear){
        [UIView animateWithDuration:1.0 animations: ^ {
            float diameter = self.troveModel.growDiameter*2 > 280 ? 280 : self.troveModel.growDiameter*2;
            self.imageView.image = [UIImage imageNamed:@"trover_happy"];
            self.statusLabel.text = @"prox near";
            self.imageView.alpha = 0.0;
            self.circleImage.alpha = 1.0;
            self.circleImage.bounds = CGRectMake(self.circleImage.center.x, self.circleImage.center.y, diameter, diameter);
        }];
        
    }
    else if (self.troveModel.proximity == CLProximityImmediate){
        [UIView animateWithDuration:0.3 animations: ^ {
            self.imageView.center = self.middle;
            self.imageView.alpha = 0;
            self.circleImage.alpha = 0;
            self.statusLabel.center = self.middle;
            self.statusLabel.text = @"** treasure **";
        }];
        
    }

    self.instructionLabel.text = [NSString stringWithFormat:@"M: %@ m:%@", self.troveModel.major, self.troveModel.minor];
    
    // If we have three beacons registering far
        // Say there are troves nearby
        // If any number of those beacons is near, draw an arrow pointing to it
            // If immediately close, do the treasure trove

}

@end
