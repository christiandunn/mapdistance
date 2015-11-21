//
//  MapDistanceAboutViewController.h
//  MapDistance
//
//  Created by Christian Dunn on 1/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MapDistanceAboutViewController : UIViewController {
    
    IBOutlet UIWebView *documentationWebView;
    IBOutlet UIButton *documentationCloseButton;
    IBOutlet UILabel *versionLabel;
}

- (void)closeButtonPressed;

@end
