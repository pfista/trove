//
//  ImageViewController.h
//  trove
//
//  Created by Michael Pfister on 2/15/14.
//  Copyright (c) 2014 Michael Pfister. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ImageViewDelegate <NSObject>

@required
- (void) dismissImageViewController;

@end

@interface ImageViewController : UIViewController

@property (weak, nonatomic) id<ImageViewDelegate> delegate;


/// self.delegate dismiss Imageview controller to go back on a button or something
@end
