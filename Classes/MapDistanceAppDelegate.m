//
//  MapDistanceAppDelegate.m
//  MapDistance
//
//  Created by Christian Dunn on 12/19/10.
//  Copyright 2010 Cornell University. All rights reserved.
//

#import "MapDistanceAppDelegate.h"
#import "MapDistanceViewController.h"

@implementation MapDistanceAppDelegate

@synthesize window;
@synthesize viewController;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after application launch.
    CGRect ScreenSize = [[UIScreen mainScreen] bounds];
    //NSLog(@"Screen Size: [%f, %f]", ScreenSize.size.width, ScreenSize.size.height);

    // Add the view controller's view to the window and display.
	
	current_device= [UIDevice currentDevice];
    user_defaults = [NSUserDefaults standardUserDefaults];
    [user_defaults synchronize];
    
    /* Set configuration settings to defaults */
    if (![user_defaults boolForKey:@"AppLaunchedBefore"]) {
        [user_defaults setBool:TRUE forKey:@"AppLaunchedBefore"];
        [user_defaults setBool:TRUE forKey:@"UseAutomaticScroll"];
        [user_defaults setDouble:2.0 forKey:@"latspan"];
        [user_defaults setObject:[NSDate date] forKey:@"ProgramInitialLaunchDate"];
        [user_defaults setBool:TRUE forKey:@"InitialDateSetBefore"];
        [user_defaults setInteger:0 forKey:@"ProgramLaunchCount"];
        [user_defaults setInteger:2 forKey:@"LaunchCountToAskForReview"];
        [user_defaults setFloat:DAYS_TO_WAIT_FOR_REVIEW forKey:@"DayCountToAskForReview"];
        [user_defaults setBool:FALSE forKey:@"DontAskForReview"];
        [user_defaults synchronize];
    } else {
        if (![user_defaults boolForKey:@"InitialDateSetBefore"]) {
            [user_defaults setObject:[NSDate date] forKey:@"ProgramInitialLaunchDate"];
            [user_defaults setBool:TRUE forKey:@"InitialDateSetBefore"];
        }
    }
    [user_defaults synchronize];
    if ([user_defaults floatForKey:@"LastVersionInit"]<LAST_MAJOR_VERSION) {
        [user_defaults setObject:[NSDate date] forKey:@"ProgramInitialLaunchDate"];
        [user_defaults setFloat:LAST_MAJOR_VERSION forKey:@"LastVersionInit"];
    }
    [user_defaults synchronize];
    
    NSInteger programLaunchCount = [user_defaults integerForKey:@"ProgramLaunchCount"];
    [user_defaults setInteger:(programLaunchCount + 1) forKey:@"ProgramLaunchCount"];
    
    if ([current_device userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        device_type_id = 0;
    } else {
        if ([current_device userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            device_type_id = 1;
        }
    }
    
    [user_defaults synchronize];
    
    [self.window setBounds:ScreenSize];
    [viewController.view setBounds:ScreenSize];
    [self.window setRootViewController:viewController];
    [self.window makeKeyAndVisible];
    
	return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    
	[viewController applicationWillResignActive];
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    
	;
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}


@end
