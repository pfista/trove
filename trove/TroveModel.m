//
//  TroveModel.m
//  trove
//
//  Created by Michael Pfister on 2/15/14.
//  Copyright (c) 2014 Michael Pfister. All rights reserved.
//

#import "TroveModel.h"

/* This class contains information about a specific trove, basically a BeaconRegion. */
@interface TroveModel ()

@property (assign, nonatomic, readwrite) NSInteger growDiameter;
@property (strong, nonatomic, readwrite) NSUUID *uuid;
@property (strong, nonatomic, readwrite) NSNumber *major;
@property (strong, nonatomic, readwrite) NSNumber *minor;

@end

@implementation TroveModel


NSString* const TROVE_UUID = @"B9407F30-F5F8-466E-AFF9-25556B57FE6D";
NSString* const PLATFORM = @"iOS";

- (NSMutableArray *)treasurePictures {
    if (!_treasurePictures){
        _treasurePictures = [[NSMutableArray alloc] init];
    }
    return _treasurePictures;
}

- (void) updateTroveState:(CLBeacon*) closest {
    self.uuid = closest.proximityUUID;
    self.major = closest.major;
    self.minor = closest.minor;
    self.proximity = closest.proximity;
    
    //NSLog([NSString stringWithFormat:@"%@, %@", self.major, self.minor]);
    
    // Look up info on parse and update treasure pictures arraw

    if (!self.didQueryParse && self.proximity == CLProximityImmediate){
        //NSLog(@"diqueryparse is false, and proximity is immediate");
        self.didQueryParse = YES;

        PFQuery *query = [PFQuery queryWithClassName:@"cache"];
        [PFQuery clearAllCachedResults];
        query.cachePolicy = kPFCachePolicyNetworkOnly;
        [query whereKey:@"UUID" equalTo:TROVE_UUID];
        [query whereKey:@"major" equalTo:self.major];
        [query whereKey:@"minor" equalTo:self.minor];
        [query whereKey:@"platform" equalTo:PLATFORM];
         query.limit = 9;
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
               
                // The find succeeded.
                NSLog(@"Successfully retrieved %lu entries in trove (%@, %@).", (unsigned long)objects.count, self.major, self.minor);
                [self.treasurePictures removeAllObjects];

                // Do something with the found objects
                for (PFObject *object in objects) {
                    // Object was downloaded, we still need to get the PFFile
                    
                    PFFile *imageFile = [object objectForKey:@"pictureFile"];
                    [imageFile getDataInBackgroundWithBlock:^(NSData *result, NSError *error) {
                        if (result) {
                            NSData* data = [[NSData alloc] initWithData:result];
                            UIImage *image = [UIImage imageWithData:data];
                            if (image){
                                NSLog(@"Addig image");
                                [self.treasurePictures addObject:image];
                                if (self.treasurePictures.count == objects.count){
                                    self.troveState = TroveViewing;

                                }
                            }
                        }
                    }];
                }
                if (self.treasurePictures.count == 0){
                    // No treasures were found
                    self.troveState = TroveViewing;
                }
            } else {
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
        
    }
}

/* Take the closest of the three beacons and set state information based on that beacon */
- (void) updateTroveFromBeacons:(NSArray *)beacons {
    
    CLBeacon* closest = [beacons firstObject];

    for (int i = 1; i < beacons.count; i++){
        if ([self proximity:[beacons[i] proximity] closerThan:[closest proximity]]){
            closest = beacons[i];
        }
    }
    
    [self updateTroveState:closest];
}

-(void) uploadImage:(UIImage *)image {
    // Parse query to upload image based on connected beacon
    // Check state info before proceeding
    if (!image) {
        NSLog(@"LOST IMAGE");
    }
    else {
        NSLog(@"attempting to save");
    }
    NSData *imageData = UIImagePNGRepresentation(image);
    PFFile *imageFile = [PFFile fileWithName:@"image.png" data:imageData];
    	
    
    PFObject *userPhoto = [PFObject objectWithClassName:@"cache"];
    [userPhoto setObject:self.major forKey:@"major"];
    [userPhoto setObject:self.minor forKey:@"minor"];
    [userPhoto setObject:TROVE_UUID
                  forKey:@"UUID"];
    [userPhoto setObject:PLATFORM forKey:@"platform"];
    userPhoto[@"pictureFile"] = imageFile;
    [userPhoto saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error){
             NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
        else {
            NSLog(@"Success?");
        }
    }];
}

- (void) replaceImage:(UIImage *)image {
    
    PFQuery *query = [PFQuery queryWithClassName:@"cache"];
    [PFQuery clearAllCachedResults];
    query.cachePolicy = kPFCachePolicyNetworkOnly;
    [query whereKey:@"UUID" equalTo:TROVE_UUID];
    [query whereKey:@"major" equalTo:self.major];
    [query whereKey:@"minor" equalTo:self.minor];
    [query whereKey:@"platform" equalTo:PLATFORM];
    
    PFObject *userPhoto = [query getFirstObject];
    PFFile* existing = [userPhoto objectForKey:@"pictureFile"];
    [existing getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) {
            UIImage *image = [UIImage imageWithData:data];
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
            // image can now be set on a UIImageView
        }
    }];
    
    NSData *imageData = UIImagePNGRepresentation(image);
    PFFile *imageFile = [PFFile fileWithName:@"image.png" data:imageData];
    
    userPhoto[@"pictureFile"] = imageFile;
    [userPhoto saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error){
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
        else {
            NSLog(@"Success?");
        }
    }];
    
    }

- (BOOL)proximity:(CLProximity) prox1 closerThan:(CLProximity) prox2 {
    switch (prox1) {
        case CLProximityFar:
            switch (prox2) {
                case CLProximityFar:
                    return YES;
                case CLProximityUnknown:
                    return YES;
                case CLProximityImmediate:
                    return NO;
                case CLProximityNear:
                    return NO;
            }
        case CLProximityUnknown:
            switch (prox2) {
                case CLProximityFar:
                    return NO;
                case CLProximityUnknown:
                    return YES;
                case CLProximityImmediate:
                    return NO;
                case CLProximityNear:
                    return NO;
            }
        case CLProximityImmediate:
            switch (prox2) {
                case CLProximityFar:
                    return YES;
                case CLProximityUnknown:
                    return YES;
                case CLProximityImmediate:
                    return YES;
                case CLProximityNear:
                    return YES;
            }
        case CLProximityNear:
            switch (prox2) {
                case CLProximityFar:
                    return YES;
                case CLProximityUnknown:
                    return YES;
                case CLProximityImmediate:
                    return NO;
                case CLProximityNear:
                    return YES;
            }
    }
}

@end
