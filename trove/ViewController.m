//
//  ViewController.m
//  trove
//
//  Created by Michael Pfister on 2/14/14.
//  Copyright (c) 2014 Michael Pfister. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

/* Assets for state TroveSearching */
@property (weak, nonatomic) IBOutlet UIImageView *troverImage;
@property (strong, nonatomic) UIImage *sadTrover;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (strong, nonatomic) IBOutlet UIImageView *circleImage;

/* Positions for some elements */
@property (assign, nonatomic) CGPoint middle;
@property (assign, nonatomic) CGPoint troverImagePosition;

/* ImageViews for viewing a trove */
@property (strong, nonatomic) IBOutlet UIImageView *troveImage1;
@property (strong, nonatomic) IBOutlet UIImageView *troveImage2;
@property (strong, nonatomic) IBOutlet UIImageView *troveImage3;
@property (strong, nonatomic) IBOutlet UIImageView *troveImage4;
@property (strong, nonatomic) IBOutlet UIImageView *troveImage5;
@property (strong, nonatomic) IBOutlet UIImageView *troveImage6;
@property (strong, nonatomic) IBOutlet UIImageView *troveImage7;
@property (strong, nonatomic) IBOutlet UIImageView *troveImage8;
@property (strong, nonatomic) IBOutlet UIImageView *troveImage9;
@property (strong, nonatomic) IBOutlet UIImageView *foundTroverImage;
@property (strong, nonatomic) IBOutlet UILabel *foundTroveLabel;
@property (strong, nonatomic) IBOutlet UILabel *foundTroveSubLable;

@property (strong, nonatomic) IBOutlet UIButton *closeTroveGridButton;

/* Data model that talks to Parse */
@property (strong, nonatomic) TroveModel *troveModel;

/* Array of UIImageViews to help edit the UI */
@property (strong, nonatomic) NSMutableArray *troveImages;

/* State helpers */
@property (assign, nonatomic) BOOL hasInitTroveViewing;

@end

@implementation ViewController
- (IBAction)closeTroveButtonAction:(id)sender {
    [self initTroveSearching];
}

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
    
    // Add the basic emptt trove images to an array for easier updating later
    self.troveImages = [[NSMutableArray alloc] init];
    [self.troveImages addObject:self.troveImage1];
    [self.troveImages addObject:self.troveImage2];
    [self.troveImages addObject:self.troveImage3];
    [self.troveImages addObject:self.troveImage4];
    [self.troveImages addObject:self.troveImage5];
    [self.troveImages addObject:self.troveImage6];
    [self.troveImages addObject:self.troveImage7];
    [self.troveImages addObject:self.troveImage8];
    [self.troveImages addObject:self.troveImage9];
    
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

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
    if (self.hasInitTroveViewing && self.troveModel.troveState == TroveSearching){
        [self initTroveSearching];
    }
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.alertBody = @"You are near a trove! Hold your phone against it.";
    notification.alertAction = @"Explore";
    [[UIApplication sharedApplication] scheduleLocalNotification: notification];
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    [self.locationManager stopRangingBeaconsInRegion:self.beaconRegion];
}

// This should send updated information to the model and let the model handle state information etc
- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {

    [self.troveModel updateTroveFromBeacons:beacons];
    
    if (self.troveModel.troveState == TroveSearching) {
        if (self.troveModel.proximity == CLProximityUnknown){
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
                
                // Prepare for viewing mode
                self.troverImage.alpha = 0;
                
                self.statusLabel.center = self.middle;
                self.statusLabel.alpha = 0;
                self.statusLabel.text = @"";
                
                self.circleImage.alpha = 0;

            }];
            
        }
    }
    else if (self.troveModel.troveState == TroveViewing){
        
        if (!self.hasInitTroveViewing){
            [self initTroveViewing];
        }
        
    }

}

- (void) initTroveViewing {
    [UIView animateWithDuration:1.0 animations: ^ {
        self.foundTroverImage.alpha = 1.0;
        self.foundTroveLabel.alpha = 1.0;
        self.foundTroveSubLable.alpha = 1.0;
        self.closeTroveGridButton.alpha = 1.0;
        self.troverImage.alpha = 0;
        self.statusLabel.alpha = 0;
        self.circleImage.alpha = 0;
    }];
    
    // Load images from model
    int i = 0;
    for (UIImage *picture in self.troveModel.treasurePictures) {
        [self.troveImages[i++] setImage:picture];
        NSLog(@"Adding actual image");
    }
    
    // Set the rest of the unused imageViews with button placeholders
    while (i < 9){
        [self.troveImages[i++] setImage:[UIImage imageNamed:@"add-placeholder"]];
        NSLog(@"Adding placeholder iamge");
        // TODO: register these images for clicks
    }
    
    // Fade in all of the images
    for (UIImageView* imageView in self.troveImages) {
        [UIView animateWithDuration:2.0 animations: ^ {
            imageView.alpha = 1.0;
        }];
    }
    self.hasInitTroveViewing = YES;
    [self.locationManager stopRangingBeaconsInRegion:self.beaconRegion];
}

- (void) initTroveSearching {
    [UIView animateWithDuration:1.0 animations: ^ {
        self.foundTroverImage.alpha = 0;
        self.foundTroveLabel.alpha = 0;
        self.foundTroveSubLable.alpha = 0;
        self.closeTroveGridButton.alpha = 0;
        self.troverImage.alpha = 1;
        self.statusLabel.alpha = 1;
        self.circleImage.alpha = 1;
        // Fade in all of the images
        for (UIImageView* imageView in self.troveImages) {
            imageView.alpha = 0;
        }
    }];
    self.hasInitTroveViewing = NO;
    self.troveModel.didQueryParse = NO;
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
    self.troveModel.troveState = TroveSearching;
}

@end
