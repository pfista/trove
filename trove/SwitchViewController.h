//
//  SwitchViewController.h
//  trove
//
//  Created by Michael Pfister on 2/16/14.
//  Copyright (c) 2014 Michael Pfister. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TroveModel.h"

@protocol SwitchViewDelegate <NSObject>

@required
- (void) dismissSwitchViewController;

@end

@interface SwitchViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) id<SwitchViewDelegate> delegate;
/* Data model that talks to Parse */
@property (strong, nonatomic) TroveModel *troveModel;

@end
