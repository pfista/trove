//
//  ViewController.m
//  trove
//
//  Created by Michael Pfister on 2/14/14.
//  Copyright (c) 2014 Michael Pfister. All rights reserved.
//

#import "MainViewController.h"
#import "ImageViewController.h"

@interface MainViewController ()

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

/* Placeholder icons $$$ */
@property (strong, nonatomic) NSMutableArray *treasureIcons;

@property (strong, nonatomic) IBOutlet UIButton *closeTroveGridButton;

/* Data model that talks to Parse */
@property (strong, nonatomic) TroveModel *troveModel;

/* Array of UIImageViews to help edit the UI */
@property (strong, nonatomic) NSMutableArray *troveImages;

/* State helpers */
@property (assign, nonatomic) BOOL hasInitTroveViewing;

@end

@implementation MainViewController
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
    
    for (UIImageView *imgView in self.troveImages) {
        imgView.layer.cornerRadius = 45.0f;
        imgView.clipsToBounds = YES;
    }
    
    self.treasureIcons = [[NSMutableArray alloc] init];
    [self.treasureIcons addObject:[UIImage imageNamed:@"icon1.png"]];
    [self.treasureIcons addObject:[UIImage imageNamed:@"icon2.png"]];
    [self.treasureIcons addObject:[UIImage imageNamed:@"icon3.png"]];
    [self.treasureIcons addObject:[UIImage imageNamed:@"icon4.png"]];
    [self.treasureIcons addObject:[UIImage imageNamed:@"icon5.png"]];
    [self.treasureIcons addObject:[UIImage imageNamed:@"icon6.png"]];
    [self.treasureIcons addObject:[UIImage imageNamed:@"icon7.png"]];
    [self.treasureIcons addObject:[UIImage imageNamed:@"icon8.png"]];
    
    // Set up our model
    self.troveModel = [[TroveModel alloc] init];
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"editSegue"]){
        NSLog(@" edit segue is good");
        ImageViewController *controller = (ImageViewController *)segue.destinationViewController;
        controller.troveModel = self.troveModel;
    }
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
    
    if (!self.troveModel.didQueryParse && !self.hasInitTroveViewing && self.troveModel.troveState == TroveSearching) {
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
                self.statusLabel.alpha = 1.0;
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
                self.statusLabel.alpha = 1.0;
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
    else if (!self.hasInitTroveViewing && self.troveModel.troveState == TroveViewing){
        [self initTroveViewing];
    }
    else {
       // NSLog(@"Searching.. but in viewing mode so ignore");
    }
}

- (void) initTroveViewing {

    NSLog(@"Init Trove Viewing");
    self.hasInitTroveViewing = YES;
    
    [UIView animateWithDuration:1.0 animations: ^ {
        self.foundTroverImage.alpha = 1.0;
        self.foundTroveLabel.alpha = 1.0;
        self.foundTroveSubLable.alpha = 1.0;
        self.closeTroveGridButton.alpha = 1.0;
        self.troverImage.alpha = 0;
        self.statusLabel.alpha = 0;
        self.circleImage.alpha = 0;
    }];
    int lowerBound = 0;
    int upperBound = 8;
    int rndValue = 0;
    // Load images from model

    for (int j = 0; j < self.troveModel.treasurePictures.count; j++){
        rndValue = lowerBound + arc4random() % (upperBound - lowerBound);
        [self.troveImages[j] setImage:self.treasureIcons[rndValue]];
        [self.troveImages[j] setEnabled:YES];
    }
    
    NSInteger count = (int)self.troveModel.treasurePictures.count;
    
    // Set the rest of the unused imageViews with button placeholders
    for (int i = (int)count; i < 9; i++ ){
        [self.troveImages[i] setImage:[UIImage imageNamed:@"add-placeholder"]];
        [self.troveImages[i] setEnabled:YES];
    }
    
    // Fade in all of the images
    for (UIImageView* imageView in self.troveImages) {
        [UIView animateWithDuration:2.0 animations: ^ {
            imageView.alpha = 1.0;
        }];
    }
    
}

- (void) initTroveSearching {
    if (self.troveModel.troveState == TroveViewing){
        NSLog(@"Init trove searching");
        [UIView animateWithDuration:1.0 animations: ^ {
            self.foundTroverImage.alpha = 0;
            self.foundTroveLabel.alpha = 0;
            self.foundTroveSubLable.alpha = 0;
            self.closeTroveGridButton.alpha = 0;
            self.troverImage.alpha = 0;
            self.statusLabel.alpha = 0;
            self.circleImage.alpha = 0;
            // Fade in all of the images
            for (UIImageView* imageView in self.troveImages) {
                imageView.alpha = 0;
            }
            self.troveModel.troveState = TroveSearching;
            self.hasInitTroveViewing = NO;
            self.troveModel.didQueryParse = NO;
        }];

        for (int i = 0; i < 9; i++) {
            [self.troveImages[i] setEnabled:NO];
        }

    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    
    if ([self.troveImages containsObject:[touch view]])
    {
        UIImageView *iv = [self.troveImages objectAtIndex: [self.troveImages indexOfObject:[touch view]]];
        [UIView animateWithDuration:.17 animations: ^ {
            iv.alpha = .25;
        }];
    }
    
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    
    if ([self.troveImages containsObject:[touch view]])
    {
        UIImageView *iv = [self.troveImages objectAtIndex: [self.troveImages indexOfObject:[touch view]]];
        [UIView animateWithDuration:.17 animations: ^ {
            iv.alpha = 1.0;
            
            if ([self.troveImages indexOfObject:[touch view]] <= self.troveImages.count) {
                [self pushSwitchViewController];
            }
            else {
                [self pushImageViewController];
            }
            
        }];
    }
    
}
- (IBAction)pushSwitchViewController
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ImageViewController *ivc = [storyboard instantiateViewControllerWithIdentifier:@"troveSwitchController"];
    [ivc setModalPresentationStyle:UIModalPresentationFullScreen];
    
    UIStoryboardSegue *segue = [[UIStoryboardSegue alloc]initWithIdentifier:@"switchSegue" source:self destination:ivc];
    [self prepareForSegue:segue sender:self];
    [self performSegueWithIdentifier:@"switchSegue" sender:self];
    
}


- (IBAction)pushImageViewController
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ImageViewController *ivc = [storyboard instantiateViewControllerWithIdentifier:@"troveImageController"];
    [ivc setModalPresentationStyle:UIModalPresentationFullScreen];
    
    UIStoryboardSegue *segue = [[UIStoryboardSegue alloc]initWithIdentifier:@"addSegue" source:self destination:ivc];
    [self prepareForSegue:segue sender:self];
    [self performSegueWithIdentifier:@"addSegue" sender:self];

}

- (void)dismissImageViewController {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ImageViewController *ivc = [storyboard instantiateViewControllerWithIdentifier:@"troveSwitchController"];
    [ivc dismissViewControllerAnimated:YES completion:nil];
}

@end
