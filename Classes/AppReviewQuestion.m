//
//  AppReviewQuestion.m
//  MapDistance
//
//  Created by Christian Dunn on 1/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppReviewQuestion.h"

@implementation AppReviewQuestion

- (id)initWithConfig:(NSUserDefaults *)_defaults {
    if (self = [super init]) {
        user_defaults = _defaults;
    }
    return self;
}

- (void)main {
        
    NSDate *programInitialLaunchDate = [user_defaults objectForKey:@"ProgramInitialLaunchDate"];
    NSTimeInterval dayCount = -([programInitialLaunchDate timeIntervalSinceNow] / (24.0 * 3600.0));
    
    /* Ask for a review if the day count is large enough */
    considerReviewingAppAlertView = nil;
    [user_defaults synchronize];
    if (dayCount > [user_defaults floatForKey:@"DayCountToAskForReview"] && (![user_defaults boolForKey:@"DontAskForReview"])) {
        considerReviewingAppAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ReviewThisAppTitle", @"") message:NSLocalizedString(@"ReviewThisAppMessage", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"Later", @"") otherButtonTitles:NSLocalizedString(@"YesReview", @""), NSLocalizedString(@"NoReview", @""), nil];
        [considerReviewingAppAlertView show];
        [user_defaults setBool:TRUE forKey:@"DontAskForReview"];
        [user_defaults synchronize];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView == considerReviewingAppAlertView) {
        if (buttonIndex == 0) {
            /* LATER */
            [user_defaults setFloat:([user_defaults floatForKey:@"DayCountToAskForReview"] + 5.0) forKey:@"DayCountToAskForReview"];
            [user_defaults setBool:FALSE forKey:@"DontAskForReview"];
        } else {
            if (buttonIndex == 1) {
                /* REVIEW */
                
                NSString *str = @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa";
                str = [NSString stringWithFormat:@"%@/wa/viewContentsUserReviews?", str]; 
                str = [NSString stringWithFormat:@"%@type=Purple+Software&id=", str];
                
                // Here is the app id from itunesconnect
                str = [NSString stringWithFormat:@"%@413616423", str]; 
                
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
                
                [user_defaults setBool:TRUE forKey:@"DontAskForReview"];
                
            } else {
                if (buttonIndex == 2) {
                    /* DON'T REVIEW: Make sure the user is not asked again. */
                    [user_defaults setBool:TRUE forKey:@"DontAskForReview"];
                }
            }
        }
        [user_defaults synchronize];
    }
}

@end
