//
//  MapDistanceAppDelegate.h
//  MapDistance
//
//  Created by Christian Dunn on 12/19/10.
//  Copyright 2010 Cornell University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#import "CDVectorMath.h"

#define LAST_MAJOR_VERSION 1.70

@class MapDistanceViewController;

@interface MapDistanceAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	UIDevice *current_device;
    NSInteger device_type_id;
    UIAlertView *considerReviewingAppAlertView;
    UIViewController<MapDistanceViewControllerProtocol> *viewController;
    NSUserDefaults *user_defaults;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UIViewController *viewController;

@end

