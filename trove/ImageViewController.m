//
//  ImageViewController.m
//  trove
//
//  Created by Michael Pfister on 2/15/14.
//  Copyright (c) 2014 Michael Pfister. All rights reserved.
//

#import "ImageViewController.h"



@interface ImageViewController ()

@property (strong, nonatomic) UIImageView  *imageView;

@end

@implementation ImageViewController

/* Handle Button Actions */
- (IBAction)addImageButtonAction:(id)sender {
    [self selectPhoto:sender];
}
- (IBAction)addImageFromCameraAction:(id)sender {
    [self takePhoto:sender];
}
- (IBAction)addVideoButtonAction:(id)sender {
    
}
- (IBAction)addAudioButtonAction:(id)sender {
    
}
- (IBAction)addMoneyButtonAction:(id)sender {
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UISwipeGestureRecognizer *oneFingerSwipeDown =
    [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(oneFingerSwipeDown:)];
    [oneFingerSwipeDown setDirection:UISwipeGestureRecognizerDirectionDown];
    [[self view] addGestureRecognizer:oneFingerSwipeDown];
    
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                  message:@"Device has no camera"
                 delegate:nil
        cancelButtonTitle:@"OK"
        otherButtonTitles: nil];
        
        [myAlertView show];
        
    }

}

- (void)viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)oneFingerSwipeDown:(UISwipeGestureRecognizer *)recognizer
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)takePhoto:(UIButton *)sender {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = NO;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:picker animated:YES completion:nil];
    
}

- (IBAction)selectPhoto:(UIButton *)sender {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
    [self presentViewController:picker animated:YES completion:nil];
    
    
}

#pragma mark - Image Picker Controller delegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    if (chosenImage) {
        NSLog(@"Image is good");
    }
    if (self.troveModel) {
        [self.troveModel uploadImage:chosenImage];
    }
    else {
        NSLog(@"trove nil");
    }
    
    [picker dismissViewControllerAnimated:NO completion:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
}


@end
